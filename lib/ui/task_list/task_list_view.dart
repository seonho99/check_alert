import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_constants.dart';
import '../../core/route/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/model/task_model.dart';
import 'task_list_state.dart';
import 'task_list_viewmodel.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskListViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('항목 관리'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await context.push(AppRoutes.taskAdd);
                  if (context.mounted) {
                    viewModel.loadTasks();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push(AppRoutes.settings),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody(context, viewModel, state)),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await context.push(AppRoutes.taskAdd);
              if (context.mounted) {
                viewModel.loadTasks();
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    TaskListViewModel viewModel,
    TaskListState state,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage!,
                style: AppTextStyles.error()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadTasks,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildCategoryChips(viewModel),
        Expanded(
          child: state.selectedCategory == '전체'
              ? _buildCalendarView(context, viewModel, state)
              : state.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTaskList(context, viewModel, state),
        ),
      ],
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    TaskListViewModel viewModel,
    TaskListState state,
  ) {
    final selectedDayTasks = state.selectedDay != null
        ? viewModel.getTasksForDay(state.selectedDay!)
        : <TaskModel>[];

    return Column(
      children: [
        TableCalendar<TaskModel>(
          locale: 'ko_KR',
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: state.focusedDay,
          selectedDayPredicate: (day) =>
              state.selectedDay != null && isSameDay(state.selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            viewModel.selectDay(selectedDay);
          },
          onPageChanged: (focusedDay) {
            viewModel.changeFocusedDay(focusedDay);
          },
          eventLoader: viewModel.getTasksForDay,
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: '월'},
          startingDayOfWeek: StartingDayOfWeek.sunday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTextStyles.subtitle1Bold,
            leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primaryDark),
            rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primaryDark),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (date, locale) {
              const dayNames = ['일', '월', '화', '수', '목', '금', '토'];
              return dayNames[date.weekday % 7];
            },
            weekdayStyle: AppTextStyles.captionRegular.copyWith(
              color: AppColors.subtleText,
            ),
            weekendStyle: AppTextStyles.captionRegular.copyWith(
              color: AppColors.subtleText,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 0,
            todayDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          calendarBuilders: CalendarBuilders<TaskModel>(
            defaultBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, viewModel, isToday: false, isSelected: false);
            },
            todayBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, viewModel, isToday: true, isSelected: false);
            },
            selectedBuilder: (context, day, focusedDay) {
              return _buildDayCell(day, viewModel, isToday: isSameDay(day, DateTime.now()), isSelected: true);
            },
            markerBuilder: (context, day, events) {
              return const SizedBox.shrink();
            },
          ),
          rowHeight: 72,
        ),
        const Divider(height: 1),
        // 선택된 날짜의 태스크 목록
        Expanded(
          child: state.selectedDay == null
              ? Center(
                  child: Text(
                    '날짜를 선택하면 해당 날짜의 항목을 볼 수 있어요',
                    style: AppTextStyles.body2Regular.copyWith(
                      color: AppColors.subtleText,
                    ),
                  ),
                )
              : selectedDayTasks.isEmpty
                  ? Center(
                      child: Text(
                        '이 날짜에 등록된 항목이 없어요',
                        style: AppTextStyles.body2Regular.copyWith(
                          color: AppColors.subtleText,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: selectedDayTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = selectedDayTasks[index];
                        return _buildTaskCard(context, viewModel, task);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime day, TaskListViewModel viewModel, {required bool isToday, required bool isSelected}) {
    final textColor = day.weekday == DateTime.sunday
        ? const Color(0xFFEF4444)
        : day.weekday == DateTime.saturday
            ? const Color(0xFF3B82F6)
            : Colors.black87;

    final events = viewModel.getTasksForDay(day);
    // 카테고리별 색상 중복 제거하여 점(dot) 표시
    final dotColors = events.map((t) => _categoryColor(t.category)).toSet().toList();

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          // 날짜 숫자
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: isToday
                ? const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  )
                : isSelected
                    ? BoxDecoration(
                        color: AppColors.primaryDark,
                        shape: BoxShape.circle,
                      )
                    : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                color: (isToday || isSelected) ? Colors.white : textColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 카테고리 색상 점
          if (dotColors.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dotColors.take(4).map((color) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(TaskListViewModel viewModel) {
    final categories = ['전체', ...AppConstants.categories];
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = viewModel.state.selectedCategory == category;
          return FilterChip(
            label: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => viewModel.selectCategory(category),
            selectedColor: AppColors.primary,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '아직 체크 항목이 없어요',
            style: AppTextStyles.subtitle2Medium.copyWith(
              color: AppColors.subtleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+ 버튼을 눌러 새 항목을 추가하세요',
            style: AppTextStyles.body2Regular.copyWith(
              color: AppColors.subtleText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    TaskListViewModel viewModel,
    TaskListState state,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: state.filteredTasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = state.filteredTasks[index];
        return _buildTaskCard(context, viewModel, task);
      },
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskListViewModel viewModel,
    TaskModel task,
  ) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.4,
        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              await context.push('${AppRoutes.taskDetail}?id=${task.id}');
              if (context.mounted) {
                viewModel.loadTasks();
              }
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, size: 22),
                SizedBox(height: 4),
                Text('수정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => _showDeleteDialog(context, viewModel, task),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            padding: EdgeInsets.zero,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outlined, size: 22),
                SizedBox(height: 4),
                Text('삭제', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _categoryColor(task.category).withValues(alpha: 0.15),
            child: Icon(_categoryIcon(task.category), color: _categoryColor(task.category), size: 20),
          ),
          title: Text(
            task.name,
            style: AppTextStyles.body1Medium.copyWith(
              color: task.isActive ? null : AppColors.subtleText,
              decoration: task.isActive ? null : TextDecoration.lineThrough,
            ),
          ),
          subtitle: Text(
            '${task.repeatDaysText} · ${task.reminderTimeFormatted} 알림',
            style: AppTextStyles.captionRegular.copyWith(
              fontSize: 13,
              color: task.isActive ? AppColors.subtleText : AppColors.divider,
            ),
          ),
          onTap: () async {
            await context.push('${AppRoutes.taskDetail}?id=${task.id}');
            if (context.mounted) {
              viewModel.loadTasks();
            }
          },
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      '건강' => Icons.medication_outlined,
      '납부' => Icons.receipt_long_outlined,
      '운동' => Icons.fitness_center_outlined,
      '공부' => Icons.menu_book_outlined,
      '게임' => Icons.sports_esports_outlined,
      '루틴' => Icons.repeat_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  Color _categoryColor(String category) {
    return switch (category) {
      '전체' => AppColors.primary,
      '건강' => const Color(0xFFEF4444),
      '납부' => const Color(0xFFF59E0B),
      '운동' => const Color(0xFF3B82F6),
      '공부' => const Color(0xFF8B5CF6),
      '게임' => const Color(0xFF10B981),
      '루틴' => AppColors.primary,
      _ => AppColors.subtleText,
    };
  }

  void _showDeleteDialog(
    BuildContext context,
    TaskListViewModel viewModel,
    TaskModel task,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 아이콘
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '항목 삭제',
              style: AppTextStyles.subtitle1Bold,
            ),
            const SizedBox(height: 8),
            Text(
              '"${task.name}" 항목을 삭제할까요?\n삭제된 항목은 복구할 수 없습니다.',
              style: AppTextStyles.body2Regular.copyWith(
                color: AppColors.subtleText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: AppTextStyles.body2Medium.copyWith(
                        color: AppColors.subtleText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      viewModel.deleteTask(task.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '삭제',
                      style: AppTextStyles.body2Medium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
