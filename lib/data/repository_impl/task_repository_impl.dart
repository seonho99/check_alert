import '../../core/errors/failure.dart';
import '../../core/errors/failure_mapper.dart';
import '../../core/result/result.dart';
import '../../domain/model/repeat_type.dart';
import '../../domain/model/task_model.dart';
import '../../domain/repository/task_repository.dart';
import '../datasource/task_datasource.dart';
import '../mapper/task_model_mapper.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDataSource _dataSource;

  TaskRepositoryImpl({required TaskDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<List<TaskModel>>> getTasks(String userId) async {
    try {
      final dtos = await _dataSource.getTasks(userId);
      final tasks = dtos.toModelList();
      return Success(tasks);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<TaskModel>> getTaskById(String userId, String taskId) async {
    try {
      if (taskId.trim().isEmpty) {
        return const Error(ValidationFailure('항목 ID는 필수입니다'));
      }

      final dto = await _dataSource.getTaskById(userId, taskId);
      final task = dto.toModel();

      if (task == null) {
        return const Error(NotFoundFailure('체크 항목을 찾을 수 없습니다'));
      }

      return Success(task);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<String>> addTask(String userId, TaskModel task) async {
    try {
      if (task.name.trim().isEmpty) {
        return const Error(ValidationFailure('항목 이름은 필수입니다'));
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

      final dto = task.toDto();
      final taskId = await _dataSource.addTask(userId, dto);
      return Success(taskId);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> updateTask(String userId, TaskModel task) async {
    try {
      if (task.name.trim().isEmpty) {
        return const Error(ValidationFailure('항목 이름은 필수입니다'));
      }

      final dto = task.toDto();
      await _dataSource.updateTask(userId, dto);
      return const Success(null);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> deleteTask(String userId, String taskId) async {
    try {
      if (taskId.trim().isEmpty) {
        return const Error(ValidationFailure('항목 ID는 필수입니다'));
      }

      await _dataSource.deleteTask(userId, taskId);
      return const Success(null);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<List<TaskModel>>> getTodayTasks(String userId) async {
    try {
      final today = DateTime.now().weekday;
      final dtos = await _dataSource.getTasksByDay(userId, today);
      final tasks = dtos.toModelList();
      return Success(tasks);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }

  @override
  Future<Result<void>> updateSortOrders(
    String userId,
    Map<String, int> taskIdToOrder,
  ) async {
    try {
      if (taskIdToOrder.isEmpty) {
        return const Error(ValidationFailure('정렬 데이터가 비어있습니다'));
      }

      await _dataSource.updateSortOrders(userId, taskIdToOrder);
      return const Success(null);
    } catch (e, stackTrace) {
      return Error(FailureMapper.mapExceptionToFailure(e, stackTrace));
    }
  }
}
