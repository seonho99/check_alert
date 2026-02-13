import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/model/repeat_type.dart';

part 'task_detail_state.freezed.dart';

@freezed
class TaskDetailState with _$TaskDetailState {
  const TaskDetailState({
    @override required this.name,
    @override required this.category,
    @override required this.repeatDays,
    @override required this.reminderHour,
    @override required this.reminderMinute,
    @override required this.isActive,
    @override required this.isLoading,
    @override required this.isSaveSuccess,
    @override required this.isEditMode,
    @override required this.repeatType,
    @override this.taskId,
    @override this.errorMessage,
    @override required this.specificDates,
    @override required this.repeatMonthDays,
  });

  @override
  final String name;
  @override
  final String category;
  @override
  final List<int> repeatDays;
  @override
  final int reminderHour;
  @override
  final int reminderMinute;
  @override
  final bool isActive;
  @override
  final bool isLoading;
  @override
  final bool isSaveSuccess;
  @override
  final bool isEditMode;
  @override
  final RepeatType repeatType;
  @override
  final String? taskId;
  @override
  final String? errorMessage;
  @override
  final List<DateTime> specificDates;
  @override
  final List<int> repeatMonthDays;

  factory TaskDetailState.initial() => TaskDetailState(
        name: '',
        category: AppConstants.categories.first,
        repeatDays: AppConstants.defaultRepeatDays,
        reminderHour: AppConstants.defaultReminderHour,
        reminderMinute: AppConstants.defaultReminderMinute,
        isActive: true,
        isLoading: false,
        isSaveSuccess: false,
        isEditMode: false,
        repeatType: RepeatType.weekly,
        specificDates: [],
        repeatMonthDays: [],
      );
}

extension TaskDetailStateExtension on TaskDetailState {
  bool get isValid {
    if (name.trim().isEmpty) return false;
    switch (repeatType) {
      case RepeatType.weekly:
        return repeatDays.isNotEmpty;
      case RepeatType.monthly:
        return repeatMonthDays.isNotEmpty;
      case RepeatType.once:
        return specificDates.isNotEmpty;
    }
  }

  bool get hasError => errorMessage != null;
  String get pageTitle => isEditMode ? '항목 수정' : '항목 추가';
}
