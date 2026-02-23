import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../../model/repeat_type.dart';
import '../../model/task_model.dart';
import '../../repository/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase({required TaskRepository repository})
      : _repository = repository;

  Future<Result<void>> call({
    required String userId,
    required TaskModel task,
  }) async {
    if (task.name.trim().isEmpty) {
      return const Error(ValidationFailure('항목 이름을 입력해주세요'));
    }
    if (task.name.trim().length > 30) {
      return const Error(ValidationFailure('항목 이름은 30자 이하로 입력해주세요'));
    }
    switch (task.repeatType) {
      case RepeatType.weekly:
        if (task.repeatDays.isEmpty) {
          return const Error(ValidationFailure('반복 요일을 선택해주세요'));
        }
      case RepeatType.monthly:
        if (task.repeatMonthDays.isEmpty) {
          return const Error(ValidationFailure('반복 일자를 선택해주세요'));
        }
      case RepeatType.once:
        if (task.specificDates.isEmpty) {
          return const Error(ValidationFailure('날짜를 선택해주세요'));
        }
    }

    return await _repository.updateTask(userId, task);
  }
}
