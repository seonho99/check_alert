# TaskModel (체크 항목) 전체 설계

> **참조**: [docs/logic/](../logic/) 가이드의 Clean Architecture + MVVM + Provider + Freezed 3.0 패턴 준수

---

## 1. Domain Model (Entity)

> 파일: `lib/domain/model/task_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';

/// 체크 항목 도메인 모델 (순수한 데이터 구조체)
///
/// Clean Architecture 원칙에 따라:
/// - 검증 로직 없음 (UseCase에서 처리)
/// - 비즈니스 로직 없음 (Domain Services에서 처리)
/// - 기술에 독립적인 순수 도메인 개념만 포함
@freezed
sealed class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,             // 항목 고유 ID
    required String userId,         // 사용자 UID
    required String name,           // 항목 이름 (예: "물 마시기")
    required String category,       // 카테고리 (예: "건강", "운동", "학습")
    required List<int> repeatDays,  // 반복 요일 (1=월, 2=화, ..., 7=일) — weekly용
    required int reminderHour,      // 알림 시간 (0-23)
    required int reminderMinute,    // 알림 분 (0-59)
    required bool isActive,         // 활성화 상태
    required int sortOrder,         // 정렬 순서
    required DateTime createdAt,    // 생성 일시
    required DateTime updatedAt,    // 수정 일시
    required RepeatType repeatType, // 반복 유형 (weekly/monthly/once)
    @Default([]) List<DateTime> specificDates,  // once용 특정 날짜 목록
    @Default([]) List<int> repeatMonthDays,     // monthly용 매월 반복 일자
  }) = _TaskModel;
}
```

### Extension (편의 메서드)

```dart
/// TaskModel 편의 확장
extension TaskModelExtension on TaskModel {
  /// 오늘에 해당하는 항목인지 확인 (RepeatType별 분기)
  bool get isTodayTask {
    switch (repeatType) {
      case RepeatType.weekly:
        return repeatDays.contains(DateTime.now().weekday);
      case RepeatType.monthly:
        return repeatMonthDays.contains(DateTime.now().day);
      case RepeatType.once:
        if (specificDates.isEmpty) return false;
        final now = DateTime.now();
        return specificDates.any((d) =>
            d.year == now.year && d.month == now.month && d.day == now.day);
    }
  }

  /// 특정 날짜에 해당하는 항목인지 확인 (달력 뷰에서 사용)
  bool isTaskForDate(DateTime date) {
    switch (repeatType) {
      case RepeatType.weekly:
        return repeatDays.contains(date.weekday);
      case RepeatType.monthly:
        return repeatMonthDays.contains(date.day);
      case RepeatType.once:
        if (specificDates.isEmpty) return false;
        return specificDates.any((d) =>
            d.year == date.year && d.month == date.month && d.day == date.day);
    }
  }

  /// 알림 시간 포맷 (HH:mm)
  String get reminderTimeFormatted =>
      '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}';

  /// 반복 텍스트 (RepeatType별 분기)
  String get repeatDaysText {
    switch (repeatType) {
      case RepeatType.weekly:
        const dayNames = ['월', '화', '수', '목', '금', '토', '일'];
        if (repeatDays.length == 7) return '매일';
        return repeatDays.map((d) => dayNames[d - 1]).join(', ');
      case RepeatType.monthly:
        if (repeatMonthDays.isEmpty) return '일자 미지정';
        final sorted = List<int>.from(repeatMonthDays)..sort();
        return '매월 ${sorted.map((d) => '$d일').join(', ')}';
      case RepeatType.once:
        if (specificDates.isEmpty) return '날짜 미지정';
        final first = specificDates.first;
        final firstText = '${first.year}.${first.month.toString().padLeft(2, '0')}.${first.day.toString().padLeft(2, '0')}';
        if (specificDates.length == 1) return firstText;
        return '$firstText 외 ${specificDates.length - 1}일';
    }
  }
}
```

---

## 2. DTO (Data Transfer Object)

