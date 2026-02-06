# iOS 카카오 로그인 구현 가이드

## 🎯 빠른 시작 프롬프트 (새 프로젝트용)

```
iOS 카카오 로그인을 구현해줘.
- Bundle ID: com.seonho.lifetimeledger
- 카카오 앱 키: e59b708268251e6680e30d2b0898646f
- Firebase 프로젝트: lifetime-ledger
- Custom Token 방식 사용 (이미 배포된 Functions 활용)

다음 순서로 진행:
1. Podfile에 카카오 SDK 추가 (KakaoSDKCommon, KakaoSDKAuth, KakaoSDKUser)
2. iOS Deployment Target 13.0 설정 (project.pbxproj, AppFrameworkInfo.plist, Podfile)
3. Info.plist 설정 (URL Scheme, KAKAO_APP_KEY, LSApplicationQueriesSchemes)
4. AppDelegate.swift 수정 (import, 초기화, URL 핸들링)
5. Pod 설치 및 빌드

주의: Runner.xcworkspace 사용 (xcodeproj 아님)
```

## 프로젝트 정보
- **프로젝트**: lifetime-ledger
- **iOS Bundle ID**: com.seonho.lifetimeledger
- **카카오 앱 키**: e59b708268251e6680e30d2b0898646f
- **Firebase Project ID**: lifetime-ledger

## 구현 완료 사항

### 1. Info.plist 설정 ✅

#### CFBundleURLTypes (URL Scheme 설정)
```xml
<key>CFBundleURLTypes</key>
<array>
    <!-- Google Sign-In URL Scheme -->
    <dict>
        <key>CFBundleURLName</key>
        <string>GOOGLE_SIGN_IN</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.572681652958-m0phm6l9f6inst6cbvr439lhi8csssrm</string>
        </array>
    </dict>
    <!-- Kakao URL Scheme -->
    <dict>
        <key>CFBundleURLName</key>
        <string>KAKAO_APP_KEY</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakaoe59b708268251e6680e30d2b0898646f</string>
        </array>
    </dict>
</array>
```

#### 카카오 앱 키 저장
```xml
<key>KAKAO_APP_KEY</key>
<string>e59b708268251e6680e30d2b0898646f</string>
```

#### LSApplicationQueriesSchemes (카카오톡 실행 가능 체크)
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaoplus</string>
</array>
```

### 2. AppDelegate.swift 설정 ✅

#### Import 추가
```swift
import KakaoSDKCommon
import KakaoSDKAuth
```

#### 카카오 SDK 초기화 (didFinishLaunchingWithOptions)
```swift
// 카카오 SDK 초기화
let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String ?? ""
KakaoSDK.initSDK(appKey: kakaoAppKey)
```

#### URL 핸들링 메서드 추가
```swift
// 카카오 로그인을 위한 URL 핸들링
override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if (AuthApi.isKakaoTalkLoginUrl(url)) {
        return AuthController.handleOpenUrl(url: url)
    }

    return super.application(app, open: url, options: options)
}
```

### 3. Flutter 코드 (이미 구현됨) ✅

- `lib/data/datasource/auth_firebase_datasource_impl.dart`
  - Custom Token 방식 구현
  - 카카오톡/카카오 계정 로그인 분기 처리
  - Firebase Functions 호출 (`createKakaoCustomToken`)

### 4. Firebase Functions (이미 배포됨) ✅

- `createKakaoCustomToken` 함수
- 엔드포인트: `https://us-central1-lifetime-ledger.cloudfunctions.net/createKakaoCustomToken`

## 빌드 및 테스트

### Pod 설치 (카카오 SDK 포함)
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

### 빌드 명령어
```bash
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock ~/Library/Developer/Xcode/DerivedData
pod install
cd ..
flutter build ios --release
```

### Xcode에서 빌드
```bash
open ios/Runner.xcworkspace
# Product → Clean Build Folder (Shift+Cmd+K)
# Product → Build (Cmd+B)
```

### 테스트 체크리스트

1. **카카오톡 설치된 기기** ✅ (실기기 테스트 완료!)
   - [x] 카카오톡 앱이 열리는지 확인
   - [x] 로그인 후 앱으로 돌아오는지 확인
   - [x] Firebase Auth 로그인 성공 확인
   - [x] Firestore 사용자 정보 저장 확인

