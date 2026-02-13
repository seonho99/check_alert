# 전체 프로젝트 구조 + Phase별 구현 순서

> **참조**: [docs/logic/](../logic/) 가이드의 Clean Architecture + MVVM + Provider 패턴

---

## 1. 전체 lib/ 폴더 구조

```
lib/
├── main.dart                              # 앱 진입점, Firebase 초기화
├── firebase_options.dart                  # Firebase 설정 (자동 생성)
│
├── core/                                  # 공통 인프라
│   ├── di/                                # Provider 의존성 주입
│   │   ├── core_providers.dart            # Firebase, 서비스 Provider
│   │   ├── data_providers.dart            # DataSource Provider
│   │   ├── domain_providers.dart          # Repository, UseCase Provider
│   │   └── viewmodel_providers.dart       # ViewModel Provider
│   │
│   ├── result/                            # Result<T> 패턴
│   │   └── result.dart                    # Success, Error 클래스
│   │
│   ├── errors/                            # 에러 처리
│   │   ├── failure.dart                   # Failure 타입 정의
│   │   ├── failure_mapper.dart            # Exception → Failure 변환
│   │   └── exceptions.dart                # 커스텀 Exception 정의
│   │
│   ├── route/                             # 라우팅
│   │   └── router.dart                    # GoRouter 설정
│   │
│   ├── theme/                             # 테마
│   │   ├── app_theme.dart                 # ThemeData 설정
│   │   ├── app_colors.dart                # 색상 상수
│   │   └── app_text_styles.dart           # 텍스트 스타일 정의
│   │
│   ├── constants/                         # 상수
│   │   └── app_constants.dart             # 앱 전역 상수
│   │
│   ├── utils/                             # 유틸리티
│   │   ├── date_utils.dart                # 날짜 유틸 (정규화, 포맷)
│   │   └── validators.dart                # 입력 검증 유틸
│   │
│   └── services/                          # 공통 서비스
│       └── local_notification_service.dart # 로컬 알림 (rescheduleAll, iOS 64개 제한 대응)
│
├── domain/                                # 도메인 레이어
│   ├── model/                             # 도메인 모델 (Freezed)
│   │   ├── user_model.dart                # 사용자 모델
│   │   ├── user_model.freezed.dart        # (자동 생성)
│   │   ├── task_model.dart                # 체크 항목 모델
│   │   ├── task_model.freezed.dart        # (자동 생성)
│   │   ├── repeat_type.dart               # 반복 유형 enum (weekly/monthly/once)
│   │   ├── check_record_model.dart        # 체크 기록 모델
│   │   └── check_record_model.freezed.dart # (자동 생성)
│   │
│   ├── repository/                        # Repository 인터페이스
│   │   ├── auth_repository.dart           # 인증 Repository
│   │   ├── task_repository.dart           # 체크 항목 Repository
│   │   └── check_record_repository.dart   # 체크 기록 Repository
│   │
│   └── usecase/                           # UseCase (비즈니스 로직)
│       ├── auth/                          # 인증 UseCase
│       │   ├── sign_in_usecase.dart
│       │   ├── sign_up_usecase.dart
│       │   └── sign_out_usecase.dart
│       │
│       ├── task/                          # 체크 항목 UseCase
│       │   ├── get_tasks_usecase.dart
│       │   ├── get_today_tasks_usecase.dart
│       │   ├── add_task_usecase.dart
│       │   ├── update_task_usecase.dart
│       │   └── delete_task_usecase.dart
│       │
│       └── check_record/                  # 체크 기록 UseCase
│           ├── toggle_check_usecase.dart
│           ├── get_records_by_date_usecase.dart
│           └── get_monthly_records_usecase.dart
│
├── data/                                  # 데이터 레이어
│   ├── dto/                               # DTO (JsonSerializable)
│   │   ├── user_model_dto.dart
│   │   ├── user_model_dto.g.dart          # (자동 생성)
│   │   ├── task_model_dto.dart
│   │   ├── task_model_dto.g.dart          # (자동 생성)
│   │   ├── check_record_model_dto.dart
│   │   └── check_record_model_dto.g.dart  # (자동 생성)
│   │
│   ├── mapper/                            # Extension Mapper
│   │   ├── user_model_mapper.dart
│   │   ├── task_model_mapper.dart
│   │   └── check_record_model_mapper.dart
│   │
│   ├── datasource/                        # DataSource
│   │   ├── auth_datasource.dart                       # 인터페이스
│   │   ├── auth_firebase_datasource_impl.dart         # 구현체
│   │   ├── task_datasource.dart                       # 인터페이스
│   │   ├── task_firebase_datasource_impl.dart         # 구현체
│   │   ├── check_record_datasource.dart               # 인터페이스
│   │   └── check_record_firebase_datasource_impl.dart # 구현체
│   │
│   └── repository_impl/                   # Repository 구현체
│       ├── auth_repository_impl.dart
│       ├── task_repository_impl.dart
│       └── check_record_repository_impl.dart
│
└── ui/                                    # UI 레이어 (Presentation)
    ├── home/                              # 홈 화면 (오늘의 체크)
    │   ├── home_state.dart                # Freezed State
    │   ├── home_state.freezed.dart        # (자동 생성)
    │   ├── home_viewmodel.dart            # ViewModel
    │   └── home_view.dart                 # View (Widget)
    │
    ├── task_list/                         # 항목 관리 목록
    │   ├── task_list_state.dart
    │   ├── task_list_state.freezed.dart
    │   ├── task_list_viewmodel.dart
    │   └── task_list_view.dart
    │
    ├── task_detail/                       # 항목 추가/수정
    │   ├── task_detail_state.dart
    │   ├── task_detail_state.freezed.dart
    │   ├── task_detail_viewmodel.dart
    │   └── task_detail_view.dart
    │
    ├── statistics/                        # 통계
    │   ├── statistics_state.dart
    │   ├── statistics_state.freezed.dart
    │   ├── statistics_viewmodel.dart
    │   └── statistics_view.dart
    │
    ├── daily_check/                       # 날짜별 체크 상세
    │   ├── daily_check_state.dart
    │   ├── daily_check_state.freezed.dart
    │   ├── daily_check_viewmodel.dart
    │   └── daily_check_view.dart
    │
    ├── auth/                              # 인증 (로그인/회원가입)
    │   ├── sign_in/
    │   │   ├── sign_in_state.dart
    │   │   ├── sign_in_state.freezed.dart
    │   │   ├── sign_in_viewmodel.dart
    │   │   └── sign_in_view.dart
    │   └── sign_up/
    │       ├── sign_up_state.dart
    │       ├── sign_up_state.freezed.dart
    │       ├── sign_up_viewmodel.dart
    │       └── sign_up_view.dart
    │
    ├── settings/                          # 설정
    │   └── settings_view.dart
    │
    └── widgets/                           # 공통 위젯
        ├── check_item_card.dart           # 체크 항목 카드
        ├── circular_progress.dart         # 원형 진행률
        ├── calendar_heatmap.dart          # 캘린더 히트맵
        ├── week_strip.dart                # 주간 캘린더 스트립
        └── loading_overlay.dart           # 로딩 오버레이
```

