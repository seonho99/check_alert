# 🔥 Firebase 캐싱 구현 가이드

> Lifetime Ledger에서 사용하는 실제 Firebase 캐싱 구현

---

## ✅ 개요

Firebase Firestore + Firebase Auth 환경에서 **CachedHistoryDataSource**를 구현하여:
- **5분 TTL** 메모리 캐싱으로 Firestore 읽기 비용 절약
- **Firebase Auth 기반** 사용자별 캐시 분리
- **실시간 무효화**로 데이터 일관성 보장

---

## ✅ 실제 구현

### CachedHistoryDataSource

```dart
class CachedHistoryDataSource implements HistoryDataSource {
  final HistoryDataSource _remoteDataSource;

  // 캐시 저장소
  final Map<String, List<HistoryDto>> _monthlyCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, HistoryDto> _individualCache = {};

  // 캐시 설정
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static const int _maxCacheSize = 50; // 최대 50개월

  CachedHistoryDataSource({
    required HistoryDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource {
    _listenToAuthChanges();
  }
}
```

### Firebase Auth 통합

```dart
/// Firebase Auth 상태 변화 감지
void _listenToAuthChanges() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    final newUserId = user?.uid;

    // 사용자가 바뀌었을 때 캐시 정리
    if (_currentCachedUserId != null && _currentCachedUserId != newUserId) {
      clearCache();
    }

    _currentCachedUserId = newUserId;

    if (newUserId == null) {
      clearCache(); // 로그아웃 시 전체 정리
    }
  });
}

/// Firebase Auth 기반 캐시 키 생성
String _getUserCacheKey(String baseKey) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return ''; // 로그인되지 않은 경우 캐싱 안함
  return '${uid}_$baseKey';
}
```

---

## ✅ 캐싱 전략

### 월별 데이터 캐싱

```dart
@override
Future<List<HistoryDto>> getHistoriesByMonth(int year, int month) async {
  final userCacheKey = _getUserCacheKey('${year}_$month');

  // 로그인되지 않은 경우 캐시 사용하지 않음
  if (userCacheKey.isEmpty) {
    return _remoteDataSource.getHistoriesByMonth(year, month);
  }

  // 캐시 확인
  if (_isValidCache(userCacheKey)) {
    print('✅ 월별 캐시 히트: $userCacheKey');
    return _monthlyCache[userCacheKey]!;
  }

  print('📡 월별 캐시 미스: $userCacheKey - Firestore에서 가져옴');

  // Firestore에서 데이터 가져오기
  final histories = await _remoteDataSource.getHistoriesByMonth(year, month);

  // 캐시에 저장
  _cacheData(userCacheKey, histories);

  return histories;
}
```

### 캐싱하지 않는 작업

```dart
@override
Future<List<HistoryDto>> getHistories() async {
  // 전체 조회는 캐싱하지 않음 (데이터 크기가 크고 변경 빈도 높음)
  return _remoteDataSource.getHistories();
}

@override
Future<({List<HistoryDto> histories, DocumentSnapshot? lastDocument})>
    getHistoriesPaginated({
  DocumentSnapshot? lastDocument,
  int limit = 20,
}) async {
  // 페이지네이션은 캐싱하지 않음 (복잡성 때문)
  return _remoteDataSource.getHistoriesPaginated(
    lastDocument: lastDocument,
    limit: limit,
  );
}

@override
Stream<List<HistoryDto>> watchHistoriesByMonth(int year, int month) {
  // 실시간 리스너는 캐싱하지 않고 직접 전달
  // (실시간 데이터는 항상 최신이어야 하므로)
  return _remoteDataSource.watchHistoriesByMonth(year, month);
}
```

---

## ✅ 캐시 무효화

### CRUD 작업 시 자동 무효화

```dart
@override
Future<void> addHistory(HistoryDto history) async {
  await _remoteDataSource.addHistory(history);

  // 해당 월 캐시 무효화
  if (history.date != null) {
    final monthKey = '${history.date!.year}_${history.date!.month}';
    final userMonthKey = _getUserCacheKey(monthKey);
    if (userMonthKey.isNotEmpty) {
      _invalidateMonthCache(userMonthKey);
      print('🗑️ 월별 캐시 무효화: $userMonthKey');
    }
  }

  // 개별 캐시에 추가
  if (history.id != null) {
    final userKey = _getUserCacheKey(history.id!);
    if (userKey.isNotEmpty) {
      _individualCache[userKey] = history;
    }
  }
}

@override
Future<void> deleteHistory(String id) async {
  // 삭제 전에 날짜 정보 확보
  HistoryDto? historyToDelete;
  try {
    final userKey = _getUserCacheKey(id);
    if (userKey.isNotEmpty && _individualCache.containsKey(userKey)) {
      historyToDelete = _individualCache[userKey];
    } else {
      historyToDelete = await _remoteDataSource.getHistoryById(id);
    }
  } catch (e) {
    print('⚠️ 삭제할 항목 정보 가져오기 실패: $e');
  }

  // Firestore에서 삭제
  await _remoteDataSource.deleteHistory(id);

  // 캐시 정리
  final userKey = _getUserCacheKey(id);
  if (userKey.isNotEmpty) {
    _individualCache.remove(userKey);

    // 해당 월 캐시 무효화
    if (historyToDelete?.date != null) {
      final monthKey = '${historyToDelete!.date!.year}_${historyToDelete.date!.month}';
      final userMonthKey = _getUserCacheKey(monthKey);
      if (userMonthKey.isNotEmpty) {
        _invalidateMonthCache(userMonthKey);
      }
    }
  }
}
```

