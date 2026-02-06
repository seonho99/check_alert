# 🛣️ 라우팅 (Route) 설계 가이드

> **참조**: [Flutter Navigation](https://docs.flutter.dev/ui/navigation) | [go_router package](https://pub.dev/packages/go_router)

---

## ✅ 목적

- **GoRouter**를 통해 앱의 전체 라우팅 경로를 설정하고 관리합니다. (Flutter 공식 권장)
- 각 경로는 특정 View와 1:1로 매핑됩니다.
- 라우팅 계층은 네비게이션 로직에만 집중하며, 비즈니스 로직(상태 관리, 인증 확인 등)은 ViewModel과 GoRouter의 `redirect` 기능에 위임합니다.
- **main.dart 중앙 집중식 + Clean Architecture + MVVM** 패턴과 자연스럽게 연동되도록 설계합니다.

---

## 🧱 설계 원칙

- **중앙 관리**: 모든 라우팅 규칙은 `lib/core/route/router.dart` 파일에서 중앙 관리합니다.
- **역할 분리**:
    - **Router**: 경로와 View를 매핑하는 역할만 수행합니다.
    - **main.dart**: 모든 Provider를 중앙에서 설정하고 의존성을 주입합니다.
    - **View**: Consumer로 상태를 구독하고 실제 UI를 렌더링합니다.
    - **ViewModel**: UseCase를 통해 비즈니스 로직을 실행하고, State를 업데이트하며, 네비게이션 메서드를 제공합니다.
    - **State**: Freezed 기반 불변 상태 객체로 UI 상태를 정의합니다.
- **네비게이션 추상화**: ViewModel에서 `NavigationMixin`을 사용하여 `BuildContext`에 대한 의존성 없이 화면 이동을 처리합니다.

---

## ✅ 파일 구조 및 위치

```
lib/
├── core/
│   └── route/
│       ├── router.dart              # GoRouter 설정 (모든 경로 정의)
│       └── routes.dart              # 라우트 경로 상수 정의 (선택 사항)
│
├── ui/
│   └── {기능}/
│       ├── {기능}_viewmodel.dart    # ChangeNotifier 기반 상태 관리
│       ├── {기능}_state.dart        # Freezed 기반 불변 상태 객체
│       └── {기능}_view.dart         # Consumer를 통한 UI 렌더링
│
└── main.dart                        # 앱 진입점, 모든 Provider 중앙 설정, GoRouter 설정 적용
```

---

## ✅ 기본 라우터 설정

### lib/core/route/router.dart

```dart
final router = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/[feature]',
      builder: (context, state) => const [Feature]View(),
    ),
  ],
);
```

### main.dart에서 라우터 적용

```dart
class LifetimeLedgerApp extends StatelessWidget {
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
        routerConfig: router,
      ),
    );
  }
}
```

---


## 🔒 인증 및 라우트 가드

`GoRouter`의 `redirect` 기능을 사용하여 인증 상태에 따라 사용자를 다른 페이지로 보냅니다.

```dart
final router = GoRouter(
  redirect: (context, state) {
    // Provider에서 AuthViewModel 인증 상태 확인
    final authViewModel = context.read<AuthViewModel>();
    final isLoggedIn = authViewModel.isAuthenticated;

    final isAuthRoute = state.matchedLocation == '/auth';

    // 미로그인 상태에서 보호된 페이지 접근 시
    if (!isLoggedIn && !isAuthRoute) {
      return '/auth'; // 인증 페이지로 리다이렉트
    }

    // 로그인된 상태에서 인증 페이지 접근 시
    if (isLoggedIn && isAuthRoute) {
      return '/[feature]'; // 메인 페이지로 리다이렉트
    }

    return null; // 리다이렉션 없음
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/[feature]',
      builder: (context, state) => const [Feature]View(),
    ),
  ],
);
```

---

## 🏗️ 라우트 구조 템플릿

### 라우트 경로 상수

> **abstract class** 사용으로 인스턴스화 방지

```dart
/// lib/core/route/routes.dart
abstract class Routes {
  // 스플래시 (초기 화면)
  static const String splash = '/';

  // 인증 관련
  static const String auth = '/auth';
  static const String signIn = '/sign_in';
  static const String signUp = '/sign_up';

  // 메인 앱 (ShellRoute)
  static const String home = '/home';
  static const String [feature] = '/[feature]';
  static const String settings = '/settings';

  // 기능별 상세 라우트
  static const String [feature]Detail = '/[feature]/:id';
  static const String [feature]Add = '/[feature]/add';
}
```

> **경로 네이밍**: snake_case (`/sign_in`) 권장

### 실제 라우터 구현 템플릿

```dart
// lib/core/route/router.dart
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splash,
  debugLogDiagnostics: true,

  // 인증 상태 기반 리다이렉트
  redirect: (context, state) {
    final authViewModel = context.read<AuthViewModel>();
    final isLoggedIn = authViewModel.isAuthenticated;
    final isAuthRoute = state.matchedLocation == Routes.auth;

    if (!isLoggedIn && !isAuthRoute) {
      return Routes.auth;
    }
    if (isLoggedIn && isAuthRoute) {
      return Routes.home;
    }
    return null;
  },

  routes: [
    // 독립 화면 (ShellRoute 밖)
    GoRoute(
      path: Routes.splash,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: Routes.auth,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthView(),
    ),

    // 메인 앱 ShellRoute (바텀 네비게이션 포함)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: Routes.[feature],
          builder: (context, state) => const [Feature]View(),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),
  ],
);
```

### 탭 네비게이션 레이아웃 (선택사항)

```dart
// lib/ui/layout/main_layout.dart
class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '목록'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/list')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/list'); break;
      case 2: context.go('/settings'); break;
    }
  }
}
```

탭 네비게이션이 필요한 경우 `ShellRoute`와 함께 사용:

```dart
ShellRoute(
  builder: (context, state, child) => MainLayout(child: child),
  routes: [
    GoRoute(path: '/home', builder: (_, __) => const HomeView()),
    GoRoute(path: '/list', builder: (_, __) => const ListView()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsView()),
  ],
)
```

---

## ✅ 핵심 원칙

1. **중앙 집중식 라우트 관리**: 모든 라우트를 `router.dart`에서 정의
2. **Provider 기반 인증**: `context.read<AuthViewModel>()`로 인증 상태 확인
3. **간단한 리다이렉트**: GoRouter의 `redirect`로 인증 라우팅 처리
4. **명확한 경로 구조**: `/auth`, `/home`, `/[feature]` 등 직관적인 경로 사용

---

## ✅ 요약

| 항목 | 설명 |
|:---|:---|
| **파일 위치** | `lib/core/route/router.dart` |
| **기본 네비게이션** | `context.go()`, `context.push()`, `context.pop()` |
| **인증 처리** | `redirect`에서 Provider로 상태 확인 |
| **탭 네비게이션** | 필요시 `ShellRoute`와 `MainLayout` 사용 |

---