---

## 2. Phase별 구현 순서

### Phase 1: 기반 인프라 (core/) — ~15 파일

**목표**: 앱 빌드 가능한 최소 구조

| 순서 | 파일 | 설명 |
|------|------|------|
| 1-1 | `core/result/result.dart` | Result\<T\> 패턴 (Success, Error) |
| 1-2 | `core/errors/failure.dart` | Failure 타입 정의 |
| 1-3 | `core/errors/exceptions.dart` | 커스텀 Exception |
| 1-4 | `core/errors/failure_mapper.dart` | Exception → Failure 변환 |
| 1-5 | `core/theme/app_colors.dart` | 색상 상수 |
| 1-6 | `core/theme/app_theme.dart` | ThemeData 설정 |
| 1-7 | `core/constants/app_constants.dart` | 앱 상수 |
| 1-8 | `core/utils/date_utils.dart` | 날짜 유틸 |
| 1-9 | `core/utils/validators.dart` | 입력 검증 유틸 |
| 1-10 | `core/route/router.dart` | GoRouter 설정 |
| 1-11 | `core/di/core_providers.dart` | Firebase Provider |
| 1-12 | `core/di/data_providers.dart` | DataSource Provider (빈 리스트) |
| 1-13 | `core/di/domain_providers.dart` | Repository/UseCase Provider (빈 리스트) |
| 1-14 | `core/di/viewmodel_providers.dart` | ViewModel Provider (빈 리스트) |
| 1-15 | `main.dart` | 앱 진입점 |

### Phase 2: Auth 기능 — ~20 파일