---

## ✅ 메모리 관리

### 캐시 크기 제한

```dart
void _cacheData(String key, List<HistoryDto> data) {
  // 최대 50개월 데이터만 캐싱
  if (_monthlyCache.length >= _maxCacheSize) {
    final oldestKey = _cacheTimestamps.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
        .key;
    _invalidateMonthCache(oldestKey);
  }

  _monthlyCache[key] = data;
  _cacheTimestamps[key] = DateTime.now();

  print('💾 캐시 저장: $key (${data.length}개 항목)');
}

bool _isValidCache(String key) {
  if (!_monthlyCache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
    return false;
  }

  final timestamp = _cacheTimestamps[key]!;
  final isExpired = DateTime.now().difference(timestamp) > _cacheExpiry;

  if (isExpired) {
    _invalidateMonthCache(key);
    return false;
  }

  return true;
}
```

### 사용자별 캐시 분리

```dart
void clearUserCache(String userId) {
  final keysToRemove = <String>[];

  // 월별 캐시에서 해당 사용자 키 찾기
  for (String key in _monthlyCache.keys) {
    if (key.startsWith('${userId}_')) {
      keysToRemove.add(key);
    }
  }

  for (String key in keysToRemove) {
    _monthlyCache.remove(key);
    _cacheTimestamps.remove(key);
  }

  // 개별 캐시 정리
  final individualKeysToRemove = <String>[];
  for (String key in _individualCache.keys) {
    if (key.startsWith('${userId}_')) {
      individualKeysToRemove.add(key);
    }
  }

  for (String key in individualKeysToRemove) {
    _individualCache.remove(key);
  }

  print('🧹 사용자 캐시 정리 완료: $userId');
}
```

---

## ✅ 모니터링 및 디버깅

### 캐시 통계

```dart
Map<String, dynamic> getCacheStats() {
  return {
    'monthlyCache': _monthlyCache.length,
    'individualCache': _individualCache.length,
    'totalCachedItems': _monthlyCache.values.fold(0, (sum, list) => sum + list.length),
    'currentUser': _currentCachedUserId,
  };
}
```

### 로깅

```dart
// 캐시 히트
print('✅ 월별 캐시 히트: $userCacheKey');

// 캐시 미스
print('📡 월별 캐시 미스: $userCacheKey - Firestore에서 가져옴');

// 캐시 무효화
print('🗑️ 월별 캐시 무효화: $userMonthKey');

// 캐시 정리
print('🧹 전체 캐시 정리 완료');
```

---

## ✅ 성능 최적화 효과

### Firestore 읽기 비용 절약
- **월별 조회**: 5분 TTL로 반복 조회 시 Firestore 호출 없음
- **개별 조회**: 한 번 로드된 아이템은 메모리에서 즉시 반환
- **사용자 격리**: 다중 사용자 환경에서도 데이터 보안 유지

### 사용자 경험 향상
- **빠른 응답**: 캐시 히트 시 밀리초 단위 응답
- **오프라인 대응**: 네트워크 오류 시 캐시된 데이터 제공 가능
- **부드러운 UX**: 페이지 전환 시 즉시 데이터 표시

---

## ✅ Provider 등록

```dart
// DI 컨테이너에 캐시된 DataSource 등록
@module
abstract class DataSourceModule {
  @singleton
  HistoryDataSource provideHistoryDataSource(
    HistoryFirebaseDataSource remoteDataSource,
  ) {
    return CachedHistoryDataSource(
      remoteDataSource: remoteDataSource,
    );
  }
}
```

---

## ✅ 향후 개선 방안

1. **영구 캐시**: SharedPreferences나 SQLite로 앱 재시작 후에도 캐시 유지
2. **압축**: 큰 데이터의 경우 압축해서 메모리 사용량 줄이기
3. **LRU 캐시**: 가장 오래 사용되지 않은 데이터 우선 제거
4. **배치 무효화**: 여러 변경사항을 모아서 한 번에 캐시 무효화

---