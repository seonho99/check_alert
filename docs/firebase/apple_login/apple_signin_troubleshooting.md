# Apple Sign-In 문제 해결 가이드

## 빠른 진단 체크리스트

Apple Sign-In 문제 발생 시 다음 순서로 확인:

1. [ ] Runner.entitlements 파일 존재 및 capability 설정
2. [ ] Firebase Console에서 Apple Provider 활성화
3. [ ] Xcode에서 Sign In with Apple Capability 추가
4. [ ] Info.plist에 CFBundleIdentifier 설정
5. [ ] 실제 기기의 Apple ID 로그인 상태
6. [ ] iOS 13 이상 버전 확인

## 주요 에러 메시지별 해결책

### 1. "이메일 또는 비밀번호가 올바르지 않습니다"

**발생 상황**: iOS 실기기에서 Apple 로그인 버튼 클릭 시

**근본 원인**:
- Firebase Auth가 Apple Sign-In 자격 증명을 인식하지 못함
- Entitlements 설정 누락

**해결 단계**:

1. **Runner.entitlements 확인**
```xml
<!-- ios/Runner/Runner.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>aps-environment</key>
    <string>development</string>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

2. **project.pbxproj 확인**
```bash
grep "CODE_SIGN_ENTITLEMENTS" ios/Runner.xcodeproj/project.pbxproj
# 출력: CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
```

3. **Info.plist Bundle ID 확인**
```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

4. **불필요한 URL Scheme 제거**
```xml
<!-- ❌ 잘못된 설정 - Apple Sign-In URL Scheme -->
<dict>
    <key>CFBundleURLName</key>
    <string>APPLE_SIGN_IN</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>com.googleusercontent.apps.xxx</string> <!-- 제거 필요 -->
    </array>
</dict>
```

### 2. "Sign in with Apple is not available"

**발생 상황**: 로그인 시도 시 서비스 사용 불가 메시지

**해결책**:

1. **기기 설정 확인**
   - Settings → Apple ID 로그인 확인
   - Settings → Sign In & Security → Sign In with Apple 활성화

2. **iOS 버전 확인**
```swift
// iOS 13 이상 필요
if #available(iOS 13.0, *) {
    // Apple Sign-In 사용 가능
}
```

3. **시뮬레이터 설정**
   - Hardware → Device → Manage Apple ID
   - 실제 Apple ID로 로그인

### 3. "Invalid Credential" 또는 "unauthorized-domain"

**발생 상황**: Firebase Auth 에러

**해결책**:

1. **Firebase Console 설정**
   - Authentication → Sign-in method → Apple
   - Service ID: `com.seonho.lifetimeledger.service`
   - Team ID: `W6M84FB5NG`
   - Key 파일 업로드

2. **Apple Developer Console 확인**
   - Service ID의 Return URL 확인
   ```
   https://lifetime-ledger.firebaseapp.com/__/auth/handler
   ```

### 4. "User cancelled the sign-in flow"

**발생 상황**: 사용자가 로그인 취소

**코드 처리**:
```dart
if (e.code == 'user-cancelled' || e.toString().contains('canceled')) {
  throw ValidationException('Apple 로그인이 취소되었습니다');
}
```

### 5. Xcode 빌드 에러

**에러**: "Provisioning profile doesn't support the Sign In with Apple capability"

**해결책**:

1. **Xcode에서 Capability 추가**
   - Runner → Signing & Capabilities
   - "+ Capability" → "Sign In with Apple"

2. **Provisioning Profile 재생성**
   - Apple Developer Console → Profiles
   - 기존 프로파일 삭제 후 재생성
   - Xcode에서 다운로드

## 디버깅 로그 분석

