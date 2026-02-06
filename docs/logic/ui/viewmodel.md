# 🧩 ViewModel 설계 가이드 (Clean Architecture + MVVM + Provider + Freezed 3.0)

---

## ✅ 목적

ViewModel은 **Clean Architecture Presentation Layer**에서 앱의 상태를 보존하고, 사용자 액션을 처리하는  
**상태 관리 계층**입니다.

이 프로젝트에서는 **ChangeNotifier**를 기반으로  
**Freezed 3.0 State**를 일관성 있게 관리하며,  
**Provider 패턴**을 통해 UI와 연결되고, **Result<T> 패턴**으로 UseCase 결과를 처리합니다.

현재 구조: **Auth**, **[Feature]** 등 다중 기능에 완전한 클린 아키텍처를 적용

---

## 📚 MVVM 아키텍처에서의 역할

- **Model**: **Freezed 3.0 Entity**, UseCase, Repository
- **View**: Screen, Widget (Consumer/Selector 사용)
- **ViewModel**: **Freezed 3.0 State** 관리, UseCase 호출, UI 로직 처리

ViewModel은 View와 Model 사이의 중재자 역할을 수행하며,
**Result<T> 패턴**으로 UseCase 결과를 처리하고 **Freezed State**를 업데이트하여 UI 상태 관리를 담당합니다.

---

# ⚙️ 기본 구조 예시

```dart
class SignInViewModel extends ChangeNotifier {
  final SignInUseCase _signInUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  // ✅ 컨트롤러와 폼 키를 ViewModel에서 관리
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  SignInViewModel({
    required SignInUseCase signInUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _signInUseCase = signInUseCase,
       _googleSignInUseCase = googleSignInUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase {
    // 컨트롤러 리스너 등록
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onEmailChanged() {
    onEmailChanged(emailController.text);
  }

  void _onPasswordChanged() {
    onPasswordChanged(passwordController.text);
  }

  // ========================================
  // 상태 관리
  // ========================================

  SignInState _state = SignInState.initial();
  SignInState get state => _state;

  // 편의 Getters
  String get email => _state.email;
  String get password => _state.password;
  bool get isLoading => _state.isLoading;
  bool get hasError => _state.hasError;
  String? get errorMessage => _state.errorMessage;
  bool get isValid => _state.isValid;

  /// 상태 업데이트
  void _updateState(SignInState newState) {
    _state = newState;
    notifyListeners();
  }

  // ========================================
  // UI 이벤트 처리
  // ========================================

  /// 이메일 입력 변경
  void onEmailChanged(String email) {
    _updateState(_state.copyWith(
      email: email,
      errorMessage: null, // 입력 시 에러 초기화
    ));
  }

  /// 비밀번호 입력 변경
  void onPasswordChanged(String password) {
    _updateState(_state.copyWith(
      password: password,
      errorMessage: null,
    ));
  }

  /// 에러 메시지 초기화
  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }

  // ========================================
  // 비즈니스 로직 - result.when() 패턴
  // ========================================

  /// 로그인 실행
  Future<void> signIn() async {
    if (!_state.isValid) {
      _updateState(_state.copyWith(
        errorMessage: '이메일과 비밀번호를 올바르게 입력해주세요',
      ));
      return;
    }

    // 로딩 시작
    _updateState(_state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    try {
      final result = await _signInUseCase(
        email: _state.email.trim(),
        password: _state.password,
      );

      // ✅ result.when() 패턴으로 성공/실패 처리
      result.when(
        success: (user) {
          _updateState(_state.copyWith(
            isLoading: false,
            isLoginSuccess: true,
            successMessage: '로그인 성공! 환영합니다, ${user.displayName ?? user.email}',
          ));
        },
        error: (failure) {
          _updateState(_state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          ));
        },
      );
    } catch (e) {
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다: ${e.toString()}',
      ));
    }
  }

  /// Failure를 사용자 친화적 메시지로 변환
  String _getErrorMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return '인터넷 연결을 확인해주세요';
    } else if (failure is UnauthorizedFailure) {
      return '이메일 또는 비밀번호가 올바르지 않습니다';
    } else if (failure is FirebaseFailure) {
      return _translateFirebaseError(failure.message);
    } else {
      return '오류가 발생했습니다: ${failure.message}';
    }
  }

  /// Firebase Auth 에러 메시지를 한국어로 번역
  String _translateFirebaseError(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();

    if (lowerMessage.contains('user-not-found')) {
      return '등록되지 않은 이메일입니다';
    } else if (lowerMessage.contains('wrong-password')) {
      return '비밀번호가 올바르지 않습니다';
    } else if (lowerMessage.contains('invalid-email')) {
      return '유효하지 않은 이메일 형식입니다';
    } else if (lowerMessage.contains('too-many-requests')) {
      return '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요';
    } else {
      return '인증 오류가 발생했습니다: $errorMessage';
    }
  }

  // ========================================
  // 생명주기 관리
  // ========================================

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    passwordController.removeListener(_onPasswordChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
```

✅ `ChangeNotifier`를 상속하여 상태 변경을 UI에 알립니다.
✅ **TextEditingController를 ViewModel에서 관리**하여 View를 단순화합니다.
✅ 생성자에서 UseCase들을 주입받습니다.
✅ **result.when() 패턴**으로 Result의 성공/실패를 명확히 처리합니다.
✅ **dispose()에서 컨트롤러를 정리**합니다.

---

# 🏗️ 파일 구조 및 명명 규칙

```text
lib/features/
├── auth/ui/
│   ├── viewmodel.dart                # AuthViewModel
│   └── state.dart                    # AuthState (Freezed 3.0)
└── [feature]/ui/
    ├── viewmodel.dart                # [Feature]ViewModel
    └── state.dart                    # [Feature]State (Freezed 3.0)
```

