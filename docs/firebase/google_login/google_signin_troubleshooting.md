# Google Sign-In 구현 및 문제 해결 가이드

## 목차
1. [전체 구현 흐름](#전체-구현-흐름)
2. [필수 설정](#필수-설정)
3. [일반적인 문제와 해결책](#일반적인-문제와-해결책)
4. [단계별 구현 가이드](#단계별-구현-가이드)
5. [검증 방법](#검증-방법)

## 전체 구현 흐름

### 🚀 Quick Start - Google 로그인 구현 순서
1. **Firebase 프로젝트 설정** → Firebase Console에서 Google Sign-In 활성화
2. **패키지 추가** → `google_sign_in`, `firebase_auth` 추가
3. **플랫폼 설정**
   - Android: google-services.json 다운로드 및 배치
   - iOS: GoogleService-Info.plist 다운로드 및 URL Scheme 설정
4. **SHA-1 지문 등록** (Android)
5. **main.dart 초기화** → Firebase 초기화
6. **로그인 로직 구현** → DataSource, UseCase, ViewModel
7. **UI 구현** → 로그인 버튼 및 상태 표시
8. **테스트** → 실기기에서 테스트 (에뮬레이터 X)

## 개요

Flutter 앱에서 Google Sign-In 기능을 구현할 때 발생하는 일반적인 문제들과 해결 방법을 정리한 가이드입니다.

### 주요 오류 유형
- `ApiException: 10 (DEVELOPER_ERROR)`
- `SecurityException: Unknown calling package name`
- iOS CocoaPods 동기화 문제

## 필수 설정

### 1. 패키지 의존성
```yaml
# pubspec.yaml
dependencies:
  google_sign_in: ^6.2.1
  firebase_auth: ^5.6.0
  firebase_core: ^3.14.0
```

### 2. 프로젝트 정보 확인
다음 정보들을 정확히 기록해 두세요:
- **패키지명**: `com.lifetime_ledger_seonho.lifetime_ledger`
- **프로젝트 ID**: `lifetime-ledger`
- **프로젝트 번호**: `572681652958`

### 3. 초기 설정 절차

#### Android 설정
1. **google-services.json 다운로드**
   - Firebase Console → 프로젝트 설정 → google-services.json 다운로드
   - `android/app/` 디렉토리에 복사

2. **build.gradle 설정**
   ```gradle
   // android/app/build.gradle
   dependencies {
     implementation 'com.google.android.gms:play-services-auth:20.7.0'
   }
   ```

#### iOS 설정
1. **GoogleService-Info.plist 다운로드**
   - Firebase Console → 프로젝트 설정 → GoogleService-Info.plist 다운로드
   - Xcode로 `Runner` 폴더에 추가

2. **Info.plist에 URL Scheme 추가**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <!-- GoogleService-Info.plist의 REVERSED_CLIENT_ID 값 -->
         <string>com.googleusercontent.apps.572681652958-xxxxx</string>
       </array>
     </dict>
   </array>
   ```

### 4. main.dart 초기화
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  runApp(MyApp());
}
```

## 사용자 수동 작업 필요 항목

### 🔧 사용자가 직접 해야 하는 작업들
다음 작업들은 **Claude Code가 자동으로 할 수 없으며** 사용자가 직접 수행해야 합니다:

1. **Google Cloud Console 접속 및 OAuth 클라이언트 생성**
2. **Firebase Console에서 google-services.json 다운로드**
3. **다운로드한 파일을 프로젝트에 수동 복사**

### 🤖 Claude Code가 자동으로 할 수 있는 작업들
- SHA-1 지문 생성 및 확인
- 코드 구현 (Provider, DataSource, UseCase 등)
- 설정 파일 수정 (Info.plist, build.gradle 등)
- 의존성 설치 (pubspec.yaml, CocoaPods)
- 문제 진단 및 해결 방안 제시

## 일반적인 문제와 해결책

### ❌ 문제 1: ApiException: 10 (DEVELOPER_ERROR)

**증상:**
```
I/flutter: ❌ Google 로그인 오류: PlatformException(sign_in_failed,
com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**원인:** google-services.json에 Android OAuth 클라이언트 ID가 없음

**해결책:**

1. **SHA-1 지문 확인**
```bash
cd android && ./gradlew signingReport
```
예상 출력: `91:BB:9B:B6:0A:0F:9E:B8:FC:64:8A:4A:90:72:0E:05:E7:94:CC:0D`

2. **Google Cloud Console에서 Android OAuth 클라이언트 생성**
   - [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → Credentials
   - "+ CREATE CREDENTIALS" → "OAuth 2.0 Client IDs"
   - Application type: **Android**
   - Package name: `com.lifetime_ledger_seonho.lifetime_ledger`
   - SHA-1 certificate fingerprint: 위에서 확인한 지문

3. **google-services.json 파일 업데이트**
   - Firebase Console → 프로젝트 설정 → 일반 → google-services.json 다운로드
   - `android/app/google-services.json` 교체

4. **올바른 OAuth 클라이언트 확인**
```json
{
  "oauth_client": [
    {
      "client_id": "572681652958-iotlmkp9ao4dasc6ocpmiih6g3a752is.apps.googleusercontent.com",
      "client_type": 1  // Android 클라이언트
    },
    {
      "client_id": "572681652958-peba8e4ova5g5ufjmfjbbr1ptofa0hvm.apps.googleusercontent.com",
      "client_type": 3  // 웹 클라이언트
    }
  ]
}
```

### ❌ 문제 2: SecurityException: Unknown calling package name

**증상:**
```
E/GoogleApiManager: java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'.
```

**원인:** OAuth 클라이언트 설정 불일치

**해결책:**
- 위의 ApiException: 10 해결책과 동일
- 패키지명과 SHA-1 지문이 정확히 일치하는지 재확인

### ❌ 문제 3: iOS CocoaPods 동기화 오류

**증상:**
```
The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.
```

**해결책:**
```bash
cd ios && pod install
flutter clean
```

### ❌ 문제 4: iOS URL Scheme 설정 누락

**해결책:**
`ios/Runner/Info.plist`에 다음 추가:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>GOOGLE_SIGN_IN</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.572681652958-m0phm6l9f6inst6cbvr439lhi8csssrm</string>
        </array>
    </dict>
</array>
```

## 단계별 구현 가이드

### 1. Provider 설정
```dart
// main.dart
List<SingleChildWidget> _buildCoreProviders() {
  return [
    Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
    Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
    Provider<GoogleSignIn>(create: (_) => GoogleSignIn()),
  ];
}
```

### 2. DataSource 구현
```dart
// auth_firebase_datasource_impl.dart
@override
Future<String> signInWithGoogle() async {
  try {
    print('🔍 Google 로그인 시작');

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      print('❌ 사용자가 Google 로그인을 취소함');
      throw ValidationException('Google 로그인이 취소되었습니다');
    }

    print('✅ Google 사용자 정보 획득: ${googleUser.email}');

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.user == null) {
      throw ServerException('Google 로그인에 실패했습니다');
    }

    print('✅ Firebase Google 로그인 성공: ${userCredential.user!.uid}');
    return userCredential.user!.uid;
  } catch (e) {
    print('❌ Google 로그인 오류: $e');
    throw ServerException('Google 로그인 중 오류가 발생했습니다: $e');
  }
}
```

### 3. UseCase 구현
```dart
// google_signin_usecase.dart
class GoogleSignInUseCase {
  final AuthRepository _authRepository;

  GoogleSignInUseCase({required AuthRepository authRepository})
      : _authRepository = authRepository;

  Future<String> call() async {
    return await _authRepository.signInWithGoogle();
  }
}
```

### 4. ViewModel 연결
```dart
// signin_viewmodel.dart
Future<void> signInWithGoogle() async {
  try {
    setLoading(true);
    final uid = await _googleSignInUseCase.call();
    // 성공 처리
  } catch (e) {
    setError('Google 로그인에 실패했습니다: $e');
  } finally {
    setLoading(false);
  }
}
```

### 5. 로그인 화면 UI 구현
```dart
// signin_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignInViewModel>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 로그인 버튼
            OutlinedButton.icon(
              onPressed: viewModel.isLoading
                  ? null
                  : () => viewModel.signInWithGoogle(),
              icon: Image.asset(
                'assets/images/google_logo.png',
                height: 24,
              ),
              label: const Text(
                'Google로 계속하기',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            if (viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),

            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 6. 로그인 상태 관리
```dart
// auth_state_manager.dart
class AuthStateManager extends ChangeNotifier {
  User? _user;
  StreamSubscription? _authSubscription;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthStateManager() {
    // Firebase Auth 상태 변화 감지
    _authSubscription = FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
```

## 검증 방법

### 1. SHA-1 지문 확인
```bash
cd android && ./gradlew signingReport
```

### 2. OAuth 클라이언트 확인
google-services.json에서 `client_type: 1` (Android) 존재 확인

### 3. 실제 기기 테스트
- ✅ Android 실기기 (Galaxy 등)
- ✅ iOS 실기기 (iPhone)

### 4. 로그 확인
성공 시 예상 로그:
```
I/flutter: 🔍 Google 로그인 시작
I/flutter: ✅ Google 사용자 정보 획득: user@example.com
I/flutter: ✅ Firebase Google 로그인 성공: [uid]
```

## 주의사항

### 에뮬레이터 vs 실기기
- **Android 에뮬레이터**: Google Play Services 이슈로 실패할 수 있음
- **실제 기기**: Galaxy, iPhone 모두 정상 동작 확인됨

### 클라이언트 ID 직접 설정 금지
```dart
// ❌ 잘못된 방법
Provider<GoogleSignIn>(create: (_) => GoogleSignIn(
  clientId: 'manual-client-id', // 이렇게 하지 마세요
)),

// ✅ 올바른 방법
Provider<GoogleSignIn>(create: (_) => GoogleSignIn()), // google-services.json 자동 사용
```

### Firebase와 Google Cloud 관계
- Firebase 프로젝트 생성 시 Google Cloud 프로젝트 자동 생성
- OAuth 클라이언트는 Google Cloud Console에서 별도 생성 필요

## 트러블슈팅 체크리스트

Google Sign-In 문제 발생 시 다음 순서로 확인:

1. [ ] SHA-1 지문이 Google Cloud Console에 등록되어 있는가?
2. [ ] Android OAuth 클라이언트 ID가 생성되어 있는가?
3. [ ] google-services.json에 `client_type: 1`이 포함되어 있는가?
4. [ ] 패키지명이 정확히 일치하는가?
5. [ ] iOS URL Scheme이 설정되어 있는가?
6. [ ] CocoaPods가 최신 상태인가?
7. [ ] 실제 기기에서 테스트하고 있는가?

---

이 가이드로 Google Sign-In 문제를 해결할 수 있습니다. 추가 문제 발생 시 이 문서를 참조하여 체계적으로 해결하세요.