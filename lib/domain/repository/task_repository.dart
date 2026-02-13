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
