# 🌐 DataSource 설계 가이드

## 🎯 목적

DataSource는 **Clean Architecture Data Layer**의 핵심으로, 외부 데이터와의 연결점 역할을 하며,
Firebase 호출, API 작업, 캐싱과 같은 **실제 I/O 작업**을 수행합니다.
Repository Implementation에서 이 계층을 통해 데이터를 요청하고 예외 상황을 처리합니다.

---

## 🧱 설계 원칙

- 항상 **인터페이스 정의 → Firebase 구현체 분리**
- **인터페이스는 Firebase 의존성 제거**: 순수 Dart 타입만 사용
- Firebase 구현체는 `{Name}FirebaseDataSourceImpl` 명명 규칙 사용
- **Firestore 변환은 구현체에서**: `_documentToDto()`, `_dtoToFirestore()` 헬퍼 메서드 사용
- **예외는 그대로 throw**, Repository Implementation에서 Result로 변환
- **페이지네이션은 Record 반환**: `({List<Dto> items, String? lastDocumentId})`

---

## 📁 파일 구조

```text
lib/data/datasource/
├── auth_datasource.dart                        # Auth 인터페이스
├── auth_firebase_datasource_impl.dart          # Auth Firebase 구현체
├── history_datasource.dart                     # History 인터페이스
├── history_firebase_datasource_impl.dart       # History Firebase 구현체
├── budget_datasource.dart                      # Budget 인터페이스
└── budget_firebase_datasource_impl.dart        # Budget Firebase 구현체
```

---

## ✅ DataSource 인터페이스 (실제 구현)

> **인터페이스는 Firebase 의존성 없이** 순수 Dart 타입만 사용

```dart
import '../dto/history_dto.dart';

/// History DataSource 인터페이스 - Firebase 의존성 제거
abstract class HistoryDataSource {
  Future<List<HistoryDto>> getHistories(String userUid);
  Future<HistoryDto> getHistoryById(String userUid, String id);
  Future<void> addHistory(String userUid, HistoryDto history);
  Future<void> updateHistory(String userUid, HistoryDto history);
  Future<void> deleteHistory(String userUid, String id);

  // 월별 조회
  Future<List<HistoryDto>> getHistoriesByMonth(String userUid, int year, int month);

  // ✅ 페이지네이션 - Record 반환 (Firebase 의존성 제거)
  Future<({List<HistoryDto> histories, String? lastDocumentId})> getHistoriesPaginated({
    required String userUid,
    String? lastDocumentId,
    int limit = 20,
  });
}
```

---

## ✅ Firebase DataSource 구현체 (실제 구현)

> **Firestore 변환 로직을 헬퍼 메서드로 캡슐화**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../dto/history_dto.dart';
import 'history_datasource.dart';

/// Firebase Firestore 기반 History DataSource 구현체
class HistoryFirebaseDataSourceImpl implements HistoryDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'histories';

  HistoryFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // ========================================
  // ✅ Firestore 변환 헬퍼 메서드
  // ========================================

  /// Firestore Document를 HistoryDto로 변환
  HistoryDto _documentToDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HistoryDto(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      amount: data['amount'],
      type: data['type'],
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],  // ✨ denormalized
      date: (data['date'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// HistoryDto를 Firestore Map으로 변환
  Map<String, dynamic> _dtoToFirestore(HistoryDto dto) {
    return {
      'userId': dto.userId,
      'title': dto.title,
      'amount': dto.amount,
      'type': dto.type,
      'categoryId': dto.categoryId,
      'categoryName': dto.categoryName,
      'date': dto.date != null ? Timestamp.fromDate(dto.date!) : null,
      'createdAt': dto.createdAt != null ? Timestamp.fromDate(dto.createdAt!) : null,
      'updatedAt': dto.updatedAt != null ? Timestamp.fromDate(dto.updatedAt!) : null,
    };
  }

  // ========================================
  // CRUD 메서드
  // ========================================

  @override
  Future<List<HistoryDto>> getHistories(String userUid) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userUid)
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToDto(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> addHistory(String userUid, HistoryDto history) async {
    try {
      final historyWithUser = history.copyWith(userId: userUid);
      final historyData = _dtoToFirestore(historyWithUser);

      await _firestore
          .collection(_collection)
          .doc(history.id)
          .set(historyData);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  // ========================================
  // ✅ 페이지네이션 - Record 반환
  // ========================================

  @override
  Future<({List<HistoryDto> histories, String? lastDocumentId})> getHistoriesPaginated({
    required String userUid,
    String? lastDocumentId,
    int limit = 20,
  }) async {
    try {
      var query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userUid)
          .orderBy('date', descending: true)
          .limit(limit);

      // 커서 기반 페이지네이션
      if (lastDocumentId != null) {
        final lastDoc = await _firestore
            .collection(_collection)
            .doc(lastDocumentId)
            .get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final querySnapshot = await query.get();

      return (
        histories: querySnapshot.docs.map((doc) => _documentToDto(doc)).toList(),
        lastDocumentId: querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last.id : null,
      );
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }
}
```

---

## 🎯 핵심 패턴

### 헬퍼 메서드 패턴
```dart
// ✅ Firestore 변환은 DataSource 구현체에서 처리
HistoryDto _documentToDto(DocumentSnapshot doc) { ... }
Map<String, dynamic> _dtoToFirestore(HistoryDto dto) { ... }

// DTO는 JSON만 처리 (fromJson/toJson)
```

### 예외 처리 전략
```dart
// DataSource에서는 예외를 그대로 throw
on FirebaseException catch (e) {
  throw ServerException('Firebase 오류: ${e.message}');
}

// Repository에서 Result<T> 패턴으로 변환
catch (e) {
  return Result.error(ServerFailure(e.toString()));
}
```

### 페이지네이션 Record 반환
```dart
// ✅ Firebase DocumentSnapshot 대신 String ID 반환
Future<({List<HistoryDto> histories, String? lastDocumentId})> getHistoriesPaginated({
  required String userUid,
  String? lastDocumentId,  // DocumentSnapshot 대신 ID 사용
  int limit = 20,
});
```

### 의존성 주입 (Provider)
```dart
// core/di/data_providers.dart
List<Provider> buildDataProviders() {
  return [
    Provider<HistoryDataSource>(
      create: (context) => HistoryFirebaseDataSourceImpl(
        firestore: context.read<FirebaseFirestore>(),
      ),
    ),
  ];
}
```

> 📎 Repository 구현은 [repository_impl.md](repository_impl.md) 참조

---

## ✅ 핵심 요약

- **인터페이스는 Firebase 의존성 제거**: 순수 Dart 타입만 사용
- **Firestore 변환은 구현체에서**: `_documentToDto()`, `_dtoToFirestore()` 헬퍼 메서드
- **페이지네이션은 Record 반환**: `({List<Dto> items, String? lastDocumentId})`
- **예외는 throw**: Repository에서 Result로 변환

---
