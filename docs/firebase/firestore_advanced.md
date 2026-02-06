# 🔥 Firestore 고급 패턴 가이드

> Firebase 공식 문서 기반 고급 Firestore 패턴

---

## ✅ 목적

Firestore의 **고급 기능**과 **성능 최적화** 패턴을 설명합니다.

- 분산 카운터 (고성능 쓰기)
- 오프라인 캐싱 설정
- 트랜잭션과 배치 쓰기
- 쿼리 최적화

---

## ✅ 1. 분산 카운터 패턴

> 고성능 쓰기 시나리오 (좋아요, 조회수 등)

### 문제

Firestore는 단일 문서에 **초당 1회 쓰기** 제한이 있습니다.
인기 콘텐츠의 좋아요/조회수는 이 제한을 초과할 수 있습니다.

### 해결: Sharded Counter

```dart
// 분산 카운터 구조
// counters/{counterId}/shards/{shardId}

class DistributedCounter {
  final FirebaseFirestore _firestore;
  final String _counterId;
  final int _numShards;

  DistributedCounter({
    required FirebaseFirestore firestore,
    required String counterId,
    int numShards = 10,
  }) : _firestore = firestore,
       _counterId = counterId,
       _numShards = numShards;

  /// 카운터 초기화
  Future<void> initialize() async {
    final batch = _firestore.batch();
    final counterRef = _firestore.collection('counters').doc(_counterId);

    for (int i = 0; i < _numShards; i++) {
      final shardRef = counterRef.collection('shards').doc('$i');
      batch.set(shardRef, {'count': 0});
    }

    await batch.commit();
  }

  /// 카운터 증가 (랜덤 샤드 선택)
  Future<void> increment() async {
    final shardId = Random().nextInt(_numShards);
    final shardRef = _firestore
        .collection('counters')
        .doc(_counterId)
        .collection('shards')
        .doc('$shardId');

    await shardRef.update({
      'count': FieldValue.increment(1),
    });
  }

  /// 전체 카운트 조회 (모든 샤드 합산)
  Future<int> getCount() async {
    final shards = await _firestore
        .collection('counters')
        .doc(_counterId)
        .collection('shards')
        .get();

    int totalCount = 0;
    for (final doc in shards.docs) {
      totalCount += (doc.data()['count'] as int? ?? 0);
    }

    return totalCount;
  }
}
```

### 사용 예시

```dart
// 좋아요 카운터
final likeCounter = DistributedCounter(
  firestore: FirebaseFirestore.instance,
  counterId: 'post_${postId}_likes',
  numShards: 10,  // 초당 10회 쓰기 가능
);

// 좋아요 증가
await likeCounter.increment();

// 좋아요 수 조회
final likeCount = await likeCounter.getCount();
```

---

## ✅ 2. 오프라인 캐싱 설정

> Firestore는 기본적으로 오프라인 캐싱 활성화

### 캐시 크기 설정

```dart
// main.dart 또는 Firebase 초기화 시
FirebaseFirestore.instance.settings = const Settings(
  // 캐시 크기 설정 (기본값: 40MB)
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,  // 무제한

  // 또는 특정 크기 지정
  // cacheSizeBytes: 100 * 1024 * 1024,  // 100MB
);
```

### 오프라인 우선 조회

```dart
// 캐시 우선 조회 (오프라인 지원)
final snapshot = await _firestore
    .collection('[collection]')
    .get(const GetOptions(source: Source.cache));

// 서버 우선 조회 (최신 데이터 필요 시)
final snapshot = await _firestore
    .collection('[collection]')
    .get(const GetOptions(source: Source.server));

// 기본값: 서버 시도 → 실패 시 캐시
final snapshot = await _firestore
    .collection('[collection]')
    .get();
```

### 오프라인 상태 감지

```dart
// 네트워크 상태에 따른 처리
FirebaseFirestore.instance.snapshotsInSync().listen((_) {
  // 동기화 완료 시 호출
  print('Firestore synced with server');
});
```

---

## ✅ 3. 트랜잭션 패턴

> 읽기 후 쓰기가 필요한 원자적 작업

### 기본 트랜잭션

```dart
Future<void> transferPoints({
  required String fromUserId,
  required String toUserId,
  required int points,
}) async {
  await _firestore.runTransaction((transaction) async {
    // 1. 읽기 먼저 (필수)
    final fromDoc = await transaction.get(
      _firestore.collection('users').doc(fromUserId),
    );
    final toDoc = await transaction.get(
      _firestore.collection('users').doc(toUserId),
    );

    final fromPoints = fromDoc.data()?['points'] as int? ?? 0;
    final toPoints = toDoc.data()?['points'] as int? ?? 0;

    // 2. 검증
    if (fromPoints < points) {
      throw Exception('포인트가 부족합니다');
    }

    // 3. 쓰기 (읽기 후에만 가능)
    transaction.update(
      _firestore.collection('users').doc(fromUserId),
      {'points': fromPoints - points},
    );
    transaction.update(
      _firestore.collection('users').doc(toUserId),
      {'points': toPoints + points},
    );
  });
}
```

