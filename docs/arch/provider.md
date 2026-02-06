# 🧩 Provider 중앙 집중식 가이드

---

## ✅ 목적

**모든 Provider를 중앙 집중식으로 관리**하여 의존성 주입을 체계화합니다.

---

## ✅ 설계 원칙

- **core/di/ 폴더로 분리**: Provider 구성을 파일별로 체계적 분리
- **View는 Consumer만**: View에서는 Provider 설정 없이 Consumer로만 구독
- **의존성 순서**: DataSource → Repository → UseCase → ViewModel
- **싱글톤 관리**: 앱 전체에서 하나의 ViewModel 인스턴스 공유

---

## ✅ 실제 구현: Provider 분리 구조

### 폴더 구조

```
lib/core/di/
├── core_providers.dart        # Firebase, 기본 서비스
├── data_providers.dart        # DataSource 계층
├── domain_providers.dart      # Repository, UseCase 계층
└── viewmodel_providers.dart   # ViewModel 계층
```

### core_providers.dart

```dart
// core/di/core_providers.dart
List<Provider> buildCoreProviders() {
  return [
    Provider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
    Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
    Provider<FirebaseStorage>(create: (_) => FirebaseStorage.instance),
  ];
}
```

### data_providers.dart

```dart
// core/di/data_providers.dart
List<Provider> buildDataProviders() {
  return [
    Provider<AuthDataSource>(
      create: (context) => AuthFirebaseDataSourceImpl(
        auth: context.read<FirebaseAuth>(),
      ),
    ),
    Provider<[Feature]DataSource>(
      create: (context) => [Feature]FirebaseDataSourceImpl(
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),
  ];
}
```

### domain_providers.dart

```dart
// core/di/domain_providers.dart
List<Provider> buildDomainProviders() {
  return [
    // Repositories
    Provider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        dataSource: context.read<AuthDataSource>(),
      ),
    ),

    // UseCases
    Provider<SignInUseCase>(
      create: (context) => SignInUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
  ];
}
```

### viewmodel_providers.dart

```dart
// core/di/viewmodel_providers.dart
List<ChangeNotifierProvider> buildViewModelProviders() {
  return [
    ChangeNotifierProvider<AuthViewModel>(
      create: (context) => AuthViewModel(
        signInUseCase: context.read<SignInUseCase>(),
        signUpUseCase: context.read<SignUpUseCase>(),
      ),
    ),
  ];
}
```

### main.dart에서 통합

```dart
// main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...buildCoreProviders(),
        ...buildDataProviders(),
        ...buildDomainProviders(),
        ...buildViewModelProviders(),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

---

## 🏗️ 기본 구조

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LifetimeLedgerApp());
}

class LifetimeLedgerApp extends StatelessWidget {
  const LifetimeLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ..._buildDataSources(),
        ..._buildRepositories(),
        ..._buildUseCases(),
        ..._buildViewModels(),
      ],
      child: MaterialApp.router(
        title: 'Lifetime Ledger',
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

---

## 🗂️ 폴더 구조 예시

### Auth 기능
```
lib/features/auth/
├── data/
│   ├── datasource/
│   │   └── auth_firebase_datasource.dart
│   ├── dto/
│   │   └── auth_dto.dart
│   ├── mapper/
│   │   └── auth_mapper.dart
│   └── repository_impl/
│       └── auth_repository_impl.dart
├── domain/
│   ├── model/
│   │   └── auth.dart
│   ├── repository/
│   │   └── auth_repository.dart
│   └── usecase/
│       ├── sign_in_usecase.dart
│       ├── sign_up_usecase.dart
│       └── sign_out_usecase.dart
└── ui/
    ├── auth_viewmodel.dart
    ├── auth_state.dart
    └── auth_view.dart
```

### [Feature] 기능 템플릿
```
lib/features/[feature]/
├── data/
│   ├── datasource/
│   │   └── [feature]_firebase_datasource.dart
│   ├── dto/
│   │   └── [feature]_dto.dart
│   ├── mapper/
│   │   └── [feature]_mapper.dart
│   └── repository_impl/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── model/
│   │   └── [feature].dart
│   ├── repository/
│   │   └── [feature]_repository.dart
│   └── usecase/
│       ├── get_[feature]s_usecase.dart
│       ├── add_[feature]_usecase.dart
│       ├── update_[feature]_usecase.dart
│       └── delete_[feature]_usecase.dart
└── ui/
    ├── [feature]_viewmodel.dart
    ├── [feature]_state.dart
    └── [feature]_view.dart
