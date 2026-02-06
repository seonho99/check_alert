# 🧱 상태 클래스 (State) 설계 가이드 (Clean Architecture + Freezed 3.0)

---

## ✅ 목적

State 클래스는 **Clean Architecture Presentation Layer**에서 화면에 필요한 모든 상태 값을 하나의 **Freezed 3.0 불변 객체**로 표현합니다.  
UI는 **ViewModel** (ChangeNotifier)을 통해 이 상태 객체를 **Consumer/Selector**로 구독하여 렌더링하며,  
ViewModel은 **Result<T> 패턴**을 통해 상태를 생성하고 변경합니다.

현재 구조: **Auth**, **[Feature]** 등 다중 기능에 완전한 클린 아키텍처를 적용

---

## 🧱 설계 원칙

- 상태는 화면에 필요한 데이터만 포함한 **최소 단위의 객체**로 설계한다.
- `@freezed`를 사용하여 불변 객체로 정의하고,  
  **Freezed 3.0 방식**으로 작성한다. (일반 class + 일반 생성자)
- 상태는 직접 관리하지 않고,  
  **각 필드는 적절한 타입으로 관리**한다. (loading, error 상태 포함)
- 상태 객체 자체는 단순한 데이터 집합이며, 비즈니스 로직은 포함하지 않는다.

---

## ✅ 파일 구조 및 위치

```text
lib/features/
├── auth/ui/state.dart                 # AuthState
└── [feature]/ui/state.dart            # [Feature]State
```

---

## ✅ 작성 규칙 및 구성

| 항목 | 규칙 |
|:---|:---|
| 어노테이션 | `@freezed` 사용 |
| 생성자 | Freezed 3.0 방식: 일반 class + 일반 생성자 |
| 상태 값 | 모든 필드는 nullable 또는 기본값 제공 |
| 로딩/에러 | boolean 필드와 errorMessage로 관리 |

---

## ✅ 기본 State 예시 (실제 구현)

### SignIn State (실제 프로젝트 예시)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_state.freezed.dart';

/// SignIn 화면 상태 (Freezed 3.0 방식)
@freezed
class SignInState with _$SignInState {
  const SignInState({
    required this.email,
    required this.password,
    required this.isLoading,
    required this.obscurePassword,
    this.errorMessage,
    this.successMessage,
    this.isLoginSuccess = false,
    this.isAlreadyAuthenticated = false,
    this.shouldNavigateToHistory = false,
  });

  // ✅ 모든 필드에 @override 어노테이션 (Freezed 3.0 요구사항)
  @override
  final String email;
  @override
  final String password;
  @override
  final bool isLoading;
  @override
  final bool obscurePassword;
  @override
  final String? errorMessage;
  @override
  final String? successMessage;
  @override
  final bool isLoginSuccess;
  @override
  final bool isAlreadyAuthenticated;
  @override
  final bool shouldNavigateToHistory;

  /// 초기 상태
  factory SignInState.initial() {
    return SignInState(
      email: '',
      password: '',
      isLoading: false,
      obscurePassword: true,
      errorMessage: null,
      successMessage: null,
      isLoginSuccess: false,
      isAlreadyAuthenticated: false,
      shouldNavigateToHistory: false,
    );
  }

  /// 로딩 상태
  factory SignInState.loading() {
    return SignInState(
      email: '',
      password: '',
      isLoading: true,
      obscurePassword: true,
    );
  }

  // ========================================
  // 계산된 속성 (Computed Properties)
  // ========================================

  /// 폼 유효성 검증
  bool get isValid =>
      email.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      _isValidEmail(email.trim());

  /// 에러 상태 확인
  bool get hasError => errorMessage != null;

  /// 성공 상태 확인
  bool get hasSuccess => successMessage != null;

  /// 이메일 형식 검증
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
```

---

## ✅ 요약

- **Freezed 3.0**: 일반 class + 일반 생성자
- **@override 필수**: 모든 필드에 `@override` 어노테이션 추가
- **최소 데이터**: 화면에 필요한 필수 상태만 포함
- **불변 객체**: 자동 생성되는 copyWith, ==, hashCode
- **Factory 메서드**: `initial()`, `loading()` 제공
- **Computed Properties**: `isValid`, `hasError` 등 계산된 속성

---