# CheckRecordModel (체크 기록) 전체 설계

> **참조**: [docs/logic/](../logic/) 가이드의 Clean Architecture + MVVM + Provider + Freezed 3.0 패턴 준수

---

## 1. Domain Model (Entity)

> 파일: `lib/domain/model/check_record_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_record_model.freezed.dart';

/// 체크 기록 도메인 모델 (순수한 데이터 구조체)
///
/// Clean Architecture 원칙에 따라:
/// - 검증 로직 없음 (UseCase에서 처리)
/// - 하루에 하나의 Task에 대해 하나의 CheckRecord만 존재
/// - date는 시간 정보 없이 날짜만 저장 (yyyy-MM-dd 00:00:00)
@freezed
sealed class CheckRecordModel with _$CheckRecordModel {
  const factory CheckRecordModel({
    required String id,             // 기록 고유 ID
    required String userId,         // 사용자 UID
    required String taskId,         // 체크 항목 ID (TaskModel.id)
    required DateTime date,         // 체크 날짜 (시간 없음, 날짜만)
    required bool isCompleted,      // 완료 상태
    DateTime? completedAt,          // 완료 시각 (isCompleted=true일 때)
    required DateTime createdAt,    // 생성 일시
    required DateTime updatedAt,    // 수정 일시
  }) = _CheckRecordModel;
}
```

### Extension (편의 메서드)

```dart
/// CheckRecordModel 편의 확장 (단순한 getter만)
extension CheckRecordModelExtension on CheckRecordModel {
  /// 오늘 기록인지 확인
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// 날짜 포맷 (yyyy-MM-dd)
  String get dateFormatted =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// 완료 시각 포맷 (HH:mm)
  String? get completedAtFormatted {
    if (completedAt == null) return null;
    return '${completedAt!.hour.toString().padLeft(2, '0')}:${completedAt!.minute.toString().padLeft(2, '0')}';
  }
}
```

---

## 2. DTO (Data Transfer Object)

> 파일: `lib/data/dto/check_record_model_dto.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'check_record_model_dto.g.dart';

/// CheckRecordModel DTO (JsonSerializable)
/// 모든 필드 nullable - 외부 데이터의 불완전성 대응
@JsonSerializable()
class CheckRecordModelDto {
  final String? id;
  final String? userId;
  final String? taskId;
  final DateTime? date;
  final bool? isCompleted;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CheckRecordModelDto({
    this.id,
    this.userId,
    this.taskId,
    this.date,
    this.isCompleted,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// JSON serialization (auto-generated)
  factory CheckRecordModelDto.fromJson(Map<String, dynamic> json) =>
      _$CheckRecordModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckRecordModelDtoToJson(this);

  /// copyWith 메서드 (수동 구현)
  CheckRecordModelDto copyWith({
    String? id,
    String? userId,
    String? taskId,
    DateTime? date,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CheckRecordModelDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

---

## 3. Mapper (Extension 패턴)

> 파일: `lib/data/mapper/check_record_model_mapper.dart`

```dart
import '../../domain/model/check_record_model.dart';
import '../dto/check_record_model_dto.dart';