```

---

## 🔧 의존성 주입 함수들

### DataSources
```dart
List<Provider> _buildDataSources() {
  return [
    Provider<AuthFirebaseDataSource>(
      create: (_) => AuthFirebaseDataSourceImpl(
        auth: FirebaseAuth.instance,
      ),
    ),
    Provider<[Feature]FirebaseDataSource>(
      create: (_) => [Feature]FirebaseDataSourceImpl(
        firestore: FirebaseFirestore.instance,
      ),
    ),
  ];
}
```

### Repositories
```dart
List<Provider> _buildRepositories() {
  return [
    Provider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        dataSource: context.read<AuthFirebaseDataSource>(),
      ),
    ),
    Provider<[Feature]Repository>(
      create: (context) => [Feature]RepositoryImpl(
        dataSource: context.read<[Feature]FirebaseDataSource>(),
      ),
    ),
  ];
}
```

### UseCases
```dart
List<Provider> _buildUseCases() {
  return [
    // Auth UseCases
    Provider(
      create: (context) => SignInUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
    Provider(
      create: (context) => SignUpUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),

    // [Feature] UseCases
    Provider(
      create: (context) => Get[Feature]sUseCase(
        repository: context.read<[Feature]Repository>(),
      ),
    ),
    Provider(
      create: (context) => Add[Feature]UseCase(
        repository: context.read<[Feature]Repository>(),
      ),
    ),
  ];
}
```

### ViewModels
```dart
List<ChangeNotifierProvider> _buildViewModels() {
  return [
    ChangeNotifierProvider(
      create: (context) => AuthViewModel(
        signInUseCase: context.read<SignInUseCase>(),
        signUpUseCase: context.read<SignUpUseCase>(),
        signOutUseCase: context.read<SignOutUseCase>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => [Feature]ViewModel(
        get[Feature]sUseCase: context.read<Get[Feature]sUseCase>(),
        add[Feature]UseCase: context.read<Add[Feature]UseCase>(),
      ),
    ),
  ];
}
```

---

## 🖥️ View 사용 패턴

### Auth View 예시
```dart
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (viewModel.isAuthenticated) {
            return _buildAuthenticatedView();
          }

          return _buildAuthForm();
        },
      ),
    );
  }

  Widget _buildAuthForm() {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '이메일'),
              onChanged: viewModel.setEmail,
            ),
            TextField(
              decoration: const InputDecoration(labelText: '비밀번호'),
              obscureText: true,
              onChanged: viewModel.setPassword,
            ),
            ElevatedButton(
              onPressed: viewModel.canSignIn ? () => viewModel.signIn() : null,
              child: const Text('로그인'),
            ),
          ],
        );
      },
    );
  }
}
```

### [Feature] View 템플릿
```dart
class [Feature]View extends StatelessWidget {
  const [Feature]View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('[Feature]')),
      body: Consumer<[Feature]ViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (viewModel.hasError) {
            return _buildErrorState(viewModel.errorMessage);
          }

          return _buildSuccessState(viewModel.data);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message ?? '오류가 발생했습니다'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<[Feature]ViewModel>().retry(),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(dynamic data) {
    return Container(); // 실제 UI 구현
  }
}
```

---

## 🔄 데이터 흐름

```
main.dart MultiProvider 설정
    ↓
모든 Provider 싱글톤으로 생성
    ↓
View에서 Consumer로 ViewModel 구독
    ↓
User Event → ViewModel → UseCase → Repository → DataSource
    ↓
DataSource → Repository → UseCase → ViewModel
    ↓
State 업데이트 → notifyListeners()
    ↓
Consumer 자동 리빌드
```

---

## ✅ 장점

### 1. **중앙 집중식 관리**
- 모든 Provider가 main.dart에 집중
- 의존성 흐름이 한눈에 보임
- 수정이 필요할 때 한 곳에서 관리

### 2. **싱글톤 보장**
- 앱 전체에서 하나의 ViewModel 인스턴스 공유
- 메모리 효율성 극대화
- 상태 일관성 유지

### 3. **View 단순화**
- View는 Consumer만 사용
- Provider 설정 코드 불필요
- UI 로직에만 집중 가능

### 4. **테스트 용이성**
- main.dart에서 Provider Override 쉬움
- 각 레이어별 독립 테스트 가능
- Mock 객체 주입 간편

---

## 📌 핵심 요약

- **main.dart에서 모든 Provider 중앙 관리**
- **View는 Consumer로만 상태 구독**
- **의존성 순서**: DataSource → Repository → UseCase → ViewModel
- **싱글톤 패턴**으로 메모리 효율성 극대화
- **Auth와 [Feature] 템플릿**으로 일관된 구조 유지

---