### 주의사항

```dart
// ⚠️ 트랜잭션 내에서 하지 말아야 할 것
await _firestore.runTransaction((transaction) async {
  // ❌ Bad - 앱 상태 직접 수정
  setState(() { ... });  // 트랜잭션 재시도 시 문제 발생

  // ❌ Bad - 트랜잭션 외부 비동기 작업
  await sendEmail();  // 트랜잭션과 무관한 작업

  // ✅ Good - 트랜잭션 결과만 반환
  return result;
});

// 트랜잭션 완료 후 상태 업데이트
final result = await _firestore.runTransaction(...);
setState(() { ... });  // 트랜잭션 완료 후 처리
```

---

## ✅ 4. 배치 쓰기

> 여러 독립적인 쓰기를 원자적으로 처리

```dart
Future<void> createUserWithProfile({
  required String userId,
  required UserDto user,
  required ProfileDto profile,
}) async {
  final batch = _firestore.batch();

  // 여러 문서 동시 쓰기
  batch.set(
    _firestore.collection('users').doc(userId),
    user.toFirestore(),
  );
  batch.set(
    _firestore.collection('profiles').doc(userId),
    profile.toFirestore(),
  );
  batch.set(
    _firestore.collection('settings').doc(userId),
    {'theme': 'light', 'notifications': true},
  );

  // 원자적 커밋 (전부 성공 또는 전부 실패)
  await batch.commit();
}
```

### 트랜잭션 vs 배치 쓰기

| 특성 | 트랜잭션 | 배치 쓰기 |
|------|---------|----------|
| **읽기** | 가능 | 불가 |
| **용도** | 읽기 후 쓰기 | 독립적 다중 쓰기 |
| **재시도** | 자동 재시도 | 없음 |
| **오프라인** | 불가 | 가능 |
| **성능** | 느림 | 빠름 |

---

## ✅ 5. 쿼리 최적화

### 복합 인덱스 활용

```dart
// 복합 쿼리 (인덱스 필요)
final query = _firestore
    .collection('posts')
    .where('userId', isEqualTo: userId)
    .where('category', isEqualTo: 'tech')
    .orderBy('createdAt', descending: true)
    .limit(20);

// Firebase Console에서 인덱스 생성 필요
// 또는 쿼리 실행 시 에러 메시지의 링크 클릭
```

### 쿼리 제한사항

```dart
// ❌ 불가 - 서로 다른 필드에 범위 필터
.where('price', isGreaterThan: 100)
.where('rating', isLessThan: 4)

// ❌ 불가 - OR 조건 (별도 쿼리 후 병합)
.where('status', whereIn: ['active', 'pending'])

// ✅ 가능 - 같은 필드에 범위 필터
.where('price', isGreaterThan: 100)
.where('price', isLessThan: 500)

// ✅ 가능 - 등호 + 범위 조합
.where('category', isEqualTo: 'tech')
.where('price', isGreaterThan: 100)
```

### 페이지네이션

```dart
// 커서 기반 페이지네이션 (권장)
DocumentSnapshot? lastDocument;

Future<List<[Model]Dto>> getNextPage() async {
  var query = _firestore
      .collection('[collection]')
      .orderBy('createdAt', descending: true)
      .limit(20);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument!);
  }

  final snapshot = await query.get();

  if (snapshot.docs.isNotEmpty) {
    lastDocument = snapshot.docs.last;
  }

  return snapshot.docs.map((doc) => [Model]Dto.fromFirestore(doc)).toList();
}
```

---

## ✅ 체크리스트

### 고성능 쓰기
- [ ] 인기 콘텐츠에 분산 카운터 적용
- [ ] 배치 쓰기로 다중 문서 처리

### 오프라인 지원
- [ ] 캐시 크기 적절히 설정
- [ ] 오프라인 우선 조회 고려

### 쿼리 최적화
- [ ] 복합 인덱스 생성
- [ ] limit() 항상 사용
- [ ] 커서 기반 페이지네이션

---

## ✅ 참고 자료

- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Distributed Counters](https://firebase.google.com/docs/firestore/solutions/counters)
- [FlutterFire Firestore](https://firebase.flutter.dev/docs/firestore/usage/)

---