> 파일: `lib/data/dto/task_model_dto.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'task_model_dto.g.dart';

/// TaskModel DTO (JsonSerializable)
/// 모든 필드 nullable - 외부 데이터의 불완전성 대응
@JsonSerializable()
class TaskModelDto {
  final String? id;
  final String? userId;
  final String? name;
  final String? category;
  final String? repeatType;           // "weekly" / "monthly" / "once"
  final List<int>? repeatDays;        // weekly용
  final List<int>? repeatMonthDays;   // monthly용
  final List<DateTime>? specificDates; // once용
  final int? reminderHour;
  final int? reminderMinute;
  final bool? isActive;
  final int? sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModelDto({
    this.id,
    this.userId,
    this.name,
    this.category,
    this.repeatType,
    this.repeatDays,
    this.repeatMonthDays,
    this.specificDates,
    this.reminderHour,
    this.reminderMinute,
    this.isActive,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  /// JSON serialization (auto-generated)
  factory TaskModelDto.fromJson(Map<String, dynamic> json) =>
      _$TaskModelDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelDtoToJson(this);

  /// copyWith 메서드 (수동 구현)
  TaskModelDto copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? repeatType,
    List<int>? repeatDays,
    List<int>? repeatMonthDays,
    List<DateTime>? specificDates,
    int? reminderHour,
    int? reminderMinute,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModelDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatMonthDays: repeatMonthDays ?? this.repeatMonthDays,
      specificDates: specificDates ?? this.specificDates,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

> **Firestore 변환은 DataSource에서 처리**: `_documentToDto()`, `_dtoToFirestore()` 헬퍼 메서드 활용

---

## 3. Mapper (Extension 패턴)

> 파일: `lib/data/mapper/task_model_mapper.dart`

```dart
import '../../domain/model/task_model.dart';
import '../dto/task_model_dto.dart';

/// TaskModelDto -> TaskModel 변환
extension TaskModelDtoMapper on TaskModelDto? {
  TaskModel? toModel() {
    final dto = this;
    if (dto == null) return null;

    return TaskModel(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      name: dto.name ?? '',
      category: dto.category ?? '',
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == dto.repeatType,
        orElse: () => RepeatType.weekly,
      ),
      repeatDays: dto.repeatDays ?? [1, 2, 3, 4, 5, 6, 7],
      repeatMonthDays: dto.repeatMonthDays ?? [],
      specificDates: dto.specificDates ?? [],
      reminderHour: dto.reminderHour ?? 9,
      reminderMinute: dto.reminderMinute ?? 0,
      isActive: dto.isActive ?? true,
      sortOrder: dto.sortOrder ?? 0,
      createdAt: dto.createdAt ?? DateTime.now(),
      updatedAt: dto.updatedAt ?? DateTime.now(),
    );
  }
}

