# 💾 캐싱 전략 설계 가이드

> ⚠️ **상태**: 이 문서는 향후 구현 예정인 캐싱 전략을 설명합니다.
> 현재 버전에서는 구현되지 않았으며, 성능 최적화가 필요할 때 참고용으로 사용하세요.

---

## ✅ 목적

**Clean Architecture**에서 DataSource 계층에 캐싱을 적용하여 성능 향상과 비용 절약을 달성합니다.

- Repository는 변경 없이 캐싱 기능을 투명하게 제공
- 사용자별 데이터 격리와 보안 유지
- TTL 기반 자동 만료와 수동 무효화 지원
- 메모리 사용량 제한으로 안정성 보장

---

## ✅ 설계 원칙

### Decorator 패턴
```dart
// 기존 DataSource를 래핑하여 캐싱 기능 추가
class CachedDataSource implements DataSource {
  final DataSource _remoteDataSource;

  // 캐싱 로직 구현
}
```

### 사용자별 캐시 분리
```dart
// 캐시 키: {userId}_{dataKey}
String _getUserCacheKey(String userId, String baseKey) {
  return '${userId}_$baseKey';
}
```

### TTL 기반 자동 만료
```dart
static const Duration _cacheExpiry = Duration(minutes: 5);

bool _isValidCache(String key) {
  final timestamp = _cacheTimestamps[key];
  return DateTime.now().difference(timestamp) <= _cacheExpiry;
}
```

---

## ✅ 캐시 구조

### 계층별 캐시 전략

| 계층 | 캐시 대상 | TTL | 크기 제한 |
|------|-----------|-----|-----------|
| **월별 데이터** | 자주 조회되는 월별 리스트 | 5분 | 50개월 |
| **개별 아이템** | 상세 조회된 단일 아이템 | 무제한 | 100개 |
| **실시간 데이터** | 캐싱 안함 | - | - |

### 캐시 키 네이밍

```dart
// 월별 데이터: {userId}_{year}_{month}
final monthKey = _getUserCacheKey(userId, '${year}_$month');

// 개별 아이템: {userId}_{itemId}
final itemKey = _getUserCacheKey(userId, itemId);
```

---

## ✅ 캐시 무효화 전략

### 자동 무효화
```dart
// CRUD 작업 시 관련 캐시 자동 무효화
Future<void> addItem(ItemDto item) async {
  await _remoteDataSource.addItem(item);

  // 해당 월 캐시 무효화
  _invalidateMonthCache(userId, item.year, item.month);

  // 개별 캐시에 추가
  _individualCache[itemKey] = item;
}
```

### 사용자 변경 시 캐시 클리어
```dart
void _listenToAuthChanges() {
  authService.onAuthStateChanged.listen((user) {
    if (_currentUserId != user?.id) {
      clearCache(); // 전체 캐시 정리
      _currentUserId = user?.id;
    }
  });
}
```

---

## ✅ 메모리 관리

### 크기 제한
```dart
void _cacheData(String key, List<ItemDto> data) {
  // 최대 크기 초과 시 가장 오래된 캐시 제거
  if (_cache.length >= _maxCacheSize) {
    final oldestKey = _findOldestCacheKey();
    _invalidateCache(oldestKey);
  }

  _cache[key] = data;
  _timestamps[key] = DateTime.now();
}
```

### 주기적 정리
```dart
void _scheduleCleanup() {
  Timer.periodic(Duration(minutes: 10), (_) {
    _removeExpiredCache();
  });
}
```

---

## ✅ 인터페이스 설계

### Auth Provider 추상화
```dart
abstract class AuthProvider {
  String? get currentUserId;
  Stream<String?> get onAuthStateChanged;
}

// Firebase 구현
class FirebaseAuthProvider implements AuthProvider {
  @override
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Stream<String?> get onAuthStateChanged =>
    FirebaseAuth.instance.authStateChanges().map((user) => user?.uid);
}
```

### 캐시 전략 인터페이스
```dart
abstract class CacheStrategy<T> {
  bool shouldCache(String operation, T? data);
  Duration getCacheDuration(String operation);
  String generateCacheKey(String userId, Map<String, dynamic> params);
}
```

---

## ✅ 구현 패턴

### Generic Cached DataSource
```dart
class CachedDataSource<T> implements DataSource<T> {
  final DataSource<T> _remoteDataSource;
  final AuthProvider _authProvider;
  final CacheStrategy<T> _strategy;

  final Map<String, List<T>> _listCache = {};
  final Map<String, T> _itemCache = {};
  final Map<String, DateTime> _timestamps = {};

  Future<List<T>> getList(Map<String, dynamic> params) async {
    final userId = _authProvider.currentUserId;
    if (userId == null) return _remoteDataSource.getList(params);

    final cacheKey = _strategy.generateCacheKey(userId, params);

    if (_isValidCache(cacheKey)) {
      return _listCache[cacheKey]!;
    }

    final data = await _remoteDataSource.getList(params);
    if (_strategy.shouldCache('getList', data)) {
      _cacheList(cacheKey, data);
    }

    return data;
  }
}
```

---

## ✅ 캐싱 패턴의 장점

1. **성능 향상**: 반복 조회 시 응답 시간 단축
2. **비용 절약**: 외부 API 호출 횟수 감소
3. **사용자 경험**: 빠른 데이터 로딩
4. **확장성**: 다양한 DataSource에 적용 가능
5. **보안성**: 사용자별 데이터 격리

---

## ✅ 모니터링

### 캐시 통계
```dart
Map<String, dynamic> getCacheStats() {
  return {
    'listCache': _listCache.length,
    'itemCache': _itemCache.length,
    'hitRate': _calculateHitRate(),
    'memoryUsage': _calculateMemoryUsage(),
  };
}
```

### 캐시 효율성 측정
```dart
class CacheMetrics {
  int hits = 0;
  int misses = 0;

  double get hitRate => hits / (hits + misses);

  void recordHit() => hits++;
  void recordMiss() => misses++;
}
```

---