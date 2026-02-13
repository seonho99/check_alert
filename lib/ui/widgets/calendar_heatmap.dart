import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 월별 캘린더 히트맵 위젯
class CalendarHeatmap extends StatelessWidget {
  final int year;
  final int month;
  final double Function(int day) completionRateForDay;
  final void Function(int day)? onDayTap;

  const CalendarHeatmap({
    super.key,
    required this.year,
    required this.month,
    required this.completionRateForDay,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=월 ~ 7=일

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 요일 헤더
            _buildWeekdayHeader(),
            const SizedBox(height: 8),
            // 날짜 그리드
            _buildDayGrid(daysInMonth, firstWeekday),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.subtleText,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDayGrid(int daysInMonth, int firstWeekday) {
    final rows = <Widget>[];
    int day = 1;

    // 주 단위로 행 생성
    while (day <= daysInMonth) {
      final cells = <Widget>[];

      for (int weekday = 1; weekday <= 7; weekday++) {
        if ((rows.isEmpty && weekday < firstWeekday) || day > daysInMonth) {
          cells.add(const Expanded(child: SizedBox(height: 40)));
        } else {
          final currentDay = day;
          final rate = completionRateForDay(currentDay);

          cells.add(Expanded(
            child: GestureDetector(
              onTap: onDayTap != null ? () => onDayTap!(currentDay) : null,
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: rate < 0
                      ? AppColors.background
                      : AppColors.heatmapColor(rate),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$currentDay',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: rate >= 0.67
                          ? Colors.white
                          : AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ));
          day++;
        }
      }

      rows.add(Row(children: cells));
    }

    return Column(children: rows);
  }
}
