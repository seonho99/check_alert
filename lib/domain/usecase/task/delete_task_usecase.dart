import '../../../core/result/result.dart';
import '../../repository/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase({required TaskRepository repository})
      : _repository = repository;

  Future<Result<void>> call({
    required String userId,
    required String taskId,
  }) async {
    return await _repository.deleteTask(userId, taskId);
  }
}
