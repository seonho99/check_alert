import '../../../core/result/result.dart';
import '../../model/task_model.dart';
import '../../repository/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase({required TaskRepository repository})
      : _repository = repository;

  Future<Result<List<TaskModel>>> call(String userId) async {
    return await _repository.getTasks(userId);
  }
}
