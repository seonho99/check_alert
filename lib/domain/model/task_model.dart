import 'package:freezed_annotation/freezed_annotation.dart';

import 'repeat_type.dart';

part 'task_model.freezed.dart';

/// 체크 항목 도메인 모델 (순수한 데이터 구조체)
@freezed
sealed class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String userId,
    required String name,
    required String category,
    required List<int> repeatDays,
    required int reminderHour,
    required int reminderMinute,
    required bool isActive,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    required RepeatType repeatType,
    @Default([]) List<DateTime> specificDates,
    @Default([]) List<int> repeatMonthDays,
  }) = _TaskModel;
}

/// TaskModel 편의 확장
extension TaskModelExtension on TaskModel {
  /// 오늘 요일에 해당하는 항목인지 확인
  bool get isTodayTask {
    switch (repeatType) {
      case RepeatType.weekly:
        final today = DateTime.now().weekday;
        return repeatDays.contains(today);
      case RepeatType.monthly:
        final todayDay = DateTime.now().day;
        return repeatMonthDays.contains(todayDay);
      case RepeatType.once:
        if (specificDates.isEmpty) return false;
        final now = DateTime.now();
        return specificDates.any((d) =>
            d.year == now.year && d.month == now.month && d.day == now.day);
    }
  }

  /// 특정 날짜에 해당하는 항목인지 확인
  bool isTaskForDate(DateTime date) {
    switch (repeatType) {
      case RepeatType.weekly:
        return repeatDays.contains(date.weekday);
      case RepeatType.monthly:
        return repeatMonthDays.contains(date.day);
      case RepeatType.once:
        if (specificDates.isEmpty) return false;
        return specificDates.any((d) =>
            d.year == date.year && d.month == date.month && d.day == date.day);
    }
  }

  /// 알림 시간 포맷 (HH:mm)
  String get reminderTimeFormatted =>
      '${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}';

  /// 반복 요일 텍스트
  String get repeatDaysText {
    switch (repeatType) {
      case RepeatType.weekly:
        const dayNames = ['월', '화', '수', '목', '금', '토', '일'];
        if (repeatDays.length == 7) return '매일';
        return repeatDays.map((d) => dayNames[d - 1]).join(', ');
      case RepeatType.monthly:
        if (repeatMonthDays.isEmpty) return '일자 미지정';
        final sorted = List<int>.from(repeatMonthDays)..sort();
        return '매월 ${sorted.map((d) => '$d일').join(', ')}';
      case RepeatType.once:
        if (specificDates.isEmpty) return '날짜 미지정';
        final first = specificDates.first;
        final firstText = '${first.year}.${first.month.toString().padLeft(2, '0')}.${first.day.toString().padLeft(2, '0')}';
        if (specificDates.length == 1) return firstText;
        return '$firstText 외 ${specificDates.length - 1}일';
    }
  }
}
