import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/model/task_model.dart';

part 'task_list_state.freezed.dart';

@freezed
class TaskListState with _$TaskListState {
  const TaskListState({
    @override required this.tasks,
    @override required this.filteredTasks,
    @override required this.isLoading,
    @override required this.selectedCategory,
    @override this.errorMessage,
    @override required this.focusedDay,
    @override this.selectedDay,
  });

  @override
  final List<TaskModel> tasks;
  @override
  final List<TaskModel> filteredTasks;
  @override
  final bool isLoading;
  @override
  final String selectedCategory;
  @override
  final String? errorMessage;
  @override
  final DateTime focusedDay;
  @override
  final DateTime? selectedDay;

  factory TaskListState.initial() => TaskListState(
        tasks: [],
        filteredTasks: [],
        isLoading: false,
        selectedCategory: '전체',
        focusedDay: DateTime.now(),
      );
}

extension TaskListStateExtension on TaskListState {
  bool get hasError => errorMessage != null;
  bool get isEmpty => !isLoading && tasks.isEmpty;
  int get activeCount => tasks.where((t) => t.isActive).length;
}