**목표**: 로그인/회원가입 동작

| 순서 | 파일 | 설명 |
|------|------|------|
| 2-1 | `domain/model/user_model.dart` | UserModel (Freezed) |
| 2-2 | `data/dto/user_model_dto.dart` | UserModelDto (JsonSerializable) |
| 2-3 | `data/mapper/user_model_mapper.dart` | User Mapper |
| 2-4 | `data/datasource/auth_datasource.dart` | Auth DataSource 인터페이스 |
| 2-5 | `data/datasource/auth_firebase_datasource_impl.dart` | Auth Firebase 구현체 |
| 2-6 | `domain/repository/auth_repository.dart` | Auth Repository 인터페이스 |
| 2-7 | `data/repository_impl/auth_repository_impl.dart` | Auth Repository 구현체 |
| 2-8 | `domain/usecase/auth/sign_in_usecase.dart` | 로그인 UseCase |
| 2-9 | `domain/usecase/auth/sign_up_usecase.dart` | 회원가입 UseCase |
| 2-10 | `domain/usecase/auth/sign_out_usecase.dart` | 로그아웃 UseCase |
| 2-11 | `ui/auth/sign_in/sign_in_state.dart` | 로그인 State |
| 2-12 | `ui/auth/sign_in/sign_in_viewmodel.dart` | 로그인 ViewModel |
| 2-13 | `ui/auth/sign_in/sign_in_view.dart` | 로그인 View |
| 2-14 | `ui/auth/sign_up/sign_up_state.dart` | 회원가입 State |
| 2-15 | `ui/auth/sign_up/sign_up_viewmodel.dart` | 회원가입 ViewModel |
| 2-16 | `ui/auth/sign_up/sign_up_view.dart` | 회원가입 View |
| 2-17 | Provider 등록 업데이트 | data/domain/viewmodel providers에 Auth 추가 |

### Phase 3: Task CRUD — ~15 파일

**목표**: 체크 항목 생성/조회/수정/삭제

| 순서 | 파일 | 설명 |
|------|------|------|
| 3-1 | `domain/model/task_model.dart` | TaskModel (Freezed) |
| 3-2 | `data/dto/task_model_dto.dart` | TaskModelDto (JsonSerializable) |
| 3-3 | `data/mapper/task_model_mapper.dart` | Task Mapper |
| 3-4 | `data/datasource/task_datasource.dart` | Task DataSource 인터페이스 |
| 3-5 | `data/datasource/task_firebase_datasource_impl.dart` | Task Firebase 구현체 |
| 3-6 | `domain/repository/task_repository.dart` | Task Repository 인터페이스 |
| 3-7 | `data/repository_impl/task_repository_impl.dart` | Task Repository 구현체 |
| 3-8 | `domain/usecase/task/get_tasks_usecase.dart` | 전체 항목 조회 |
| 3-9 | `domain/usecase/task/get_today_tasks_usecase.dart` | 오늘 항목 조회 |
| 3-10 | `domain/usecase/task/add_task_usecase.dart` | 항목 추가 |
| 3-11 | `domain/usecase/task/update_task_usecase.dart` | 항목 수정 |
| 3-12 | `domain/usecase/task/delete_task_usecase.dart` | 항목 삭제 |
| 3-13 | `ui/task_list/task_list_*.dart` | 항목 목록 UI (State, ViewModel, View) |
| 3-14 | `ui/task_detail/task_detail_*.dart` | 항목 상세 UI (State, ViewModel, View) |
| 3-15 | Provider 등록 업데이트 | Task 관련 Provider 추가 |

### Phase 4: Check Record — ~12 파일

**목표**: 체크 토글 + 오늘의 체크 화면

| 순서 | 파일 | 설명 |
|------|------|------|
| 4-1 | `domain/model/check_record_model.dart` | CheckRecordModel (Freezed) |
| 4-2 | `data/dto/check_record_model_dto.dart` | CheckRecordModelDto (JsonSerializable) |
| 4-3 | `data/mapper/check_record_model_mapper.dart` | CheckRecord Mapper |
| 4-4 | `data/datasource/check_record_datasource.dart` | CheckRecord DataSource 인터페이스 |
| 4-5 | `data/datasource/check_record_firebase_datasource_impl.dart` | CheckRecord Firebase 구현체 |
| 4-6 | `domain/repository/check_record_repository.dart` | CheckRecord Repository 인터페이스 |
| 4-7 | `data/repository_impl/check_record_repository_impl.dart` | CheckRecord Repository 구현체 |
| 4-8 | `domain/usecase/check_record/toggle_check_usecase.dart` | 체크 토글 UseCase |
| 4-9 | `domain/usecase/check_record/get_records_by_date_usecase.dart` | 날짜별 기록 조회 |
| 4-10 | `ui/home/home_*.dart` | 홈 화면 UI (State, ViewModel, View) |
| 4-11 | `ui/daily_check/daily_check_*.dart` | 날짜별 체크 UI |
| 4-12 | Provider 등록 업데이트 | CheckRecord 관련 Provider 추가 |

