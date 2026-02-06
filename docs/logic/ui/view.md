# 🖥️ View 설계 가이드 (Clean Architecture + MVVM + Provider)

---

## ✅ 목적

View는 Presentation Layer에서 **ChangeNotifierProvider 설정**과 **UI 렌더링**을 담당합니다.

---

## ✅ 설계 원칙

- **ChangeNotifierProvider**로 ViewModel 주입
- View는 **StatelessWidget**으로 작성
- **Consumer/Selector**로 State 구독
- **_buildXXX() 함수**로 세분화

---

## ✅ 파일 구조

```text
lib/features/
├── auth/ui/view.dart                  # AuthView
└── [feature]/ui/view.dart             # [Feature]View
```

---

## ✅ View 기본 구성 예시

### Provider 구독 (main.dart에서 설정됨)

View는 main.dart에서 설정된 ChangeNotifierProvider를 Consumer로 구독합니다.

```dart
class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SignInViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingScreen();
          }

          return _buildSignInForm(context, viewModel);
        },
      ),
    );
  }
}
```

### UI 렌더링 함수들

```dart
Widget _buildLoadingScreen() {
  return const Center(child: CircularProgressIndicator());
}

Widget _buildSignInForm(BuildContext context, SignInViewModel viewModel) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Form(
      key: viewModel.formKey,  // ✅ ViewModel에서 formKey 관리
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ ViewModel의 TextEditingController 사용
          TextFormField(
            controller: viewModel.emailController,
            decoration: const InputDecoration(labelText: '이메일'),
            validator: viewModel.validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.passwordController,
            decoration: const InputDecoration(labelText: '비밀번호'),
            obscureText: viewModel.obscurePassword,
            validator: viewModel.validatePassword,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: viewModel.isValid
                ? () => viewModel.signIn()
                : null,
            child: const Text('로그인'),
          ),
        ],
      ),
    ),
  );
}
```

> ✅ **TextEditingController는 ViewModel에서 관리**: View는 controller만 연결하고, 상태 관리는 ViewModel에서 담당합니다.

---
## ✅ [Feature] 템플릿

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
    // 성공 상태의 UI 구현
    return Container();
  }
}
```

---

## ✅ 상태 기반 렌더링

### Consumer 패턴

```dart
Consumer<[Feature]ViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.hasError) {
      return _buildErrorState(viewModel.errorMessage);
    }

    if (viewModel.isLoading) {
      return _buildLoadingState();
    }

    return _buildSuccessState(viewModel.data);
  },
)
```

### Selector 패턴 (성능 최적화)

```dart
// 특정 상태만 구독
Selector<[Feature]ViewModel, bool>(
  selector: (context, viewModel) => viewModel.isLoading,
  builder: (context, isLoading, child) {
    return isLoading
        ? const CircularProgressIndicator()
        : const SizedBox.shrink();
  },
)
```

---

## ✅ _buildXXX 함수 분리 원칙

### 세분화 기준
- UI 구조가 2~3단계 이상 중첩될 때
- 반복적인 리스트나 카드 뷰를 그릴 때
- 조건 분기가 필요한 상태를 표시할 때
- Consumer가 필요한 위젯 그룹

### 작성 규칙
- `_buildHeader()`, `_buildList()`, `_buildBody()`처럼 목적에 맞게 명확히 함수명 작성
- 하나의 _buildXXX 함수는 하나의 역할만 수행
- _buildXXX 함수에서는 Consumer로 ViewModel 상태에 접근
- ViewModel 메서드 호출은 `context.read<ViewModel>()`을 사용



---

## ✅ 성능 최적화 (필수)

### const 생성자 사용

```dart
// ✅ Good - const 사용
const Text('고정 텍스트')
const SizedBox(height: 16)
const Icon(Icons.home)

// ❌ Bad - const 없음
Text('고정 텍스트')
SizedBox(height: 16)
```

### ListView.builder 필수 사용

```dart
// ❌ Bad - 모든 아이템 한 번에 생성
ListView(
  children: items.map((item) => ItemCard(item: item)).toList(),
)

// ✅ Good - 화면에 보이는 아이템만 생성
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

### Selector로 세분화된 구독

```dart
// ❌ Bad - 전체 상태 구독
Consumer<[Feature]ViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.state.title);  // title 외 변경에도 리빌드
  },
)

// ✅ Good - 필요한 상태만 구독
Selector<[Feature]ViewModel, String>(
  selector: (_, vm) => vm.state.title,
  builder: (context, title, child) {
    return Text(title);  // title 변경시에만 리빌드
  },
)
```

---

## 📌 핵심 요약

- View는 **Consumer/Selector로 상태를 구독**하고 UI를 렌더링
- **const 생성자** 적극 활용 (Flutter가 rebuild 건너뜀)
- **ListView.builder** 필수 사용 (Lazy Loading)
- **Selector 패턴**으로 세분화된 구독 (성능 최적화)
- **_buildXXX() 함수**로 화면 요소를 작은 단위로 분리
- **상태별 UI 분기** (로딩/에러/성공)로 사용자 경험 향상
- ViewModel 메서드 호출은 `context.read<ViewModel>()`

---