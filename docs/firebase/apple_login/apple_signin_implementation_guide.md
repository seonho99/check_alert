# Apple Sign-In 구현 가이드 (Complete Guide)

## 목차
1. [개요](#개요)
2. [필수 전제 조건](#필수-전제-조건)
3. [설정 단계별 가이드](#설정-단계별-가이드)
4. [코드 구현](#코드-구현)
5. [일반적인 문제와 해결책](#일반적인-문제와-해결책)
6. [플랫폼별 동작 차이](#플랫폼별-동작-차이)
7. [보안 및 프라이버시](#보안-및-프라이버시)
8. [검증 체크리스트](#검증-체크리스트)

## 개요

Apple Sign-In은 iOS 13 이상에서 사용 가능한 인증 방식으로, 사용자의 Apple ID를 통해 안전하고 빠른 로그인을 제공합니다.

### 주요 특징
- **iOS**: Face ID/Touch ID를 통한 생체 인증
- **Android**: 웹 기반 Apple ID 로그인
- **Hide My Email**: 사용자 실제 이메일 대신 Private Relay 이메일 제공

### 프로젝트 정보
- **Bundle ID**: `com.seonho.lifetimeledger`
- **Firebase Project ID**: `lifetime-ledger`
- **Development Team**: `W6M84FB5NG`

## 필수 전제 조건

### 🔧 Apple Developer 계정 요구사항
1. Apple Developer Program 가입 (유료)
2. App ID에서 Sign In with Apple 활성화
3. Service ID 생성 (웹/Android용)

### 🤖 Claude Code가 자동으로 할 수 있는 작업
- ✅ Entitlements 파일 수정
- ✅ Info.plist 설정
- ✅ 코드 구현 (DataSource, UseCase, ViewModel)
- ✅ 에러 핸들링 로직
- ✅ Firebase 설정 파일 수정

### 👤 사용자가 직접 해야 하는 작업
- ❌ Apple Developer Console에서 Sign In with Apple 활성화
- ❌ Firebase Console에서 Apple Provider 설정
- ❌ Service ID 및 Key 파일 생성
- ❌ Xcode에서 Capability 추가

## 설정 단계별 가이드

### Step 1: Apple Developer Console 설정

#### 1.1 App ID 설정
1. [Apple Developer](https://developer.apple.com) 접속
2. Certificates, Identifiers & Profiles → Identifiers
3. App ID 선택 또는 생성
4. Capabilities에서 "Sign In with Apple" 체크
5. Save

#### 1.2 Service ID 생성 (Android/Web용)
1. Identifiers → + 버튼
2. Service IDs 선택
3. Identifier: `com.seonho.lifetimeledger.service`
4. Description: `Lifetime Ledger Sign In`
5. Configure → Primary App ID 선택
6. Return URL 설정:
   ```
   https://lifetime-ledger.firebaseapp.com/__/auth/handler
   ```

#### 1.3 Key 생성
1. Keys → + 버튼
2. Key Name: `Lifetime Ledger Auth Key`
3. Sign In with Apple 체크
4. Configure → Primary App ID 선택
5. .p8 파일 다운로드 (한 번만 다운로드 가능!)

### Step 2: Firebase Console 설정

1. [Firebase Console](https://console.firebase.google.com) 접속
2. Authentication → Sign-in method
3. Apple 제공업체 추가
4. 활성화 및 다음 정보 입력:
   - Service ID: `com.seonho.lifetimeledger.service`
   - Team ID: `W6M84FB5NG`
   - Key ID: 생성한 키의 ID
   - Private Key: .p8 파일 내용

### Step 3: iOS 프로젝트 설정

#### 3.1 Entitlements 파일 수정
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

#### 3.2 Info.plist 설정
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

<!-- URL Schemes는 Apple Sign-In에 필요하지 않음 -->
<!-- Google Sign-In URL Scheme만 유지 -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>GOOGLE_SIGN_IN</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.[YOUR_GOOGLE_CLIENT_ID]</string>
        </array>
    </dict>
</array>
```

#### 3.3 Xcode Capability 추가
1. Xcode에서 프로젝트 열기
2. Runner → Signing & Capabilities
3. "+ Capability" 클릭
4. "Sign In with Apple" 추가

### Step 4: Flutter 패키지 설정

```yaml
# pubspec.yaml
dependencies:
  firebase_auth: ^5.6.0
  firebase_core: ^3.14.0
```

## 코드 구현

### 1. DataSource 구현

```dart
// lib/data/datasource/auth_firebase_datasource_impl.dart

@override
Future<String> signInWithApple() async {
  try {
    print('🍎 Apple 로그인 시작');
    print('🔍 현재 플랫폼: ${Platform.operatingSystem}');

    // Android에서는 Apple 로그인 지원하지 않음
    if (Platform.isAndroid) {
      throw ValidationException(
        'Android에서는 Apple 로그인을 지원하지 않습니다. Google 로그인을 이용해주세요.'
      );
    }

    // Firebase Auth AppleAuthProvider 생성 (iOS만)
    AppleAuthProvider appleProvider = AppleAuthProvider();
    appleProvider = appleProvider.addScope('email');
    appleProvider = appleProvider.addScope('name');

    print('✅ AppleAuthProvider 설정 완료');

    // Firebase Auth를 통한 Apple 로그인
    final UserCredential userCredential =
        await _firebaseAuth.signInWithProvider(appleProvider);

    if (userCredential.user == null) {
      throw ServerException('Apple 로그인에 실패했습니다');
    }

    print('🚀 Firebase Apple 로그인 성공: ${userCredential.user!.uid}');
    print('📧 사용자 이메일: ${userCredential.user!.email}');
    print('👤 사용자 이름: ${userCredential.user!.displayName}');

    return userCredential.user!.uid;

  } on FirebaseAuthException catch (e) {
    print('❌ Firebase 인증 오류: ${e.code} - ${e.message}');

    // Apple Sign-In 특정 에러 처리
    if (e.code == 'invalid-credential' || e.code == 'unauthorized-domain') {
      throw ServerException(
        'Apple Sign-In이 올바르게 구성되지 않았습니다. '
        'Firebase Console에서 Apple Sign-In 설정을 확인해주세요.'
      );
    }

    if (e.code == 'user-cancelled' || e.toString().contains('canceled')) {
      throw ValidationException('Apple 로그인이 취소되었습니다');
    }

    throw _mapFirebaseAuthException(e);
  } catch (e) {
    print('❌ Apple 로그인 오류: $e');
    print('❌ 오류 타입: ${e.runtimeType}');

    if (e is ValidationException) rethrow;
    if (e is ServerException) rethrow;

    // 사용자가 취소한 경우
    if (e.toString().contains('canceled') ||
        e.toString().contains('cancelled')) {
      throw ValidationException('Apple 로그인이 취소되었습니다');
    }

    // 네트워크 오류 체크
    if (e.toString().contains('network') ||
        e.toString().contains('Network') ||
        e.toString().contains('connection') ||
        e.toString().contains('Connection')) {
      throw NetworkException(
        '네트워크 연결을 확인해주세요. '
        'Wi-Fi 또는 모바일 데이터가 켜져 있는지 확인하세요.'
      );
    }

    // Sign in with Apple is not available 에러
    if (e.toString().contains('not available')) {
      throw ServerException(
        'Apple Sign-In 서비스를 사용할 수 없습니다. '
        '기기 설정에서 Apple ID 로그인 상태를 확인해주세요.'
      );
    }

    throw ServerException('Apple 로그인 중 오류가 발생했습니다');
  }
}
```

### 2. UseCase 구현

```dart
// lib/domain/usecase/apple_signin_usecase.dart

class AppleSignInUseCase {
  final AuthRepository _authRepository;

  AppleSignInUseCase({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<Result<UserModel>> execute() async {
    try {
      print('🎯 UseCase: Apple 로그인 실행');
      final result = await _authRepository.signInWithApple();
      return result;
    } catch (e) {
      print('❌ UseCase: Apple 로그인 예외 발생 - $e');
      return Error(
        ServerFailure('Apple 로그인 중 예기치 않은 오류가 발생했습니다')
      );
    }
  }
}
```

### 3. ViewModel 구현

```dart
// lib/ui/auth/signin/signin_viewmodel.dart

Future<void> signInWithApple() async {
  _updateState(_state.copyWith(
    isLoading: true,
    errorMessage: null,
    successMessage: null,
  ));

  try {
    print('🚀 [SignInViewModel] Apple 로그인 시작');

    // Apple 로그인 UseCase 호출
    final result = await _appleSignInUseCase.execute();

    result.when(
      success: (user) async {
        print('✅ [SignInViewModel] Apple 로그인 성공 - ${user.email}');

        // Firebase Auth 상태 동기화
        await _waitForAuthStateUpdate(user.uid);

        // 사용자 정보를 Firestore에 저장
        await _saveUserToFirestore(user);

        // FCM 토큰 업데이트
        final fcmService = FCMService();
        await fcmService.updateTokenForUser(user.uid, null);

        _updateState(_state.copyWith(
          isLoading: false,
          successMessage: '로그인 성공! 환영합니다, ${user.displayName ?? user.email}',
          isLoginSuccess: true,
          errorMessage: null,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
          isLoginSuccess: false,
          successMessage: null,
        ));
      },
    );
  } catch (e) {
    String errorMessage = 'Apple 로그인 중 오류가 발생했습니다';

    if (e.toString().contains('사용할 수 없습니다')) {
      errorMessage =
        'Apple Sign-In 서비스를 사용할 수 없습니다. '
        '네트워크 연결을 확인해주세요.';
    }

    _updateState(_state.copyWith(
      isLoading: false,
      errorMessage: errorMessage,
      isLoginSuccess: false,
      successMessage: null,
    ));
  }
}
```

### 4. UI 구현

```dart
// lib/ui/auth/signin/signin_screen.dart

Widget _buildAppleSignInButton(SignInViewModel viewModel) {
  return Container(
    width: 64,
    height: 64,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(32),
      color: const Color(0xFF000000),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: viewModel.isLoading
        ? null
        : () => _handleAppleSignIn(viewModel),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: const Icon(
        Icons.apple,
        color: Colors.white,
        size: 28,
      ),
    ),
  );
}

void _handleAppleSignIn(SignInViewModel viewModel) {
  print('🍎 Apple 로그인 버튼 클릭됨');
  viewModel.signInWithApple();
}
```

## 일반적인 문제와 해결책

### ❌ 문제 1: "이메일 또는 비밀번호가 올바르지 않습니다"

**원인**:
- Runner.entitlements에 Apple Sign-In capability 없음
- Firebase Console에서 Apple Provider 미설정

**해결책**:
1. Runner.entitlements 파일에 capability 추가
2. Firebase Console에서 Apple Sign-In 활성화
3. Service ID, Team ID, Key 정보 정확히 입력

### ❌ 문제 2: "Sign in with Apple is not available"

**원인**:
- 기기에 Apple ID 로그인 안 됨
- iOS 버전이 13 미만
- 시뮬레이터에서 Apple ID 설정 안 됨

**해결책**:
1. Settings → Sign in to your iPhone
2. iOS 13 이상 확인
3. 실제 기기에서 테스트

### ❌ 문제 3: Invalid Credential Error

**원인**:
- Firebase에 Apple Provider 설정 오류
- Service ID 불일치

**해결책**:
1. Firebase Console → Authentication → Sign-in method
2. Apple 설정 재확인
3. Service ID가 Apple Developer Console과 일치하는지 확인

### ❌ 문제 4: Xcode Build 오류

**원인**:
- Entitlements 파일이 프로젝트에 연결 안 됨

**해결책**:
```bash
# project.pbxproj에서 확인
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
```

## 플랫폼별 동작 차이

### iOS (iPhone/iPad)
- **인증 방식**: Face ID / Touch ID
- **계정 연동**: 기기에 로그인된 Apple ID 자동 사용
- **비밀번호**: 불필요 (생체 인증)
- **첫 로그인**: 이메일 공개/숨김 선택 가능
- **Private Relay**: `xxxxx@privaterelay.appleid.com`

### Android
- **인증 방식**: 웹 브라우저 리다이렉트
- **계정 연동**: Apple ID와 비밀번호 직접 입력
- **2차 인증**: SMS 또는 신뢰할 수 있는 기기 필요
- **제한사항**: Service ID 설정 필수

### 주요 차이점
```dart
// iOS
// 1. 버튼 탭
// 2. Face ID 인증
// 3. 완료

// Android
// 1. 버튼 탭
// 2. 웹 브라우저 열림
// 3. Apple ID 입력
// 4. 비밀번호 입력
// 5. 2차 인증
// 6. 앱으로 리다이렉트
```

## 보안 및 프라이버시

### Hide My Email 기능
- 실제 이메일 대신 랜덤 생성 이메일 제공
- 형식: `cdmqrpqv7n@privaterelay.appleid.com`
- Apple이 실제 이메일로 전달

### 사용자 정보 처리
```dart
// Private Relay 이메일 처리
if (user.email?.contains('@privaterelay.appleid.com') == true) {
  // Hide My Email 사용 중
  // 실제 이메일 요청 불가
  // displayName이나 uid로 사용자 식별
}
```

### 필수 권한
- **email**: 이메일 주소 (Hide My Email 가능)
- **name**: 사용자 이름 (첫 로그인 시만)

## 검증 체크리스트

### 초기 설정 확인
- [ ] Apple Developer Program 가입 완료
- [ ] App ID에서 Sign In with Apple 활성화
- [ ] Service ID 생성 (Android/Web용)
- [ ] Key 파일(.p8) 생성 및 저장
- [ ] Firebase Console에서 Apple Provider 설정

### iOS 프로젝트 설정
- [ ] Runner.entitlements 파일 생성
- [ ] com.apple.developer.applesignin capability 추가
- [ ] Info.plist에 CFBundleIdentifier 존재
- [ ] Xcode에서 Sign In with Apple Capability 추가
- [ ] CODE_SIGN_ENTITLEMENTS 설정 확인

### 코드 구현
- [ ] AuthDataSource에 signInWithApple 메서드 구현
- [ ] AppleSignInUseCase 생성
- [ ] ViewModel에 Apple 로그인 메서드 추가
- [ ] UI에 Apple 로그인 버튼 추가
- [ ] 에러 핸들링 구현

### 테스트
- [ ] iOS 실기기에서 Face ID/Touch ID 로그인 성공
- [ ] Firebase Console에서 사용자 생성 확인
- [ ] Private Relay 이메일 처리 확인
- [ ] 로그아웃 후 재로그인 정상 동작
- [ ] FCM 토큰 저장 확인

### 성공 로그 예시
```
flutter: 🍎 Apple 로그인 시작
flutter: 🔍 현재 플랫폼: ios
flutter: ✅ AppleAuthProvider 설정 완료
flutter: 🚀 Firebase Apple 로그인 성공: a3SawMt2oFNoHHCAsjVUaO1R7qI2
flutter: 📧 사용자 이메일: cdmqrpqv7n@privaterelay.appleid.com
flutter: 👤 사용자 이름: null
flutter: ✅ [SignInViewModel] Apple 로그인 성공
```

## 추가 리소스

### 공식 문서
- [Apple Developer - Sign In with Apple](https://developer.apple.com/sign-in-with-apple/)
- [Firebase - Authenticate Using Apple](https://firebase.google.com/docs/auth/flutter/federated-auth#apple)
- [Human Interface Guidelines - Sign In with Apple](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)

### 주의사항
1. **개발 환경**: Debug 모드에서도 실제 Apple ID 필요
2. **앱 심사**: Apple 로그인 제공 시 반드시 포함해야 함 (iOS 앱)
3. **버튼 디자인**: Apple의 디자인 가이드라인 준수 필수

---

이 가이드를 따라 Apple Sign-In을 성공적으로 구현할 수 있습니다.
다음 프로젝트에서 Claude Code가 이 문서를 참조하여 자동으로 설정할 수 있습니다.