/// TaskModel -> TaskModelDto 변환
extension TaskModelMapper on TaskModel {
  TaskModelDto toDto() {
    return TaskModelDto(
      id: id,
      userId: userId,
      name: name,
      category: category,
      repeatType: repeatType.name,
      repeatDays: repeatDays,
      repeatMonthDays: repeatMonthDays,
      specificDates: specificDates,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// List<TaskModelDto> -> List<TaskModel> 변환
extension TaskModelDtoListMapper on List<TaskModelDto>? {
  List<TaskModel> toModelList() {
    final dtoList = this;
    if (dtoList == null || dtoList.isEmpty) return [];
    return dtoList.map((dto) => dto.toModel()).whereType<TaskModel>().toList();
  }
}

/// List<TaskModel> -> List<TaskModelDto> 변환
extension TaskModelListMapper on List<TaskModel>? {
  List<TaskModelDto> toDtoList() {
    final entityList = this;
    if (entityList == null || entityList.isEmpty) return [];
    return entityList.map((entity) => entity.toDto()).toList();
  }
}
```

---

## 4. DataSource

### 인터페이스

> 파일: `lib/data/datasource/task_datasource.dart`

```dart
import '../dto/task_model_dto.dart';

/// Task DataSource 인터페이스 - Firebase 의존성 제거
abstract class TaskDataSource {
  /// 사용자의 모든 활성 체크 항목 조회
  Future<List<TaskModelDto>> getTasks(String userId);

  /// 특정 체크 항목 조회
  Future<TaskModelDto?> getTaskById(String userId, String taskId);

  /// 체크 항목 추가
  Future<String> addTask(String userId, TaskModelDto task);

  /// 체크 항목 수정
  Future<void> updateTask(String userId, TaskModelDto task);

  /// 체크 항목 삭제
  Future<void> deleteTask(String userId, String taskId);

  /// 오늘 요일에 해당하는 체크 항목 조회
  Future<List<TaskModelDto>> getTasksByDay(String userId, int weekday);

  /// 정렬 순서 일괄 업데이트
  Future<void> updateSortOrders(String userId, Map<String, int> taskIdToOrder);
}
```

### Firebase 구현체

> 파일: `lib/data/datasource/task_firebase_datasource_impl.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../dto/task_model_dto.dart';
import 'task_datasource.dart';

/// Firebase Firestore 기반 Task DataSource 구현체
class TaskFirebaseDataSourceImpl implements TaskDataSource {
  final FirebaseFirestore _firestore;

  TaskFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // ========================================
  // Firestore 변환 헬퍼 메서드
  // ========================================

  /// Firestore Document를 TaskModelDto로 변환
  TaskModelDto _documentToDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModelDto(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      icon: data['icon'],
      colorValue: data['colorValue'],
      category: data['category'],
      repeatDays: (data['repeatDays'] as List<dynamic>?)?.cast<int>(),
      reminderHour: data['reminderHour'],
      reminderMinute: data['reminderMinute'],
      isActive: data['isActive'],
      sortOrder: data['sortOrder'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// TaskModelDto를 Firestore Map으로 변환
  Map<String, dynamic> _dtoToFirestore(TaskModelDto dto) {
    return {
      'userId': dto.userId,
      'name': dto.name,
      'icon': dto.icon,
      'colorValue': dto.colorValue,
      'category': dto.category,
      'repeatDays': dto.repeatDays,
      'reminderHour': dto.reminderHour,
      'reminderMinute': dto.reminderMinute,
      'isActive': dto.isActive,
      'sortOrder': dto.sortOrder,
      'createdAt': dto.createdAt != null ? Timestamp.fromDate(dto.createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // ========================================
  // Firestore 경로: users/{userId}/tasks/{taskId}
  // ========================================

  CollectionReference _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // ========================================
  // CRUD 메서드
  // ========================================

  @override
  Future<List<TaskModelDto>> getTasks(String userId) async {
    try {
      final querySnapshot = await _tasksCollection(userId)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToDto(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<TaskModelDto?> getTaskById(String userId, String taskId) async {
    try {
      final doc = await _tasksCollection(userId).doc(taskId).get();
      if (!doc.exists) return null;
      return _documentToDto(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<String> addTask(String userId, TaskModelDto task) async {
    try {
      final taskWithUser = task.copyWith(userId: userId);
      final taskData = _dtoToFirestore(taskWithUser);
      final docRef = await _tasksCollection(userId).add(taskData);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> updateTask(String userId, TaskModelDto task) async {
    try {
      final taskData = _dtoToFirestore(task);
      await _tasksCollection(userId).doc(task.id).update(taskData);
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<List<TaskModelDto>> getTasksByDay(String userId, int weekday) async {
    try {
      final querySnapshot = await _tasksCollection(userId)
          .where('isActive', isEqualTo: true)
          .where('repeatDays', arrayContains: weekday)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => _documentToDto(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> updateSortOrders(String userId, Map<String, int> taskIdToOrder) async {
    try {
      final batch = _firestore.batch();
      for (final entry in taskIdToOrder.entries) {
        batch.update(
          _tasksCollection(userId).doc(entry.key),
          {'sortOrder': entry.value, 'updatedAt': Timestamp.fromDate(DateTime.now())},
        );
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }
}
```

---

## 5. Repository

### 인터페이스

> 파일: `lib/domain/repository/task_repository.dart`

```dart
import '../../core/result/result.dart';
import '../model/task_model.dart';

/// Task Repository 인터페이스
abstract class TaskRepository {
  Future<Result<List<TaskModel>>> getTasks(String userId);
  Future<Result<TaskModel>> getTaskById(String userId, String taskId);
  Future<Result<String>> addTask(String userId, TaskModel task);
  Future<Result<void>> updateTask(String userId, TaskModel task);
  Future<Result<void>> deleteTask(String userId, String taskId);
  Future<Result<List<TaskModel>>> getTodayTasks(String userId);
  Future<Result<void>> updateSortOrders(String userId, Map<String, int> taskIdToOrder);
}
```

### 구현체

> 파일: `lib/data/repository_impl/task_repository_impl.dart`

```dart
import '../../core/result/result.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/failure_mapper.dart';
import '../../domain/model/task_model.dart';
import '../../domain/repository/task_repository.dart';
import '../datasource/task_datasource.dart';
import '../mapper/task_model_mapper.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource _dataSource;

  TaskRepositoryImpl({
    required TaskDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<List<TaskModel>>> getTasks(String userId) async {
    try {
      final dtos = await _dataSource.getTasks(userId);
      final tasks = dtos.toModelList();
      return Success(tasks);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<TaskModel>> getTaskById(String userId, String taskId) async {
    try {
      if (taskId.trim().isEmpty) {
        return Error(ValidationFailure('항목 ID는 필수입니다'));
      }

      final dto = await _dataSource.getTaskById(userId, taskId);
      final task = dto.toModel();

      if (task == null) {
        return Error(ServerFailure('체크 항목을 찾을 수 없습니다'));
      }

      return Success(task);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<String>> addTask(String userId, TaskModel task) async {
    try {
      if (task.name.trim().isEmpty) {
        return Error(ValidationFailure('항목 이름은 필수입니다'));
      }
      if (task.repeatDays.isEmpty) {
        return Error(ValidationFailure('반복 요일을 선택해주세요'));
      }

      final dto = task.toDto();
      final taskId = await _dataSource.addTask(userId, dto);
      return Success(taskId);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> updateTask(String userId, TaskModel task) async {
    try {
      if (task.name.trim().isEmpty) {
        return Error(ValidationFailure('항목 이름은 필수입니다'));
      }

      final dto = task.toDto();
      await _dataSource.updateTask(userId, dto);
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> deleteTask(String userId, String taskId) async {
    try {
      if (taskId.trim().isEmpty) {
        return Error(ValidationFailure('항목 ID는 필수입니다'));
      }

      await _dataSource.deleteTask(userId, taskId);
      return Success(null);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<List<TaskModel>>> getTodayTasks(String userId) async {
    try {
      final today = DateTime.now().weekday; // 1=월 ~ 7=일
      final dtos = await _dataSource.getTasksByDay(userId, today);
      final tasks = dtos.toModelList();
      return Success(tasks);
    } catch (e, stackTrace) {
      final failure = FailureMapper.mapExceptionToFailure(e, stackTrace);
      return Error(failure);
    }
  }

  @override
  Future<Result<void>> updateSortOrders(String userId, Map<String, int> taskIdToOrder) async {
    try {
      if (taskIdToOrder.isEmpty) {
        return Error(ValidationFailure('정렬 데이터가 비어있습니다'));
      }

      await _dataSource.updateSortOrders(userId, taskIdToOrder);
      return Success(null);
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
Provider<TaskDataSource>(
  create: (_) => TaskFirebaseDataSourceImpl(
    firestore: context.read<FirebaseFirestore>(),
  ),
),

// core/di/domain_providers.dart
Provider<TaskRepository>(
  create: (context) => TaskRepositoryImpl(
    dataSource: context.read<TaskDataSource>(),
  ),
),
```

---

## 7. Firestore 경로

```
users/{userId}/tasks/{taskId}
```

- **서브컬렉션 방식**: 사용자별 데이터 격리
- **보안 규칙**: 본인 데이터만 읽기/쓰기 가능
- **인덱스**: `isActive` + `repeatDays` + `sortOrder` 복합 인덱스

---