### Phase 5: 알림 서비스 — ~4 파일

**목표**: 로컬 알림 (FCM 미사용)

| 순서 | 파일 | 설명 |
|------|------|------|
| 5-1 | `core/services/local_notification_service.dart` | 로컬 알림 서비스 (rescheduleAll, iOS 64개 제한, Android 14 정확한 알람 권한) |
| 5-2 | Firestore 보안 규칙 배포 | `firestore.rules` |
| 5-3 | Firestore 인덱스 배포 | `firestore.indexes.json` |
| 5-4 | 알림 관련 설정 UI | settings_view.dart (카드 그룹 레이아웃, 로그아웃 다이얼로그) |

### Phase 6: 통계/대시보드 — ~8 파일

**목표**: 통계 화면 + 캘린더 히트맵

| 순서 | 파일 | 설명 |
|------|------|------|
| 6-1 | `domain/usecase/check_record/get_monthly_records_usecase.dart` | 월별 기록 조회 |
| 6-2 | `ui/statistics/statistics_*.dart` | 통계 UI (State, ViewModel, View) |
| 6-3 | `ui/widgets/calendar_heatmap.dart` | 캘린더 히트맵 위젯 |
| 6-4 | `ui/widgets/circular_progress.dart` | 원형 진행률 위젯 |
| 6-5 | `ui/widgets/week_strip.dart` | 주간 캘린더 스트립 |
| 6-6 | `ui/widgets/check_item_card.dart` | 체크 항목 카드 |
| 6-7 | `ui/widgets/loading_overlay.dart` | 로딩 오버레이 |
| 6-8 | Provider 등록 업데이트 | Statistics 관련 Provider 추가 |

---

## 3. Provider DI 등록 구조

### `core/di/core_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

List<Provider> buildCoreProviders() {
  return [
    Provider<FirebaseFirestore>(
      create: (_) => FirebaseFirestore.instance,
    ),
    Provider<FirebaseAuth>(
      create: (_) => FirebaseAuth.instance,
    ),
  ];
}
```

### `core/di/data_providers.dart`

```dart
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// DataSource imports
import '../../data/datasource/auth_datasource.dart';
import '../../data/datasource/auth_firebase_datasource_impl.dart';
import '../../data/datasource/task_datasource.dart';
import '../../data/datasource/task_firebase_datasource_impl.dart';
import '../../data/datasource/check_record_datasource.dart';
import '../../data/datasource/check_record_firebase_datasource_impl.dart';

