import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/model/repeat_type.dart';
import '../../domain/model/task_model.dart';
import '../../domain/usecase/task/add_task_usecase.dart';
import '../../domain/usecase/task/update_task_usecase.dart';
import '../../core/services/local_notification_service.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/repository/task_repository.dart';
import 'task_detail_state.dart';

class TaskDetailViewModel extends ChangeNotifier {
  final AddTaskUseCase _addTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final AuthRepository _authRepository;
  final TaskRepository _taskRepository;
  final LocalNotificationService _notificationService;

  final TextEditingController nameController = TextEditingController();

  TaskDetailState _state = TaskDetailState.initial();
  TaskDetailState get state => _state;

  TaskDetailViewModel({
    required AddTaskUseCase addTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required AuthRepository authRepository,
    required TaskRepository taskRepository,
    required LocalNotificationService notificationService,
    String? taskId,
  })  : _addTaskUseCase = addTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _authRepository = authRepository,
        _taskRepository = taskRepository,
        _notificationService = notificationService {
    nameController.addListener(_onNameChanged);
    if (taskId != null) {
      loadTask(taskId);
    }
  }

  void _updateState(TaskDetailState newState) {
    _state = newState;
    notifyListeners();
  }

  String? get _userId => _authRepository.currentUserId;

  void _onNameChanged() {
    _updateState(_state.copyWith(name: nameController.text, errorMessage: null));
  }

  /// 수정 모드: 기존 Task 데이터 로드
  Future<void> loadTask(String taskId) async {
    final userId = _userId;
    if (userId == null) return;

    _updateState(_state.copyWith(isLoading: true));

    final result = await _taskRepository.getTaskById(userId, taskId);
    result.when(
      success: (task) {
        nameController.text = task.name;
        _updateState(_state.copyWith(
          isLoading: false,
          isEditMode: true,
          taskId: task.id,
          name: task.name,
          category: task.category,
          repeatDays: task.repeatDays,
          reminderHour: task.reminderHour,
          reminderMinute: task.reminderMinute,
          isActive: task.isActive,
          repeatType: task.repeatType,
          specificDates: task.specificDates,
          repeatMonthDays: task.repeatMonthDays,
        ));
      },
      error: (failure) {
        _updateState(_state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void selectCategory(String category) {
    _updateState(_state.copyWith(category: category));
  }

  void selectRepeatType(RepeatType type) {
    switch (type) {
      case RepeatType.weekly:
        _updateState(_state.copyWith(
          repeatType: type,
          repeatDays: _state.repeatDays.isEmpty
              ? AppConstants.defaultRepeatDays
              : _state.repeatDays,
        ));
      case RepeatType.monthly:
        _updateState(_state.copyWith(
          repeatType: type,
          repeatDays: [],
        ));
      case RepeatType.once:
        _updateState(_state.copyWith(
          repeatType: type,
          repeatDays: [],
        ));
    }
  }

  void setSpecificDates(List<DateTime> dates) {
    _updateState(_state.copyWith(specificDates: dates));
  }

  void removeSpecificDate(DateTime date) {
    final updated = _state.specificDates
        .where((d) =>
            !(d.year == date.year &&
                d.month == date.month &&
                d.day == date.day))
        .toList();
    _updateState(_state.copyWith(specificDates: updated));
  }

  void toggleDay(int day) {
    final days = List<int>.from(_state.repeatDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
      days.sort();
    }
    _updateState(_state.copyWith(repeatDays: days));
  }

  void setAllDays() {
    _updateState(_state.copyWith(
      repeatDays: AppConstants.defaultRepeatDays,
    ));
  }

  void toggleMonthDay(int day) {
    final days = List<int>.from(_state.repeatMonthDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
      days.sort();
    }
    _updateState(_state.copyWith(repeatMonthDays: days));
  }

  void setReminderTime(int hour, int minute) {
    _updateState(_state.copyWith(reminderHour: hour, reminderMinute: minute));
  }

  void toggleActive() {
    _updateState(_state.copyWith(isActive: !_state.isActive));
  }

  /// 저장 (추가 or 수정)
  Future<void> save() async {
    final userId = _userId;
    if (userId == null) return;
    if (!_state.isValid) return;

    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final now = DateTime.now();
    final task = TaskModel(
      id: _state.taskId ?? '',
      userId: userId,
      name: _state.name.trim(),
      category: _state.category,
      repeatDays: _state.repeatDays,
      reminderHour: _state.reminderHour,
      reminderMinute: _state.reminderMinute,
      isActive: _state.isActive,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
      repeatType: _state.repeatType,
      specificDates: _state.specificDates,
      repeatMonthDays: _state.repeatMonthDays,
    );

    if (_state.isEditMode) {
      final result = await _updateTaskUseCase(userId: userId, task: task);
      await result.when(
        success: (_) async {
          await _notificationService.cancelTaskReminder(task.id);
          await _notificationService.scheduleTaskReminder(task);
          _updateState(_state.copyWith(isLoading: false, isSaveSuccess: true));
        },
        error: (failure) {
          _updateState(_state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
        },
      );
    } else {
      final result = await _addTaskUseCase(userId: userId, task: task);
      await result.when(
        success: (taskId) async {
          final savedTask = task.copyWith(id: taskId);
          await _notificationService.scheduleTaskReminder(savedTask);
          _updateState(_state.copyWith(isLoading: false, isSaveSuccess: true));
        },
        error: (failure) {
          _updateState(_state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ));
        },
      );
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    nameController.dispose();
    super.dispose();
  }
}