/// CheckRecordModelDto -> CheckRecordModel 변환
extension CheckRecordModelDtoMapper on CheckRecordModelDto? {
  CheckRecordModel? toModel() {
    final dto = this;
    if (dto == null) return null;

    return CheckRecordModel(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      taskId: dto.taskId ?? '',
      date: dto.date ?? DateTime.now(),
      isCompleted: dto.isCompleted ?? false,
      completedAt: dto.completedAt,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }
}

/// CheckRecordModel -> CheckRecordModelDto 변환
extension CheckRecordModelMapper on CheckRecordModel {
  CheckRecordModelDto toDto() {
    return CheckRecordModelDto(
      id: id,
      userId: userId,
      taskId: taskId,
      date: date,
      isCompleted: isCompleted,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// List<CheckRecordModelDto> -> List<CheckRecordModel> 변환
extension CheckRecordModelDtoListMapper on List<CheckRecordModelDto>? {
  List<CheckRecordModel> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<CheckRecordModel>().toList();
  }
}

/// List<CheckRecordModel> -> List<CheckRecordModelDto> 변환
extension CheckRecordModelListMapper on List<CheckRecordModel>? {
  List<CheckRecordModelDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
```

---

## 4. DataSource

### 인터페이스

> 파일: `lib/data/datasource/check_record_datasource.dart`

```dart
import '../dto/check_record_model_dto.dart';

/// CheckRecord DataSource 인터페이스 - Firebase 의존성 제거
abstract class CheckRecordDataSource {
  /// 특정 날짜의 체크 기록 조회
  Future<List<CheckRecordModelDto>> getRecordsByDate(String userId, DateTime date);

  /// 특정 Task + 날짜의 체크 기록 조회 (단일)
  Future<CheckRecordModelDto?> getRecord(String userId, String taskId, DateTime date);

  /// 체크 기록 생성
  Future<String> addRecord(String userId, CheckRecordModelDto record);

  /// 체크 기록 수정 (토글)
  Future<void> updateRecord(String userId, CheckRecordModelDto record);

  /// 체크 기록 삭제
  Future<void> deleteRecord(String userId, String recordId);

  /// 월별 체크 기록 조회 (통계용)
  Future<List<CheckRecordModelDto>> getRecordsByMonth(String userId, int year, int month);

  /// 특정 Task의 체크 기록 조회 (기간)
  Future<List<CheckRecordModelDto>> getRecordsByTaskAndRange(
    String userId,
    String taskId,
    DateTime startDate,
    DateTime endDate,
  );
}
```

### Firebase 구현체

> 파일: `lib/data/datasource/check_record_firebase_datasource_impl.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../dto/check_record_model_dto.dart';
import 'check_record_datasource.dart';

/// Firebase Firestore 기반 CheckRecord DataSource 구현체
class CheckRecordFirebaseDataSourceImpl implements CheckRecordDataSource {
  final FirebaseFirestore _firestore;

  CheckRecordFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // ========================================
  // Firestore 변환 헬퍼 메서드
  // ========================================

  /// Firestore Document를 CheckRecordModelDto로 변환
  CheckRecordModelDto _documentToDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckRecordModelDto(
      id: doc.id,
      userId: data['userId'],
      taskId: data['taskId'],
      date: (data['date'] as Timestamp?)?.toDate(),
      isCompleted: data['isCompleted'],
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// CheckRecordModelDto를 Firestore Map으로 변환
  Map<String, dynamic> _dtoToFirestore(CheckRecordModelDto dto) {
    return {
      'userId': dto.userId,
      'taskId': dto.taskId,
      'date': dto.date != null ? Timestamp.fromDate(dto.date!) : null,
      'isCompleted': dto.isCompleted,
      'completedAt': dto.completedAt != null ? Timestamp.fromDate(dto.completedAt!) : null,
      'createdAt': dto.createdAt != null ? Timestamp.fromDate(dto.createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // ========================================
  // Firestore 경로: users/{userId}/checkRecords/{recordId}
  // ========================================

  CollectionReference _recordsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('checkRecords');
  }

  /// 날짜를 시간 없이 정규화 (yyyy-MM-dd 00:00:00)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ========================================
  // CRUD 메서드
  // ========================================

  @override
  Future<List<CheckRecordModelDto>> getRecordsByDate(String userId, DateTime date) async {
    try {
      final normalizedDate = _normalizeDate(date);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final querySnapshot = await _recordsCollection(userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate))
          .where('date', isLessThan: Timestamp.fromDate(nextDay))
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToDto(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<CheckRecordModelDto?> getRecord(String userId, String taskId, DateTime date) async {
    try {
      final normalizedDate = _normalizeDate(date);
      final nextDay = normalizedDate.add(const Duration(days: 1));

      final querySnapshot = await _recordsCollection(userId)
          .where('taskId', isEqualTo: taskId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate))
          .where('date', isLessThan: Timestamp.fromDate(nextDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return _documentToDto(querySnapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<String> addRecord(String userId, CheckRecordModelDto record) async {
    try {
      final recordWithUser = record.copyWith(userId: userId);
      final recordData = _dtoToFirestore(recordWithUser);
      final docRef = await _recordsCollection(userId).add(recordData);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> updateRecord(String userId, CheckRecordModelDto record) async {
    try {
      final recordData = _dtoToFirestore(record);
      await _recordsCollection(userId).doc(record.id).update(recordData);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> deleteRecord(String userId, String recordId) async {
    try {
      await _recordsCollection(userId).doc(recordId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<List<CheckRecordModelDto>> getRecordsByMonth(String userId, int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1);

      final querySnapshot = await _recordsCollection(userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToDto(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<List<CheckRecordModelDto>> getRecordsByTaskAndRange(
    String userId,
    String taskId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _recordsCollection(userId)
          .where('taskId', isEqualTo: taskId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_normalizeDate(startDate)))
          .where('date', isLessThan: Timestamp.fromDate(_normalizeDate(endDate).add(const Duration(days: 1))))
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToDto(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }
}
```

---

## 5. Repository

### 인터페이스

> 파일: `lib/domain/repository/check_record_repository.dart`

```dart
import '../../core/result/result.dart';
import '../model/check_record_model.dart';

/// CheckRecord Repository 인터페이스
abstract class CheckRecordRepository {
  /// 특정 날짜의 체크 기록 조회
  Future<Result<List<CheckRecordModel>>> getRecordsByDate(String userId, DateTime date);

  /// 체크 토글 (핵심 로직: 기존 레코드 조회 → 있으면 토글 / 없으면 생성)
  Future<Result<CheckRecordModel>> toggleCheck(String userId, String taskId, DateTime date);

  /// 월별 체크 기록 조회 (통계용)
  Future<Result<List<CheckRecordModel>>> getRecordsByMonth(String userId, int year, int month);

  /// 특정 Task의 기간별 체크 기록 조회
  Future<Result<List<CheckRecordModel>>> getRecordsByTaskAndRange(
    String userId,
    String taskId,
    DateTime startDate,
    DateTime endDate,
  );
}
```

### 구현체

> 파일: `lib/data/repository_impl/check_record_repository_impl.dart`

```dart
import '../../core/result/result.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/failure_mapper.dart';
import '../../domain/model/check_record_model.dart';
import '../../domain/repository/check_record_repository.dart';
import '../datasource/check_record_datasource.dart';
import '../mapper/check_record_model_mapper.dart';

class CheckRecordRepositoryImpl implements CheckRecordRepository {
  final CheckRecordDataSource _dataSource;

  CheckRecordRepositoryImpl({
    required CheckRecordDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<CheckRecordModel>>> getRecordsByDate(String userId, DateTime date) async {
    try {
      final dtos = await _dataSource.getRecordsByDate(userId, date);
      final records = dtos.toModelList();
      return Success(records);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  /// 체크 토글 핵심 로직
  /// 1. 기존 레코드 조회 (userId + taskId + date)
  /// 2. 있으면: isCompleted 토글 + completedAt 업데이트
  /// 3. 없으면: 새 레코드 생성 (isCompleted = true)
  @override
  Future<Result<CheckRecordModel>> toggleCheck(String userId, String taskId, DateTime date) async {
    try {
      if (taskId.trim().isEmpty) {
        return Error(ValidationFailure('체크 항목 ID는 필수입니다'));
      }

      // 1. 기존 레코드 조회
      final existingDto = await _dataSource.getRecord(userId, taskId, date);

      if (existingDto != null) {
        // 2. 기존 레코드가 있으면 토글
        final existingRecord = existingDto.toModel();
        if (existingRecord == null) {
          return Error(ServerFailure('체크 기록 데이터를 변환할 수 없습니다'));
        }

        final toggled = existingRecord.copyWith(
          isCompleted: !existingRecord.isCompleted,
          completedAt: !existingRecord.isCompleted ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );

        final toggledDto = toggled.toDto();
        await _dataSource.updateRecord(userId, toggledDto);
        return Success(toggled);
      } else {
        // 3. 기존 레코드가 없으면 새로 생성
        final now = DateTime.now();
        final normalizedDate = DateTime(date.year, date.month, date.day);

        final newRecordDto = CheckRecordModelDto(
          userId: userId,
          taskId: taskId,
          date: normalizedDate,
          isCompleted: true,
          completedAt: now,
          createdAt: now,
          updatedAt: now,
        );

        final recordId = await _dataSource.addRecord(userId, newRecordDto);

        final newRecord = newRecordDto.copyWith(id: recordId).toModel();
        if (newRecord == null) {
          return Error(ServerFailure('체크 기록 생성 후 변환에 실패했습니다'));
        }

        return Success(newRecord);
      }
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<CheckRecordModel>>> getRecordsByMonth(String userId, int year, int month) async {
    try {
      final dtos = await _dataSource.getRecordsByMonth(userId, year, month);
      final records = dtos.toModelList();
      return Success(records);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<CheckRecordModel>>> getRecordsByTaskAndRange(
    String userId,
    String taskId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (taskId.trim().isEmpty) {
        return Error(ValidationFailure('체크 항목 ID는 필수입니다'));
      }

      final dtos = await _dataSource.getRecordsByTaskAndRange(userId, taskId, startDate, endDate);
      final records = dtos.toModelList();
      return Success(records);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }
}
```

---

## 6. Provider DI 등록

```dart
// core/di/data_providers.dart
Provider<CheckRecordDataSource>(
  create: (_) => CheckRecordFirebaseDataSourceImpl(
    firestore: context.read<FirebaseFirestore>(),
  ),
),

// core/di/domain_providers.dart
Provider<CheckRecordRepository>(
  create: (context) => CheckRecordRepositoryImpl(
    dataSource: context.read<CheckRecordDataSource>(),
  ),
),
```

---

## 7. Firestore 경로

```
users/{userId}/checkRecords/{recordId}
```

- **서브컬렉션 방식**: 사용자별 데이터 격리
- **핵심 쿼리**: `userId` + `taskId` + `date` 조합으로 유니크 레코드 조회
- **필수 인덱스**: `date` 범위 쿼리 + `taskId` 필터 복합 인덱스

---

## 8. toggleCheck 핵심 로직 다이어그램

```
toggleCheck(userId, taskId, date)
  │
  ├─ 기존 레코드 조회 (getRecord)
  │
  ├─ 레코드 있음?
  │   ├─ Yes → isCompleted 토글
  │   │         isCompleted: true → false  (completedAt: null)
  │   │         isCompleted: false → true  (completedAt: now)
  │   │         → updateRecord()
  │   │
  │   └─ No  → 새 레코드 생성
  │             isCompleted: true
  │             completedAt: now
  │             → addRecord()
  │
  └─ Result<CheckRecordModel> 반환
```

---
