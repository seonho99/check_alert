# ⚙️ UseCase 설계 가이드 (Auth 중심 비즈니스 로직)

> **참조**: [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide) - Domain Layer는 복잡한 비즈니스 로직이 있을 때 선택적으로 사용

---

## ✅ 목적

UseCase는 하나의 명확한 **비즈니스 동작**을 수행하는 단위입니다.
단순한 Repository 호출을 넘어서 **입력값 검증**, **비즈니스 규칙 적용**, **보안 로직 처리** 등
**실제 도메인 요구사항**을 구현하는 핵심 계층입니다.

> **Template Guide**: [Feature] 부분을 실제 기능명으로 대체하여 사용하세요.
> 예: SignUp, Login, [Feature]Profile → UserProfile

---

## 🧱 설계 원칙

- **단일 책임**: 하나의 UseCase는 하나의 비즈니스 목적만 수행
- **비즈니스 로직 중심**: 도메인 요구사항과 비즈니스 규칙을 구현
- **입력값 검증**: 모든 외부 입력에 대한 철저한 검증
- **Result<T> 반환**: 타입 안전한 성공/실패 처리
- **Repository 의존**: 데이터 접근은 Repository를 통해서만

---

## ✅ 파일 구조 및 위치

```text
lib/domain/usecase/
├── [feature]_usecase.dart             # [Feature] 관련 비즈니스 로직
│
└── 🔐 Auth UseCases
    └── signup_usecase.dart            # 회원가입 (주요 예시)
```

---

## 🔥 실제 구현된 UseCase 예시

### 1. 기본 UseCase 템플릿

#### [Feature]UseCase (템플릿)

```dart
class [Feature]UseCase {
  final [Feature]Repository _repository;

  [Feature]UseCase({
    required [Feature]Repository repository,
  }) : _repository = repository;

  Future<Result<[ReturnType]>> call([Parameters]) async {
    // 🔍 비즈니스 로직: 입력값 검증
    if ([validation_condition]) {
      return Error(ValidationFailure('[validation_message]'));
    }

    // 🔍 비즈니스 규칙 적용
    // 추가적인 비즈니스 로직 구현

    return await _repository.[method_name]([parameters]);
  }
}
```

### 2. 실제 구현: SignUpUseCase (Auth 중심 예시)

```dart
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Result<UserModel>> call({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    // 🔍 필수 입력값 검증
    if (email.trim().isEmpty) {
      return Error(ValidationFailure('이메일을 입력해주세요'));
    }
    if (password.trim().isEmpty) {
      return Error(ValidationFailure('비밀번호를 입력해주세요'));
    }

    // 🔍 이메일 형식 검증
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // 🔍 비밀번호 검증
    if (password.length < 6) {
      return Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
    }
    if (password != confirmPassword) {
      return Error(ValidationFailure('비밀번호가 일치하지 않습니다'));
    }

    try {
      return await _repository.signUpWithEmailAndPassword(
        email: email.trim(),
        password: password,
        displayName: displayName?.trim(),
      );
    } catch (e) {
      return Error(ServerFailure('회원가입 중 오류가 발생했습니다: $e'));
    }
  }
}
```

## 🔄 UseCase 조합 패턴

### 1. ViewModel에서의 Auth UseCase 조합

```dart
class AuthViewModel extends ChangeNotifier {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;

  // 🔍 복합 비즈니스 로직: 회원가입 후 자동 로그인
  Future<void> signUpAndSignIn({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    // 1단계: 회원가입
    final signUpResult = await _signUpUseCase(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      displayName: displayName,
    );

    if (signUpResult.isSuccess) {
      // 2단계: 자동 로그인
      await signIn(email: email, password: password);
    } else {
      _updateState(_state.copyWith(
        errorMessage: signUpResult.failure?.message,
      ));
    }
  }
}
```

## 📋 UseCase 복잡도별 분류

### 🟢 Level 1: 단순 Repository 호출
- `SignOutUseCase`
- `GetCurrentUserUseCase`
- `Simple[Feature]UseCase`

### 🟡 Level 2: 기본 검증 포함
- `[Feature]UseCase` - 도메인 객체 검증
- `Get[Feature]ByIdUseCase` - ID 검증
- `Delete[Feature]UseCase` - 권한 검증

### 🟠 Level 3: 복합 검증 및 변환
- `SignInUseCase` - 이메일 형식 검증
- `SendPasswordResetEmailUseCase` - 이메일 검증
- `UpdateProfileUseCase` - 입력값 형식 검증

### 🔴 Level 4: 복잡한 비즈니스 규칙 (주요 예시)
- `SignUpUseCase` - 다중 검증 + 보안 규칙
- `ChangePasswordUseCase` - 보안 비즈니스 규칙
- `DeleteAccountUseCase` - 극강 보안 검증

### 🟣 Level 5: 다중 Repository 조합
- `Complex[Feature]UseCase` - 다중 Repository 연동
- `[Feature]WithAuthUseCase` - 인증 + 비즈니스 로직 조합

---

## ✅ UseCase 설계 베스트 프랙티스

### 🔒 Auth 중심 원칙 (SignUpUseCase 기반)
1. **철저한 입력값 검증**: 모든 외부 입력에 대한 검증 로직 포함
2. **보안 우선**: 인증 관련 UseCase는 특히 엄격한 검증
3. **에러 메시지 명확화**: 사용자가 이해하기 쉬운 에러 메시지
4. **예외 처리**: try-catch와 Result<T> 패턴 조합
5. **정규식 활용**: 이메일, 비밀번호 등의 형식 검증
6. **비즈니스 규칙 구현**: 단순 검증을 넘어선 도메인 규칙 적용

### 🏗️ 템플릿 활용법
1. **[Feature] 대체**: 실제 기능명으로 대체 (예: User, Product, Order)
2. **Parameter 정의**: 필요한 입력 매개변수 정의
3. **검증 로직 추가**: 해당 도메인에 맞는 검증 규칙 구현
4. **Repository 연동**: 적절한 Repository 메서드 호출
5. **테스트 작성**: 비즈니스 로직 중심의 단위 테스트

### 🎯 구현 가이드라인
- **Auth UseCases**: 보안을 최우선으로 검증 로직 강화
- **CRUD UseCases**: 기본적인 입력값 검증 및 권한 확인
- **Complex UseCases**: 다중 Repository 조합 시 트랜잭션 고려

---

이 문서는 **실제 구현된 SignUpUseCase**를 중심으로 Auth 도메인의 비즈니스 로직 패턴을 템플릿화하여 작성되었습니다.