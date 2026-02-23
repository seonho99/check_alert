# Google 로그인 오류: [16] Account reauth failed

## 오류 메시지
```
GoogleSignInException(code GoogleSignInExceptionCode.canceled, [16] Account reauth failed., null)
```

## 발생 조건
- `google_sign_in: ^7.x` 사용
- **Play Store에서 설치한 앱**에서만 발생 (디버그/릴리즈 로컬 빌드는 정상)

## 원인
Play Store는 **Play App Signing** 을 사용하여 앱을 재서명합니다.

| 구분 | SHA-1 |
|------|-------|
| 개발자 업로드 키 | `f8:0d:97:...` |
| Play App Signing 앱 서명 키 | `EE:6A:4D:1D:AD:C0:C2:DD:...` ← **이게 기기에 설치됨** |

Firebase에 **Play App Signing 인증서 SHA-1** 이 등록되지 않으면 Credential Manager 인증 실패.

## 해결 절차

### 1. Play Console에서 SHA-1 확인
```
Play Console → 앱 선택 → 설정 → 앱 서명
→ "앱 서명 키 인증서"의 SHA-1 복사
  (업로드 키 인증서 SHA-1이 아님!)
```

### 2. Firebase Console에 SHA-1 추가
```
Firebase Console → 프로젝트 설정 → 해당 Android 앱
→ 디지털 지문 추가 → Play App Signing SHA-1 입력 → 저장
```

### 3. google-services.json 교체
Firebase Console에서 최신 `google-services.json` 다운로드 후
`android/app/google-services.json` 교체

### 4. 코드 수정 (google_sign_in v7 필수)
`lib/data/datasource/auth_firebase_datasource_impl.dart`

```dart
// _initializeGoogleSignIn() 내부
await _googleSignIn.initialize(
  clientId: '[새로 생성된 Android OAuth 클라이언트 ID]', // google-services.json에서 확인
  serverClientId: '[Web 클라이언트 ID]',                 // client_type: 3
);
```

> `clientId`는 새로 추가된 SHA-1에 대응하는 `client_type: 1` Android 클라이언트 ID
> `google-services.json`에서 패키지명에 해당하는 `oauth_client` 목록 중 새로 생긴 것

### 5. 앱 재빌드 및 Play Store 재배포

## 현재 프로젝트 적용값 (2026-02-23)

| 항목 | 값 |
|------|----|
| 패키지명 | `seonho.com.share_status.share_status` |
| Play App Signing SHA-1 | `EE:6A:4D:1D:AD:C0:C2:DD:C8:8B:51:8D:22:85:8D:3E:71:62:AE:31` |
| 적용된 clientId | `92105577038-e2qh282rkc87ll94et30349jf7agi9je.apps.googleusercontent.com` |
| serverClientId | `92105577038-slpl4jp7t6chqjg9gq9e4gd6fqg9l7re.apps.googleusercontent.com` |

## 참고
- [Flutter Issue #174744](https://github.com/flutter/flutter/issues/174744)
- [google_sign_in v7 마이그레이션 가이드](https://isaacadariku.medium.com/google-sign-in-flutter-migration-guide-pre-7-0-versions-to-v7-version-cdc9efd7f182)
