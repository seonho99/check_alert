import '../dto/task_model_dto.dart';

/// Task DataSource 인터페이스 - Firebase 의존성 제거
abstract class TaskDataSource {
  Future<List<TaskModelDto>> getTasks(String userId);
  Future<TaskModelDto?> getTaskById(String userId, String taskId);
  Future<String> addTask(String userId, TaskModelDto task);
  Future<void> updateTask(String userId, TaskModelDto task);
  Future<void> deleteTask(String userId, String taskId);
  Future<List<TaskModelDto>> getTasksByDay(String userId, int weekday);
  Future<void> updateSortOrders(String userId, Map<String, int> taskIdToOrder);
}