2. **카카오톡 미설치 기기**
   - [ ] 웹뷰로 카카오 계정 로그인 화면이 나타나는지 확인
   - [ ] 로그인 완료 후 앱으로 돌아오는지 확인
   - [ ] Firebase Auth 로그인 성공 확인
   - [ ] Firestore 사용자 정보 저장 확인

3. **로그아웃**
   - [ ] 카카오 + Firebase 로그아웃 확인
   - [ ] 재로그인 정상 작동 확인

## 주의사항

### iOS 특정 사항
1. **시뮬레이터 제한**: iOS 시뮬레이터에서는 카카오톡 앱을 설치할 수 없으므로 웹 로그인만 가능
2. **실기기 테스트 필수**: 카카오톡 연동 테스트는 실제 기기에서 진행
3. **URL Scheme 충돌**: 다른 앱과 URL Scheme이 충돌하지 않도록 주의

### 카카오 개발자 콘솔 설정
1. iOS 플랫폼 등록 필수
   - Bundle ID: `com.seonho.lifetimeledger`
   - 앱스토어 ID: (출시 후 등록)
2. 리다이렉트 URI 설정 (Firebase용)
   - `https://lifetime-ledger.firebaseapp.com/__/auth/handler`

## 트러블슈팅

### ✅ 해결 완료: iOS Deployment Target 오류
**문제**: `Compiling for iOS 12.0, but module 'KakaoSDKCommon' has a minimum deployment target of iOS 13.0`
**해결**:
1. `/ios/Runner.xcodeproj/project.pbxproj`에서 `IPHONEOS_DEPLOYMENT_TARGET = 13.0` 변경
2. `/ios/Flutter/AppFrameworkInfo.plist`에서 `MinimumOSVersion` 13.0 변경
3. `/ios/Podfile`에서 `platform :ios, '13.0'` 확인
4. DerivedData 삭제: `rm -rf ~/Library/Developer/Xcode/DerivedData`

### ✅ 해결 완료: No such module 오류
**문제**: `No such module 'KakaoSDKCommon'` 또는 `No such module 'Flutter'`
**해결**:
1. **반드시 `.xcworkspace` 파일 사용** (`.xcodeproj` 아님!)
2. Podfile에 카카오 SDK 추가:
   ```ruby
   pod 'KakaoSDKCommon'
   pod 'KakaoSDKAuth'
   pod 'KakaoSDKUser'
   ```
3. Pod 재설치:
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install --repo-update
   ```

### 문제 1: 카카오톡 앱이 열리지 않음
**원인**: LSApplicationQueriesSchemes 누락
**해결**: Info.plist에 `kakaokompassauth` 스키마 추가

### 문제 2: 로그인 후 앱으로 돌아오지 않음
**원인**: URL Scheme 설정 오류 또는 AppDelegate 핸들링 누락
**해결**:
- Info.plist의 CFBundleURLSchemes 확인
- AppDelegate.swift의 URL 핸들링 메서드 확인

### 문제 3: Firebase Custom Token 생성 실패
**원인**: Functions 권한 또는 카카오 토큰 검증 실패
**해결**:
- Firebase Functions 로그 확인
- IAM 권한 확인 (Service Account Token Creator)
- 카카오 앱 키 확인

## 다음 단계

1. **프로덕션 준비**
   - 앱스토어 ID 등록
   - 카카오 비즈앱 전환 검토
   - 사용자 약관 및 개인정보처리방침 연동

2. **기능 확장**
   - 카카오 프로필 이미지 연동
   - 카카오 친구 목록 연동 (선택)
   - 카카오페이 연동 (선택)

## 참고 링크

- [카카오 로그인 Flutter SDK](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)
- [카카오 로그인 iOS 가이드](https://developers.kakao.com/docs/latest/ko/kakaologin/ios)
- [Firebase Custom Authentication](https://firebase.google.com/docs/auth/admin/create-custom-tokens)
- [Android 구현 가이드](/docs/firebase/kakao_login/kakao_sign_in_android_guide.md)