List<Provider> buildDataProviders() {
  return [
    Provider<AuthDataSource>(
      create: (context) => AuthFirebaseDataSourceImpl(
        auth: context.read<FirebaseAuth>(),
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),
    Provider<TaskDataSource>(
      create: (context) => TaskFirebaseDataSourceImpl(
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),
    Provider<CheckRecordDataSource>(
      create: (context) => CheckRecordFirebaseDataSourceImpl(
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),
  ];
}
```

### `core/di/domain_providers.dart`

```dart
import 'package:provider/provider.dart';

// Repository imports
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/task_repository.dart';
import '../../domain/repository/check_record_repository.dart';
import '../../data/repository_impl/auth_repository_impl.dart';
import '../../data/repository_impl/task_repository_impl.dart';
import '../../data/repository_impl/check_record_repository_impl.dart';

// UseCase imports
import '../../domain/usecase/auth/sign_in_usecase.dart';
import '../../domain/usecase/auth/sign_up_usecase.dart';
import '../../domain/usecase/auth/sign_out_usecase.dart';
import '../../domain/usecase/task/get_tasks_usecase.dart';
import '../../domain/usecase/task/get_today_tasks_usecase.dart';
import '../../domain/usecase/task/add_task_usecase.dart';
import '../../domain/usecase/task/update_task_usecase.dart';
import '../../domain/usecase/task/delete_task_usecase.dart';
import '../../domain/usecase/check_record/toggle_check_usecase.dart';
import '../../domain/usecase/check_record/get_records_by_date_usecase.dart';
import '../../domain/usecase/check_record/get_monthly_records_usecase.dart';

List<Provider> buildDomainProviders() {
  return [
    // Repositories
    Provider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        dataSource: context.read<AuthDataSource>(),
      ),
    ),
    Provider<TaskRepository>(
      create: (context) => TaskRepositoryImpl(
        dataSource: context.read<TaskDataSource>(),
      ),
    ),
    Provider<CheckRecordRepository>(
      create: (context) => CheckRecordRepositoryImpl(
        dataSource: context.read<CheckRecordDataSource>(),
      ),
    ),

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
    Provider(
      create: (context) => SignOutUseCase(
        repository: context.read<AuthRepository>(),
      ),
    ),

    // Task UseCases
    Provider(
      create: (context) => GetTasksUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => GetTodayTasksUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => AddTaskUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => UpdateTaskUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),
    Provider(
      create: (context) => DeleteTaskUseCase(
        repository: context.read<TaskRepository>(),
      ),
    ),

    // CheckRecord UseCases
    Provider(
      create: (context) => ToggleCheckUseCase(
        repository: context.read<CheckRecordRepository>(),
      ),
    ),
    Provider(
      create: (context) => GetRecordsByDateUseCase(
        repository: context.read<CheckRecordRepository>(),
      ),
    ),
    Provider(
      create: (context) => GetMonthlyRecordsUseCase(
        repository: context.read<CheckRecordRepository>(),
      ),
    ),
  ];
}
```

### `core/di/viewmodel_providers.dart`

```dart
import 'package:provider/provider.dart';

// ViewModel imports
import '../../ui/auth/sign_in/sign_in_viewmodel.dart';
import '../../ui/auth/sign_up/sign_up_viewmodel.dart';
import '../../ui/home/home_viewmodel.dart';
import '../../ui/task_list/task_list_viewmodel.dart';
import '../../ui/task_detail/task_detail_viewmodel.dart';
import '../../ui/statistics/statistics_viewmodel.dart';
import '../../ui/daily_check/daily_check_viewmodel.dart';

List<ChangeNotifierProvider> buildViewModelProviders() {
  return [
    // Auth ViewModels
    ChangeNotifierProvider(
      create: (context) => SignInViewModel(
        signInUseCase: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => SignUpViewModel(
        signUpUseCase: context.read(),
      ),
    ),

    // Home ViewModel
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        getTodayTasksUseCase: context.read(),
        getRecordsByDateUseCase: context.read(),
        toggleCheckUseCase: context.read(),
      ),
    ),

    // Task ViewModels
    ChangeNotifierProvider(
      create: (context) => TaskListViewModel(
        getTasksUseCase: context.read(),
        deleteTaskUseCase: context.read(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => TaskDetailViewModel(
        addTaskUseCase: context.read(),
        updateTaskUseCase: context.read(),
      ),
    ),

    // Statistics ViewModel
    ChangeNotifierProvider(
      create: (context) => StatisticsViewModel(
        getMonthlyRecordsUseCase: context.read(),
        getTasksUseCase: context.read(),
      ),
    ),

    // Daily Check ViewModel
    ChangeNotifierProvider(
      create: (context) => DailyCheckViewModel(
        getRecordsByDateUseCase: context.read(),
        toggleCheckUseCase: context.read(),
        getTodayTasksUseCase: context.read(),
      ),
    ),
  ];
}
```

---

## 4. 코드 생성 명령어

```bash
# Freezed + JsonSerializable 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 파일 감시 모드 (개발 중)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 5. 총 파일 수 요약

| Phase | 카테고리 | 파일 수 |
|-------|---------|---------|
| 1 | 기반 인프라 (core/) | ~15 |
| 2 | Auth 기능 | ~17 |
| 3 | Task CRUD | ~15 |
| 4 | Check Record | ~12 |
| 5 | 알림 서비스 | ~5 |
| 6 | 통계/대시보드 | ~8 |
| **합계** | | **~72 파일** |

> 자동 생성 파일 (`.freezed.dart`, `.g.dart`) 포함 시 약 85~90 파일

---
