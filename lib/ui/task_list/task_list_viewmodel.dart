import 'package:flutter/material.dart';

import '../../core/services/local_notification_service.dart';
import '../../domain/model/task_model.dart';
import '../../domain/usecase/task/get_tasks_usecase.dart';
import '../../domain/usecase/task/delete_task_usecase.dart';
import '../../domain/repository/auth_repository.dart';
import 'task_list_state.dart';

class TaskListViewModel extends ChangeNotifier {
  final GetTasksUseCase _getTasksUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final AuthRepository _authRepository;
  final LocalNotificationService _notificationService;

  TaskListState _state = TaskListState.initial();
  TaskListState get state => _state;
  bool _disposed = false;

  TaskListViewModel({
    required GetTasksUseCase getTasksUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required AuthRepository authRepository,
    required LocalNotificationService notificationService,
  })  : _getTasksUseCase = getTasksUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _authRepository = authRepository,
        _notificationService = notificationService {
    loadTasks();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _updateState(TaskListState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  String? get _userId => _authRepository.currentUserId;

  /// 전체 항목 로드
  Future<void> loadTasks() async {
    final userId = _userId;
    if (userId == null) return;

    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getTasksUseCase(userId);
    result.when(
      success: (tasks) {
        _updateState(_state.copyWith(
          isLoading: false,
          tasks: tasks,
          filteredTasks: _filterTasks(tasks, _state.selectedCategory),
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

  /// 카테고리 필터 변경
  void selectCategory(String category) {
    _updateState(_state.copyWith(
      selectedCategory: category,
      filteredTasks: _filterTasks(_state.tasks, category),
      selectedDay: null,
    ));
  }

  /// 달력 날짜 선택
  void selectDay(DateTime day) {
    _updateState(_state.copyWith(selectedDay: day, focusedDay: day));
  }

  /// 달력 포커스 월 변경
  void changeFocusedDay(DateTime day) {
    _updateState(_state.copyWith(focusedDay: day));
  }

  /// 특정 날짜의 태스크 목록 반환
  List<TaskModel> getTasksForDay(DateTime day) {
    return _state.tasks.where((t) => t.isTaskForDate(day)).toList();
  }

  /// 항목 삭제
  Future<void> deleteTask(String taskId) async {
    final userId = _userId;
    if (userId == null) return;

    // Optimistic UI: 로컬에서 먼저 제거
    final previousTasks = _state.tasks;
    final updatedTasks = previousTasks.where((t) => t.id != taskId).toList();
    _updateState(_state.copyWith(
      tasks: updatedTasks,
      filteredTasks: _filterTasks(updatedTasks, _state.selectedCategory),
    ));

    final result = await _deleteTaskUseCase(userId: userId, taskId: taskId);
    result.when(
      success: (_) {
        _notificationService.cancelTaskReminder(taskId);
      },
      error: (failure) {
        // 실패 시 원래 목록으로 복원
        _updateState(_state.copyWith(
          tasks: previousTasks,
          filteredTasks: _filterTasks(previousTasks, _state.selectedCategory),
          errorMessage: failure.message,
        ));
      },
    );
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks, String category) {
    if (category == '전체') return tasks;
    return tasks.where((t) => t.category == category).toList();
  }
}
