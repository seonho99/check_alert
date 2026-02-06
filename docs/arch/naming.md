# 🏷️ 네이밍 규칙 가이드

> **참조**: [Effective Dart: Style](https://dart.dev/effective-dart/style)

## ✅ 목적

**Provider + MVVM + Clean Architecture**에서 일관된 명명 규칙을 정의하여 코드 가독성과 유지보수성을 확보한다.

## ✅ 설계 원칙 (Dart 공식 가이드 기반)

- 파일명: `lowercase_with_underscores.dart` (snake_case)
- 클래스명: `UpperCamelCase` (PascalCase)
- 변수/함수/매개변수: `lowerCamelCase`
- 상수: `lowerCamelCase` (k 접두사 비권장)
- 계층별 접미사 고정 (Repository, UseCase, ViewModel, State, Dto)
- Firebase 구현체: `FirebaseDataSourceImpl` 접미사
- Extension 변환: `toModel()`, `toDto()`, `toFirestore()`

## ✅ 1. Repository & DataSource 네이밍

### Repository
- 인터페이스: `[Feature]Repository`
- 구현체: `[Feature]RepositoryImpl`
- 파일명: `[feature]_repository.dart`, `[feature]_repository_impl.dart`

#### 📌 Repository 메서드 네이밍 규칙

| 동작 유형   | 접두사 예시              | 설명                         |
|-------------|--------------------------|------------------------------|
| 데이터 조회 | `get`, `fetch`           | 도메인 객체를 가져오는 경우 |
| 상태 변경   | `update`, `toggle`       | 데이터 수정, 상태 전환 |
| 생성/등록   | `add`, `create`, `save`  | 새로운 데이터 등록           |
| 삭제        | `delete`, `remove`       | 데이터 제거                  |
| 검증/확인   | `check`, `verify`        | 조건 확인, 유효성 검사 등    |

---

### 📁 DataSource

| 구분        | 클래스명 패턴                    | 파일명 패턴                                |
|-------------|----------------------------------|--------------------------------------------|
| 인터페이스  | `[Feature]DataSource`            | `[feature]_datasource.dart`               |
| Firebase 구현체 | `[Feature]FirebaseDataSourceImpl` | `[feature]_firebase_datasource_impl.dart` |

- Firebase 구현체는 `[Feature]FirebaseDataSourceImpl` 형식 사용
- 인터페이스는 추상 클래스로 정의

```dart
// 인터페이스 정의
abstract class [Feature]DataSource {
  Future<List<[Feature]Dto>> get[Features]();
  Future<void> add[Feature]([Feature]Dto dto);
  Future<void> update[Feature](String id, [Feature]Dto dto);
  Future<void> delete[Feature](String id);
}

// Firebase 구현체
class [Feature]FirebaseDataSourceImpl implements [Feature]DataSource {
  final FirebaseFirestore _firestore;

  [Feature]FirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  @override
  Future<List<[Feature]Dto>> get[Features]() async {
    // Firebase Firestore 호출 구현
  }
}
```

#### 📌 DataSource 메서드 네이밍 규칙

| 동작 유형   | 메서드 패턴              | 설명                         | 예시                          |
|-------------|--------------------------|------------------------------|-------------------------------|
| 조회 (단일) | `get[Feature]`           | 단일 엔티티 조회            | `get[Feature](String id)`     |
| 조회 (목록) | `get[Features]`          | 복수 엔티티 조회            | `get[Features]()`             |
| 조회 (조건) | `get[Features]By[Condition]` | 조건부 조회           | `get[Features]ByMonth(int year, int month)` |
| 생성        | `add[Feature]`           | 새 엔티티 추가              | `add[Feature]([Feature]Dto dto)` |
| 수정        | `update[Feature]`        | 기존 엔티티 수정            | `update[Feature](String id, [Feature]Dto dto)` |
| 삭제        | `delete[Feature]`        | 엔티티 삭제                 | `delete[Feature](String id)`  |
| 존재 확인   | `exists[Feature]`        | 엔티티 존재 여부            | `exists[Feature](String id)`  |

---

# ✅ 2. UseCase 네이밍 및 사용 규칙

### UseCase 클래스 네이밍
- 클래스명: `[동작][Feature]UseCase`
- 파일명: `[동작]_[feature]_usecase.dart`
- 메서드는 기본적으로 `call()` 사용 (함수 객체 패턴)

### UseCase 네이밍 패턴

| 동작 유형 | 클래스명 패턴 | 파일명 패턴 |
|-----------|--------------|------------|
| 조회 (목록) | `Get[Features]UseCase` | `get_[features]_usecase.dart` |
| 조회 (단일) | `Get[Feature]UseCase` | `get_[feature]_usecase.dart` |
| 조회 (조건) | `Get[Features]By[Condition]UseCase` | `get_[features]_by_[condition]_usecase.dart` |
| 생성 | `Add[Feature]UseCase` | `add_[feature]_usecase.dart` |
| 수정 | `Update[Feature]UseCase` | `update_[feature]_usecase.dart` |
| 삭제 | `Delete[Feature]UseCase` | `delete_[feature]_usecase.dart` |
| 상태 변경 | `Toggle[Feature]UseCase` | `toggle_[feature]_usecase.dart` |
| 검증 | `Validate[Feature]UseCase` | `validate_[feature]_usecase.dart` |

### UseCase 구현 예시

```dart
// 목록 조회
class Get[Features]UseCase {
  final [Feature]Repository _repository;

  Get[Features]UseCase({required [Feature]Repository repository})
      : _repository = repository;

  Future<Result<List<[Feature]>>> call() async {
    return await _repository.get[Features]();
  }
}

// 조건부 조회
class Get[Features]By[Condition]UseCase {
  final [Feature]Repository _repository;

  Get[Features]By[Condition]UseCase({required [Feature]Repository repository})
      : _repository = repository;

  Future<Result<List<[Feature]>>> call({
    required [ParameterType] parameter,
  }) async {
    return await _repository.get[Features]By[Condition](parameter);
  }
}

// 생성
class Add[Feature]UseCase {
  final [Feature]Repository _repository;

  Add[Feature]UseCase({required [Feature]Repository repository})
      : _repository = repository;

  Future<Result<void>> call([Feature] [feature]) async {
    return await _repository.add[Feature]([feature]);
  }
}
```

---

# ✅ 3. UI 계층 네이밍 (MVVM)

### 📁 폴더 구조

```
ui/
├── [feature]/
│   ├── [feature]_view.dart        # [Feature]View (Consumer로 상태 구독)
│   ├── [feature]_viewmodel.dart   # [Feature]ViewModel
│   ├── [feature]_state.dart       # [Feature]State
│   └── widgets/                   # 해당 기능 전용 위젯
│       ├── [feature]_item.dart
│       └── [feature]_card.dart
```

### 📌 ViewModel 네이밍

| 구성 요소 | 클래스명 패턴 | 파일명 |
|----------|--------------|--------|
| ViewModel | `[Feature]ViewModel` | `[feature]_viewmodel.dart` |

- ChangeNotifier를 상속하여 구현
- UseCase를 주입받아 비즈니스 로직 실행

```dart
class [Feature]ViewModel extends ChangeNotifier {
  final Get[Features]UseCase _get[Features]UseCase;
  final Add[Feature]UseCase _add[Feature]UseCase;

  [Feature]State _state = const [Feature]State();
  [Feature]State get state => _state;

  [Feature]ViewModel({
    required Get[Features]UseCase get[Features]UseCase,
    required Add[Feature]UseCase add[Feature]UseCase,
  }) : _get[Features]UseCase = get[Features]UseCase,
       _add[Feature]UseCase = add[Feature]UseCase;

  // 상태 관리 메서드
  void _setState([Feature]State newState) {
    _state = newState;
    notifyListeners();
  }
}
```

### 📌 State 네이밍

| 구성 요소 | 클래스명 패턴 | 파일명 |
|----------|--------------|--------|
| State | `[Feature]State` | `[feature]_state.dart` |

- Freezed 3.0의 `sealed class` 사용
- 기능별 폴더 내 `[feature]_state.dart` 파일로 통일

```dart
@freezed
sealed class [Feature]State with _$[Feature]State {
  const factory [Feature]State({
    @Default([]) List<[Feature]> items,
    @Default(false) bool isLoading,
    @Default(null) String? errorMessage,
    @Default(null) [Feature]? selected[Feature],
  }) = _[Feature]State;
}
```

### 📌 View 네이밍

| 구성 요소 | 클래스명 패턴 | 파일명 | 역할 |
|----------|--------------|-------|------|
| View | `[Feature]View` | `[feature]_view.dart` | UI 렌더링 (Consumer로 구독) |

- main.dart에서 모든 ChangeNotifierProvider 중앙 설정됨 (`core/di/viewmodel_providers.dart`)
- View는 Consumer/Selector로만 ViewModel 상태 구독
- StatelessWidget으로 구현
- Provider 설정 코드 불필요

```dart
// [feature]_view.dart
class [Feature]View extends StatelessWidget {
  const [Feature]View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<[Feature]ViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          if (state.isLoading) {
            return _buildLoadingView();
          }

          return _buildContentView(state);
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContentView([Feature]State state) {
    return Column(
      children: [
        // UI 구현
      ],
    );
  }
}
```

### 📌 Widget 네이밍

| 위젯 유형 | 파일명 패턴 | 클래스명 패턴 |
|----------|------------|--------------|
| 리스트 아이템 | `[feature]_item.dart` | `[Feature]Item` |
| 카드 | `[feature]_card.dart` | `[Feature]Card` |
| 폼 | `[feature]_form.dart` | `[Feature]Form` |
| 다이얼로그 | `[feature]_dialog.dart` | `[Feature]Dialog` |

- 기능명 접두사 필수 사용
- 각 기능 폴더의 `widgets/` 하위에 위치

---

# ✅ Mapper 네이밍 (Extension 방식)

### 📁 파일 위치 및 네이밍

| 항목 | 규칙 |
|------|------|
| 파일 경로 | `lib/data/mapper/` |
| 파일명 | `[entity_name]_mapper.dart` |
| Extension명 | `[Feature]DtoMapper`, `[Feature]ModelMapper` 등 |
| 메서드명 | `toModel()`, `toDto()`, `toFirestore()`, `toModelList()` 등 |

### 📌 Extension 패턴

| Extension 유형 | Extension명 | 주요 메서드 |
|---------------|-------------|------------|
| DTO → Model | `[Feature]DtoMapper` | `toModel()` |
| Model → DTO | `[Feature]ModelMapper` | `toDto()`, `toFirestore()` |
| List 변환 | `[Feature]DtoListMapper` | `toModelList()` |
| List 변환 | `[Feature]ModelListMapper` | `toDtoList()` |
| Firebase 변환 | `FirestoreDocumentMapper` | `to[Feature]Model()` |

---

# ✅ 5. DTO 네이밍

| 구분 | 패턴 | 예시 |
|------|------|------|
| 클래스명 | `[Feature]Dto` | `UserDto`, `HistoryDto` |
| 파일명 | `[feature]_dto.dart` | `user_dto.dart`, `history_dto.dart` |
| 구현 방식 | Freezed (일반 class) | JSON 직렬화 중심 |

```dart
@freezed
class [Feature]Dto with _$[Feature]Dto {
  const factory [Feature]Dto({
    String? id,
    // 필드 정의
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _[Feature]Dto;

  factory [Feature]Dto.fromJson(Map<String, dynamic> json) =>
      _$[Feature]DtoFromJson(json);
}
```

---

# ✅ 네이밍 요약표

| 항목           | 클래스명 패턴                    | 파일명 패턴                              |
|----------------|---------------------------------|------------------------------------|
| Model (Domain) | `[Feature]`                     | `[feature].dart`                   |
| Repository (Interface) | `[Feature]Repository`    | `[feature]_repository.dart`        |
| Repository (Impl) | `[Feature]RepositoryImpl`     | `[feature]_repository_impl.dart`   |
| DataSource (Interface) | `[Feature]DataSource`     | `[feature]_datasource.dart`        |
| DataSource (Impl) | `[Feature]FirebaseDataSourceImpl` | `[feature]_firebase_datasource_impl.dart` |
| UseCase        | `[Action][Feature]UseCase`      | `[action]_[feature]_usecase.dart`   |
| ViewModel      | `[Feature]ViewModel`            | `[feature]_viewmodel.dart`          |
| State          | `[Feature]State`                | `[feature]_state.dart`              |
| View           | `[Feature]View`                 | `[feature]_view.dart`               |
| DTO            | `[Feature]Dto`                  | `[feature]_dto.dart`                |
| Mapper         | `[Feature]DtoMapper` (Extension) | `[feature]_mapper.dart`            |

---


# ✅ 6. Firebase 네이밍 규칙

### Firebase DataSource 네이밍

| 구분 | 클래스명 패턴 | 파일명 패턴 |
|------|---------------|-------------|
| 인터페이스 | `[Feature]DataSource` | `[feature]_datasource.dart` |
| Firebase 구현체 | `[Feature]FirebaseDataSourceImpl` | `[feature]_firebase_datasource_impl.dart` |

### Firestore 컬렉션 네이밍

| 타입 | 네이밍 규칙 | 예시 |
|------|-------------|------|
| 컬렉션명 | `snake_case` (복수형) | `users`, `histories` |
| 필드명 | `camelCase` | `displayName`, `createdAt` |
| 문서 ID | `kebab-case` 또는 `UUID` | `user-123`, `auto-generated` |
---