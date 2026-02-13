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
  // Firestore 변환 헬퍼
  // ========================================

  /// Firestore Document → TaskModelDto 변환 (외부 접근용)
  static TaskModelDto documentToTaskDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModelDto(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      category: data['category'],
      repeatDays: (data['repeatDays'] as List<dynamic>?)?.cast<int>(),
      reminderHour: data['reminderHour'],
      reminderMinute: data['reminderMinute'],
      isActive: data['isActive'],
      sortOrder: data['sortOrder'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      repeatType: data['repeatType'],
      specificDates: _parseSpecificDatesStatic(data),
    );
  }

  static List<DateTime>? _parseSpecificDatesStatic(Map<String, dynamic> data) {
    final list = data['specificDates'] as List<dynamic>?;
    if (list != null && list.isNotEmpty) {
      return list.map((e) => (e as Timestamp).toDate()).toList();
    }
    final single = data['specificDate'] as Timestamp?;
    if (single != null) {
      return [single.toDate()];
    }
    return null;
  }

  /// 하위 호환: specificDates(List) 우선, 없으면 기존 specificDate(단일) 감싸기
  List<DateTime>? _parseSpecificDates(Map<String, dynamic> data) {
    final list = data['specificDates'] as List<dynamic>?;
    if (list != null && list.isNotEmpty) {
      return list.map((e) => (e as Timestamp).toDate()).toList();
    }
    final single = data['specificDate'] as Timestamp?;
    if (single != null) {
      return [single.toDate()];
    }
    return null;
  }

  TaskModelDto _documentToDto(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModelDto(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      category: data['category'],
      repeatDays: (data['repeatDays'] as List<dynamic>?)?.cast<int>(),
      reminderHour: data['reminderHour'],
      reminderMinute: data['reminderMinute'],
      isActive: data['isActive'],
      sortOrder: data['sortOrder'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      repeatType: data['repeatType'],
      specificDates: _parseSpecificDates(data),
    );
  }

  Map<String, dynamic> _dtoToFirestore(TaskModelDto dto) {
    return {
      'userId': dto.userId,
      'name': dto.name,
      'category': dto.category,
      'repeatDays': dto.repeatDays,
      'reminderHour': dto.reminderHour,
      'reminderMinute': dto.reminderMinute,
      'isActive': dto.isActive,
      'sortOrder': dto.sortOrder,
      'createdAt': dto.createdAt != null
          ? Timestamp.fromDate(dto.createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'repeatType': dto.repeatType,
      'specificDates': dto.specificDates
          ?.map((d) => Timestamp.fromDate(d))
          .toList() ?? [],
    };
  }

  CollectionReference _tasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // ========================================
  // CRUD
  // ========================================

  @override
  Future<List<TaskModelDto>> getTasks(String userId) async {
    try {
      final querySnapshot = await _tasksCollection(userId)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs.map((doc) => _documentToDto(doc)).toList();
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

      return querySnapshot.docs.map((doc) => _documentToDto(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException('Firebase 오류: ${e.message}');
    }
  }

  @override
  Future<void> updateSortOrders(
    String userId,
    Map<String, int> taskIdToOrder,
  ) async {
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