| 항목 | 규칙 |
|:---|:---|
| 파일 경로 | `lib/features/{기능}/ui/` |
| 파일명 | `viewmodel.dart` |
| 클래스명 | `{기능}ViewModel` |

---

# 🔥 ViewModel 초기화 패턴

## ✅ 생성자에서 컨트롤러 리스너 등록

```dart
class SignInViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInViewModel({
    required SignInUseCase signInUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _signInUseCase = signInUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase {
    // ✅ 생성자 본문에서 리스너 등록
    emailController.addListener(_onEmailChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  SignInState _state = SignInState.initial();

  /// 인증 상태 체크 (앱 시작 시)
  Future<void> checkAuthenticationState() async {
    if (_getCurrentUserUseCase.isSignedIn) {
      final result = await _getCurrentUserUseCase.call();
      result.when(
        success: (userModel) {
          _updateState(_state.copyWith(
            isAlreadyAuthenticated: true,
            shouldNavigateToHistory: true,
          ));
        },
        error: (failure) {
          _updateState(_state.copyWith(
            isAlreadyAuthenticated: false,
          ));
        },
      );
    }
  }
}
```

## ✅ View에서 ViewModel 사용 (중앙 Provider 방식)

```dart
// ✅ 권장: main.dart의 MultiProvider에서 전역 등록
// viewmodel_providers.dart에서 설정 후 View에서 Consumer로 구독

class SignInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignInViewModel>(
      builder: (context, viewModel, child) {
        // View에서는 viewModel의 컨트롤러 직접 사용
        return Form(
          key: viewModel.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: viewModel.emailController,
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              TextFormField(
                controller: viewModel.passwordController,
                obscureText: viewModel.obscurePassword,
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

# 👁️ UI에서 ViewModel 사용

## ✅ Consumer 패턴

```dart
class AuthView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.hasError) {
          return ErrorWidget(message: viewModel.errorMessage!);
        }

        if (viewModel.isLoading) {
          return const LoadingWidget();
        }

        if (viewModel.isAuthenticated) {
          return HomeView(user: viewModel.currentUser!);
        }

        return const LoginForm();
      },
    );
  }
}
```

## ✅ Selector 패턴 (성능 최적화)

```dart
// 특정 상태만 구독
Selector<AuthViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)

// 복합 상태 구독
Selector<AuthViewModel, ({bool isAuthenticated, String? userName})>(
  selector: (context, viewModel) => (
    isAuthenticated: viewModel.isAuthenticated,
    userName: viewModel.currentUser?.name,
  ),
  builder: (context, data, child) {
    return Text(
      data.isAuthenticated
        ? '환영합니다, ${data.userName}님!'
        : '로그인이 필요합니다'
    );
  },
)
```

---

# 🧩 책임 구분

| 계층 | 역할 |
|:---|:---|
| **State** | UI에 필요한 최소한의 데이터 구조 (immutable, freezed 사용) |
| **ViewModel** | 상태를 보관하고, UseCase를 호출하여 상태를 변경 |
| **UseCase** | 비즈니스 로직 실행 (Repository 접근 포함) |
| **View** | ChangeNotifierProvider 설정, ViewModel 주입, Consumer로 상태 구독 및 UI 렌더링 |

---

# ✅ result.when() 패턴

> UseCase 결과를 success/error 콜백으로 처리

### 기본 패턴

```dart
class [Feature]ViewModel extends ChangeNotifier {
  /// 저장 실행
  Future<void> save() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _saveUseCase(data: _state.data);

    // ✅ result.when() 패턴
    result.when(
      success: (data) {
        _updateState(_state.copyWith(
          isLoading: false,
          isSaved: true,
          successMessage: '저장되었습니다',
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  /// 삭제 실행
  Future<void> delete(String id) async {
    _updateState(_state.copyWith(isLoading: true));

    final result = await _deleteUseCase(id: id);

    result.when(
      success: (_) {
        _updateState(_state.copyWith(isLoading: false));
        // 목록 새로고침 등 추가 작업
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        ));
      },
    );
  }

  void clearError() {
    _updateState(_state.copyWith(errorMessage: null));
  }
}
```

### View에서 ViewModel 메서드 호출

```dart
// ✅ context.read로 메서드 호출
ElevatedButton(
  onPressed: () => context.read<[Feature]ViewModel>().save(),
  child: const Text('저장'),
)

// ✅ 파라미터 전달
IconButton(
  onPressed: () => context.read<[Feature]ViewModel>().delete(item.id),
  icon: const Icon(Icons.delete),
)
```

### 메서드 네이밍 규칙

| 액션 | 메서드 이름 |
|------|-------------|
| 저장 | `save()` |
| 삭제 | `delete(id)` |
| 새로고침 | `refresh()` |
| 로그인 | `signIn()` |
| 제출 | `submit()` |

---

# ✅ 문서 요약

- ViewModel은 **ChangeNotifier**를 상속하여 상태를 관리합니다.
- **TextEditingController를 ViewModel에서 관리**하여 View를 단순화합니다.
- 생성자에서 UseCase들을 주입받아 비즈니스 로직을 실행합니다.
- **Freezed State** 객체로 불변 상태를 관리합니다.
- **result.when() 패턴**으로 Result<T>의 성공/실패를 콜백으로 처리합니다.
- **dispose()에서 컨트롤러 정리**: 리스너 제거 및 dispose 호출 필수.
- Consumer/Selector 패턴으로 UI에서 상태를 효율적으로 구독합니다.
- Failure 타입에 따른 **사용자 친화적 에러 메시지** 변환.

---