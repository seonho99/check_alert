# 🧱 레이어별 책임 및 흐름 가이드

> **참조**: [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/guide) | [Architecture Recommendations](https://docs.flutter.dev/app-architecture/recommendations)

---

# ✅ 아키텍처 구조 배경

이 프로젝트는 기본적으로 **Provider + MVVM + Clean Architecture + Freezed**를 기반으로 화면 구조를 설계합니다.

- **Provider**를 통해 의존성 주입과 상태 관리를 수행하고,
- **MVVM** 패턴을 통해 ViewModel(ChangeNotifier) 중심으로 상태를 관리하며,
- **Clean Architecture**를 통해 레이어별 책임을 명확히 구분하고,
- **Freezed**를 통해 불변 상태 객체와 DTO를 생성합니다.

> **Flutter 공식 권장**: UI Layer (Views + ViewModels) + Data Layer (Repositories + Services)
> Domain Layer(UseCase)는 **복잡한 비즈니스 로직**이 있을 때만 선택적으로 사용

이 문서에서는 각 레이어의 구체적인 책임과 데이터 흐름을 명확히 정의합니다.

---

# 🏛️ 레이어 구조

### 1. UI Layer (MVVM)

- **사용자 인터페이스 계층**입니다.
- **View**: 순수 UI 렌더링 (StatelessWidget), Consumer로 상태 구독
- **ViewModel**: ChangeNotifier 기반 상태 관리, UseCase 호출
- **State**: Freezed 3.0 기반 불변 상태 객체
- Provider 설정은 main.dart에서 중앙 집중식으로 관리됩니다.
- Consumer/Selector로 상태를 구독하고, ViewModel 메서드를 호출합니다.
- 직접 비즈니스 로직을 실행하거나 외부 데이터 통신을 호출하지 않습니다.

---

### 2. Domain Layer

- **비즈니스 로직 계층**입니다.
- **Model**: 순수 도메인 모델 ([Feature], Auth 등)
- **UseCase**: 비즈니스 규칙을 실행합니다.
- **Repository Interface**: 데이터 접근을 추상화합니다.
- Repository 인터페이스를 정의하고, 이 인터페이스만 의존합니다.
- 외부 통신은 직접 호출하지 않고, Repository를 통해 간접적으로 수행합니다.

---

### 3. Data Layer

- **외부 데이터 통신 및 가공 계층**입니다.
- **Repository Implementation**: Domain Layer의 Repository 인터페이스를 구현합니다.
- **DataSource**: 외부 통신을 수행합니다 (Firebase/API).
- **DTO**: 데이터 전송 객체 (Freezed 3.0)
- **Mapper**: DTO ↔ Model 변환을 수행합니다 (Extension 방식).

---

# 🔥 데이터 흐름 (Provider 패턴)

```
View Event → ViewModel → UseCase → Repository → DataSource
         ↓
   State 업데이트 → notifyListeners() → Consumer 리빌드
```

- 요청은 View에서 DataSource로, 응답은 DataSource에서 View로 흐릅니다.
- 상위 레이어가 하위 레이어에만 의존합니다.
- 하위 레이어는 상위 레이어를 참조하지 않습니다.

---

# 🧠 상태 및 결과 관리 규칙

- **DataSource**는 외부 통신 결과를 반환합니다.
- **RepositoryImpl**은 DataSource를 호출하고 결과를 변환합니다.
- **RepositoryImpl**은 결과를 **Result<T>** 형태로 감싸서 반환합니다.
- **UseCase**는 Repository로부터 받은 Result<T>를 그대로 반환합니다.
- **ViewModel**은 UseCase로부터 받은 Result<T>를 처리하여 State를 업데이트하고 notifyListeners()를 호출합니다.

✅ **Result<T> 패턴은 Repository에서 생성, UseCase에서 전달, ViewModel에서 처리**

> 이 책임 분리를 통해 통신/실패 로직과 UI 상태 관리 로직을 명확히 구분할 수 있습니다.

---

# 🗂️ 폴더 구조 설계 (보완 설명)

| 폴더 | 역할 |
|:---|:---|
| core/di | Provider 의존성 주입 설정 (분리 관리) |
| core/route | GoRouter 설정 |
| core/result | Result<T> 패턴 정의 |
| core/errors | Failure, Exception 정의 |
| data/datasource | 외부 통신 전용 (Firebase, REST API 등) |
| data/dto | 외부 데이터 통신용 순수 데이터 객체 (DTO) |
| data/mapper | DTO ↔ Model 변환 책임 |
| data/repository_impl | Repository 인터페이스의 구현체 |
| domain/model | 도메인 순수 모델 (비즈니스 단위 객체) |
| domain/repository | Repository 인터페이스 (UseCase가 의존) |
| domain/usecase | 비즈니스 로직 실행 책임 |
| ui/{feature}/{feature}_state.dart | freezed 기반 상태 객체 |
| ui/{feature}/{feature}_viewmodel.dart | ChangeNotifier 기반 ViewModel |
| ui/{feature}/{feature}_view.dart | 순수 UI 렌더링 (StatelessWidget) |

### DI 폴더 구조 (core/di/)

```
core/di/
├── core_providers.dart        # Firebase, GoogleSignIn 등 Core 서비스
├── data_providers.dart        # DataSource 구현체
├── domain_providers.dart      # Repository, UseCase
└── viewmodel_providers.dart   # ViewModel
```

✅ Repository 인터페이스는 domain에,
✅ Repository 구현체는 data에 둡니다.
✅ UseCase는 항상 Repository 인터페이스만 의존합니다.

---

# 🛠️ 레이어별 책임 요약

| 레이어 | 주요 책임 | 주의사항 |
|:---|:---|:---|
| Main.dart | 모든 Provider 설정, 의존성 주입 | 앱 전체 Provider 중앙 관리 |
| View | UI 렌더링, Consumer로 상태 구독 | 직접 비즈니스 로직이나 외부 통신 호출 금지 |
| ViewModel | State 관리, UseCase 호출, notifyListeners | UseCase 호출 외에는 비즈니스 로직 직접 처리 금지 |
| UseCase | 비즈니스 규칙 실행 | 직접 외부 통신(DataSource) 호출 금지 |
| Repository (Interface) | 외부 데이터 접근 추상화 | 구현체가 아닌 인터페이스 정의만 담당 |
| Repository Impl | 외부 데이터 가공 및 제공 | Result<T>로 감싸서 반환 |
| DataSource | 외부 통신 수행 (Firebase/API) | 외부 데이터 접근만 담당 |

---

# 🧩 예시 흐름 (구체적)

**Provider 설정 (앱 시작 시):**
```dart
// main.dart
MultiProvider(
  providers: [
    ...buildCoreProviders(),      // Firebase, GoogleSignIn
    ...buildDataProviders(),      // DataSource
    ...buildDomainProviders(),    // Repository, UseCase
    ...buildViewModelProviders(), // ViewModel
  ],
  child: MaterialApp.router(...),
)
```

**런타임 데이터 흐름:**
1. 사용자 이벤트 발생 → View에서 `context.read<ViewModel>().method()` 호출
2. ViewModel이 해당 Action에 맞는 UseCase 호출
3. UseCase가 Repository(Interface)를 호출
4. RepositoryImpl이 DataSource를 통해 외부 통신
5. 통신 결과(Result<T>)가 RepositoryImpl → UseCase → ViewModel로 전달
6. ViewModel이 Result<T>를 처리하여 State 업데이트 후 notifyListeners() 호출
7. Consumer가 상태 변경을 감지하여 View 재렌더링

---

# ✅ 문서 요약

- 레이어는 UI → Domain → Data 순으로 구성합니다.
- 요청과 응답의 양방향 흐름을 유지합니다.
- 비즈니스 로직은 UseCase에만 존재합니다. (복잡한 로직이 없으면 생략 가능)
- 외부 통신 결과는 Repository Impl에서 Result<T>로 감싸서 반환합니다.
- 상태 관리는 ViewModel이 담당합니다.
- **Provider 설정은 `core/di/` 폴더에서 분리 관리**합니다.
- main.dart에서 MultiProvider로 분리된 Provider들을 조합합니다.
- 폴더 구조는 Clean Architecture + MVVM + Freezed 패턴을 따릅니다.