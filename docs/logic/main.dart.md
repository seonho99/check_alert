# 🚀 Main.dart 설정 가이드 (Clean Architecture + Provider)

---

## ✅ 목적

main.dart에서 **앱 초기화**와 **Provider 설정**을 담당합니다.

---

## ✅ 설계 원칙

- **MultiProvider**로 모든 의존성 한 번에 설정
- **의존성 주입 순서**: DataSource → Repository → UseCase → ViewModel
- **Firebase 초기화** 및 **라우터 설정**
- View에서는 Consumer/Selector로만 구독

---

## ✅ 실제 구현 구조

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'firebase_options.dart';
import 'core/services/fcm_service.dart';
import 'core/services/network_service.dart';
import 'core/route/router.dart';
import 'core/di/core_providers.dart';
import 'core/di/data_providers.dart';
import 'core/di/domain_providers.dart';
import 'core/di/viewmodel_providers.dart';
import 'data/datasource/notification/budget_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Google Mobile Ads 초기화
  await MobileAds.instance.initialize();

  // 3. Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: 'your-native-app-key');

  // 4. 날짜 포맷 초기화 (한국어)
  await initializeDateFormatting('ko_KR', null);

  // 5. 네트워크 모니터링 시작
  NetworkService().startNetworkMonitoring();

  // 6. FCM 초기화 (플랫폼별 분기)
  if (Platform.isIOS) {
    // iOS는 안전 모드로 비동기 초기화
    Future.microtask(() async {
      await FCMServiceIOSSafe().initializeIOSSafe();
    });
  } else {
    // Android는 동기 초기화
    await FCMService().initialize();
  }

  // 7. 로컬 알림 초기화
  await BudgetNotificationService.initializeLocalNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: '[AppName]',
        theme: ThemeData.light(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        // 한국어 지역화 설정
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ko', 'KR'),
      ),
    );
  }
}
```

---

## ✅ Provider 분리 구조

### 폴더 구조

```
lib/core/di/
├── core_providers.dart        # Firebase, GoogleSignIn, 광고 서비스
├── data_providers.dart        # DataSource 구현체
├── domain_providers.dart      # Repository, UseCase
└── viewmodel_providers.dart   # ViewModel
```

### main.dart에서 import

```dart
import 'core/di/core_providers.dart';
import 'core/di/data_providers.dart';
import 'core/di/domain_providers.dart';
import 'core/di/viewmodel_providers.dart';
```

> 📎 Provider 분리 상세 가이드: [../arch/provider.md](../arch/provider.md)

---

## ✅ 의존성 주입 패턴

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
    Provider(
      create: (context) => SignInUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),
    Provider(
      create: (context) => Get[Feature]sUseCase(
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
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => [Feature]ViewModel(
        get[Feature]sUseCase: context.read<Get[Feature]sUseCase>(),
      ),
    ),
  ];
}
```

---

## ✅ 라우터 설정

```dart
class AppRouter {
  static final GoRouter router = GoRouter(
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
}
```

---

## 📌 핵심 요약

- **MultiProvider**로 모든 의존성을 main.dart에서 한 번에 설정
- **의존성 순서**: DataSource → Repository → UseCase → ViewModel
- **Firebase 초기화**와 **라우터 설정** 포함
- View에서는 Consumer로만 구독, Provider 설정 불필요

---