### 성공적인 로그인 플로우
```
flutter: 🍎 Apple 로그인 시작
flutter: 🔍 현재 플랫폼: ios
flutter: ✅ AppleAuthProvider 설정 완료
flutter: 🚀 Firebase Apple 로그인 성공: [UID]
flutter: 📧 사용자 이메일: xxx@privaterelay.appleid.com
flutter: ✅ [SignInViewModel] Apple 로그인 성공
```

### 실패 시 확인 포인트
```
flutter: ❌ Firebase 인증 오류: [ERROR_CODE] - [ERROR_MESSAGE]
```

주요 에러 코드:
- `invalid-credential`: Firebase 설정 문제
- `user-cancelled`: 사용자 취소
- `operation-not-allowed`: Provider 미활성화
- `unauthorized-domain`: Service ID 문제

## 플랫폼별 특이사항

### iOS 실기기
- **장점**: Face ID/Touch ID로 빠른 인증
- **제한**: 기기에 Apple ID 로그인 필수
- **특징**: Private Relay 이메일 자동 생성

### iOS 시뮬레이터
- **제한**: Apple ID 로그인 복잡
- **대안**: 실기기 테스트 권장

### Android
- **현재 상태**: 미지원 (ValidationException 발생)
- **향후 계획**: Web 기반 Apple Sign-In 구현 가능

## 자동화 가능 vs 수동 작업

### 🤖 Claude Code가 자동으로 수정 가능
- ✅ Entitlements 파일 생성 및 수정
- ✅ Info.plist 설정
- ✅ 코드 구현 및 에러 핸들링
- ✅ URL Scheme 정리

### 👤 사용자가 직접 해야 함
- ❌ Apple Developer Console 설정
- ❌ Firebase Console Provider 활성화
- ❌ Xcode Capability 추가
- ❌ Provisioning Profile 갱신

## 테스트 시나리오

### 1. 정상 로그인 테스트
```dart
// 예상 결과
// 1. Apple 로그인 시트 표시
// 2. Face ID 인증
// 3. Firebase 사용자 생성
// 4. 홈 화면 이동
```

### 2. 취소 테스트
```dart
// 예상 결과
// 1. Apple 로그인 시트 표시
// 2. 취소 버튼 탭
// 3. ValidationException 발생
// 4. 에러 메시지 표시
```

### 3. 재로그인 테스트
```dart
// 예상 결과
// 1. 기존 사용자로 로그인
// 2. 이메일/이름 정보 유지
// 3. FCM 토큰 업데이트
```

## 긴급 복구 절차

Apple Sign-In이 완전히 작동하지 않을 때:

1. **캐시 정리**
```bash
flutter clean
cd ios && pod deintegrate && pod install
```

2. **Xcode 정리**
- Product → Clean Build Folder (⇧⌘K)
- DerivedData 삭제

3. **Firebase 재설정**
- google-services.json 재다운로드
- GoogleService-Info.plist 재다운로드

4. **최소 구성 테스트**
```dart
// 최소한의 Apple Sign-In 테스트
final appleProvider = AppleAuthProvider();
await FirebaseAuth.instance.signInWithProvider(appleProvider);
```

## FAQ

### Q: Android에서 Apple 로그인을 지원하려면?
A: 현재는 미지원. Web 기반 구현 필요 (Service ID 활용)

### Q: Private Relay 이메일을 실제 이메일로 변환?
A: 불가능. Apple의 프라이버시 정책

### Q: 첫 로그인 후 displayName이 null인 이유?
A: Apple은 첫 로그인 시에만 이름 제공. 이후 로그인은 null

### Q: 에뮬레이터에서 테스트 가능?
A: 복잡함. 실기기 테스트 권장

## 관련 리소스

- [Firebase Console](https://console.firebase.google.com)
- [Apple Developer Console](https://developer.apple.com)
- [Sign In with Apple Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)

---

이 문서는 실제 프로젝트에서 발생한 문제와 해결 과정을 기반으로 작성되었습니다.
새로운 문제 발생 시 이 문서를 업데이트하여 지식을 축적하세요.