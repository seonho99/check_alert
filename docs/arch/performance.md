# ⚡ Performance 최적화 가이드

> Flutter 공식 문서 기반 성능 최적화 베스트 프랙티스

---

## ✅ 목적

Flutter 앱의 **렌더링 성능**과 **메모리 효율성**을 극대화합니다.

- 60fps (16ms/frame) 또는 120fps (8ms/frame) 유지
- 불필요한 위젯 리빌드 방지
- 메모리 사용량 최적화

---

## ✅ 1. const 생성자 (필수)

> **Flutter 공식 권장**: const 위젯은 rebuild를 건너뜀

### 규칙

```dart
// ✅ Good - const 사용
const MyWidget(
  child: Text('Hello'),
)

// ❌ Bad - const 없음
MyWidget(
  child: Text('Hello'),
)
```

### 적용 위치

| 위젯 | const 사용 |
|------|-----------|
| Text, Icon, SizedBox | 항상 const |
| Padding, Container (고정값) | 항상 const |
| 커스텀 StatelessWidget | 가능하면 const |
| 동적 데이터 위젯 | const 불가 |

### Lint 설정

```yaml
# analysis_options.yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
```

---

## ✅ 2. Selector 패턴 (필수)

> **Flutter 공식 권장**: Consumer 대신 Selector로 세분화된 rebuild

### 기본 패턴

```dart
// ❌ Bad - 전체 상태 구독 (모든 변경에 리빌드)
Consumer<[Feature]ViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.state.title);
  },
)

// ✅ Good - 필요한 상태만 구독
Selector<[Feature]ViewModel, String>(
  selector: (_, vm) => vm.state.title,
  builder: (context, title, child) {
    return Text(title);
  },
)
```

### 복수 필드 구독 (Record 사용)

```dart
Selector<[Feature]ViewModel, ({
  List<Item> items,
  bool isLoading,
  String? errorMessage,
})>(
  selector: (_, vm) => (
    items: vm.state.items,
    isLoading: vm.state.isLoading,
    errorMessage: vm.state.errorMessage,
  ),
  builder: (context, data, child) {
    if (data.isLoading) {
      return const CircularProgressIndicator();
    }

    if (data.errorMessage != null) {
      return Text(data.errorMessage!);
    }

    return ListView.builder(
      itemCount: data.items.length,
      itemBuilder: (context, index) => ItemCard(item: data.items[index]),
    );
  },
)
```

### 사용 기준

| 상황 | 권장 |
|------|------|
| 단일 필드만 필요 | `Selector<VM, Type>` |
| 2~5개 필드 필요 | `Selector<VM, ({...})>` (Record) |
| 전체 상태 필요 | `Consumer<VM>` |
| 메서드만 호출 | `context.read<VM>().method()` |

---

## ✅ 3. ListView.builder (필수)

> **Flutter 공식 권장**: 화면에 보이는 아이템만 생성 (Lazy Loading)

### 기본 패턴

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

### 최적화 옵션

```dart
ListView.builder(
  // 미리 캐싱할 영역 (기본값: 250)
  cacheExtent: 300,

  // 자동 유지 비활성화 (메모리 절약)
  addAutomaticKeepAlives: false,

  // 리페인트 경계 활성화 (스크롤 성능)
  addRepaintBoundaries: true,

  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(
      key: ValueKey(items[index].id),  // 고유 키 지정
      item: items[index],
    );
  },
)
```

### GridView도 동일

```dart
// ✅ Good
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

---

## ✅ 4. Opacity 최적화

> **Flutter 공식 권장**: Opacity 위젯은 saveLayer() 호출로 비용이 높음

### 애니메이션에서

```dart
// ❌ Bad - Opacity 직접 사용
Opacity(
  opacity: animationValue,
  child: MyWidget(),
)

// ✅ Good - AnimatedOpacity 사용
AnimatedOpacity(
  opacity: animationValue,
  duration: const Duration(milliseconds: 300),
  child: MyWidget(),
)
```

### 이미지 페이드

```dart
// ✅ Good - FadeInImage 사용
FadeInImage(
  placeholder: AssetImage('assets/placeholder.png'),
  image: NetworkImage(imageUrl),
)

// ✅ Good - CachedNetworkImage 사용
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### 반투명 색상

```dart
// ❌ Bad - Opacity로 감싸기
Opacity(
  opacity: 0.5,
  child: Container(color: Colors.black),
)

// ✅ Good - 직접 반투명 색상 사용
Container(color: Colors.black.withOpacity(0.5))
```

---

## ✅ 5. build() 메서드 최적화

> **Flutter 공식 권장**: build()는 자주 호출되므로 비용이 높은 작업 피하기

### 규칙

```dart
class MyWidget extends StatelessWidget {
  // ❌ Bad - build() 안에서 계산
  @override
  Widget build(BuildContext context) {
    final expensiveResult = computeExpensiveValue();  // 매번 실행됨
    return Text(expensiveResult);
  }
}

// ✅ Good - 외부에서 계산하거나 ViewModel에서 처리
class MyWidget extends StatelessWidget {
  final String precomputedValue;

  const MyWidget({required this.precomputedValue});

  @override
  Widget build(BuildContext context) {
    return Text(precomputedValue);
  }
}
```

---

## ✅ 6. RepaintBoundary

> 복잡한 위젯을 분리하여 불필요한 repaint 방지

### 적용 위치

```dart
// 리스트 아이템
ListView.builder(
  itemBuilder: (context, index) {
    return RepaintBoundary(
      child: ComplexItemCard(item: items[index]),
    );
  },
)

// 애니메이션 영역
RepaintBoundary(
  child: AnimatedWidget(),
)

// 복잡한 차트/그래프
RepaintBoundary(
  child: ComplexChartWidget(),
)
```

---

## ✅ 7. 이미지 최적화

### CachedNetworkImage 필수 사용

```dart
CachedNetworkImage(
  imageUrl: imageUrl,

  // 메모리 캐시 너비 제한 (필수)
  memCacheWidth: 300,  // 썸네일: 300, 상세: 600

  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,

  placeholder: (context, url) => Container(
    color: Colors.grey[200],
    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
  ),

  errorWidget: (context, url, error) => Container(
    color: Colors.grey[200],
    child: const Icon(Icons.image_not_supported),
  ),
)
```

### memCacheWidth 권장값

| 용도 | memCacheWidth |
|------|---------------|
| 리스트 썸네일 | 300 |
| 카드 이미지 | 400 |
| 상세 이미지 | 600 |

---

## ✅ 8. Dispose 패턴 (필수)

> 메모리 누수 방지 - ViewModel에서 관리

```dart
class [Feature]ViewModel extends ChangeNotifier {
  final TextEditingController textController = TextEditingController();
  StreamSubscription? _subscription;
  Timer? _debounceTimer;

  @override
  void dispose() {
    textController.dispose();
    _subscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
```

---

## ✅ 체크리스트

### 위젯 최적화
- [ ] const 생성자 사용
- [ ] Consumer → Selector 변경
- [ ] ListView() → ListView.builder() 변경
- [ ] Opacity → AnimatedOpacity/FadeInImage 변경

### 메모리 최적화
- [ ] Controller dispose 확인
- [ ] StreamSubscription cancel 확인
- [ ] Timer cancel 확인
- [ ] CachedNetworkImage memCacheWidth 설정

### 빌드 최적화
- [ ] build() 내 비용 높은 연산 제거
- [ ] RepaintBoundary 적용 (복잡한 위젯)

---

## ✅ 참고 자료

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Rendering Performance](https://docs.flutter.dev/perf/rendering-performance)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)

---
