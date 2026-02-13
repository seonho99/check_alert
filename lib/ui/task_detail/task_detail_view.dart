import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../domain/model/repeat_type.dart';
import 'task_detail_state.dart';
import 'task_detail_viewmodel.dart';

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskDetailViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.state;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
            title: Text(state.pageTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton(
                  onPressed: state.isValid && !state.isLoading
                      ? () async {
                          await viewModel.save();
                          if (context.mounted && viewModel.state.isSaveSuccess) {
                            context.pop();
                          }
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('저장'),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: state.isLoading && state.isEditMode && state.name.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.hasError)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    size: 18, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: AppTextStyles.body2Medium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 항목 이름
                        _buildSection(
                          children: [
                            _buildSectionLabel('알림 메세지'),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: viewModel.nameController,
                              validator: Validators.validateTaskName,
                              style: AppTextStyles.body1Regular,
                              decoration: InputDecoration(
                                hintText: '예: 물 마시기',
                                filled: true,
                                fillColor: AppColors.surfaceDim,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 카테고리
                        _buildSection(
                          children: [
                            _buildSectionLabel('카테고리'),
                            const SizedBox(height: 10),
                            _buildCategorySelector(viewModel, state),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 반복 설정
                        _buildSection(
                          children: [
                            _buildSectionLabel('반복 설정'),
                            const SizedBox(height: 10),
                            _buildRepeatTypeSelector(viewModel, state),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: switch (state.repeatType) {
                                RepeatType.weekly =>
                                  _buildDaySelector(viewModel, state),
                                RepeatType.monthly =>
                                  _buildMonthDaySelector(viewModel, state),
                                RepeatType.once =>
                                  _buildMultiDatePicker(
                                      context, viewModel, state),
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // 알림 시간
                        _buildSection(
                          children: [
                            _buildSectionLabel('알림 시간'),
                            const SizedBox(height: 10),
                            _buildTimePicker(context, viewModel, state),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ── 공통 섹션 카드 ──

  Widget _buildSection({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: AppTextStyles.captionMedium.copyWith(
        color: AppColors.subtleText,
        letterSpacing: 0.2,
      ),
    );
  }

  // ── 카테고리 ──

  Widget _buildCategorySelector(
      TaskDetailViewModel viewModel, TaskDetailState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.categories.map((category) {
        final isSelected = state.category == category;
        return GestureDetector(
          onTap: () => viewModel.selectCategory(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.divider,
              ),
            ),
            child: Text(
              category,
              style: AppTextStyles.body2Medium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 반복 유형 (세그먼트 컨트롤) ──

  Widget _buildRepeatTypeSelector(
      TaskDetailViewModel viewModel, TaskDetailState state) {
    const types = [
      (RepeatType.weekly, '요일반복'),
      (RepeatType.monthly, '월간반복'),
      (RepeatType.once, '특정날짜'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: types.map((entry) {
          final (type, label) = entry;
          final isSelected = state.repeatType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => viewModel.selectRepeatType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.body2Medium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.subtleText,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 요일 선택 ──

  Widget _buildDaySelector(
      TaskDetailViewModel viewModel, TaskDetailState state) {
    final allSelected = state.repeatDays.length == 7;

    return Column(
      key: const ValueKey('day_selector'),
      children: [
        Row(
          children: List.generate(7, (index) {
            final day = index + 1;
            final isSelected = state.repeatDays.contains(day);
            return Expanded(
              child: GestureDetector(
                onTap: () => viewModel.toggleDay(day),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 3,
                    right: index == 6 ? 0 : 3,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceDim,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        AppConstants.weekdayNames[index],
                        style: AppTextStyles.body2Bold.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.subtleText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: viewModel.setAllDays,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: allSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceDim,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: allSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '매일',
                style: AppTextStyles.body2Medium.copyWith(
                  color: allSelected ? AppColors.primary : AppColors.subtleText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 월간 일자 선택 (1~31) ──

  Widget _buildMonthDaySelector(
      TaskDetailViewModel viewModel, TaskDetailState state) {
    return Column(
      key: const ValueKey('month_day_selector'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7열 그리드로 1~31 표시
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = state.repeatMonthDays.contains(day);
            return GestureDetector(
              onTap: () => viewModel.toggleMonthDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: AppTextStyles.body2Bold.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.subtleText,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (state.repeatMonthDays.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '매월 ${(List<int>.from(state.repeatMonthDays)..sort()).map((d) => '$d일').join(', ')}',
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }

  // ── 날짜 선택 ──

  Widget _buildMultiDatePicker(
    BuildContext context,
    TaskDetailViewModel viewModel,
    TaskDetailState state,
  ) {
    final now = DateTime.now();
    return Column(
      key: const ValueKey('date_picker'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: AppColors.surfaceDim,
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.multi,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
                selectedDayHighlightColor: AppColors.primary,
                dayTextStyle: AppTextStyles.body2Regular,
                selectedDayTextStyle: AppTextStyles.body2Bold.copyWith(
                  color: Colors.white,
                ),
                weekdayLabelTextStyle: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.subtleText,
                ),
              ),
              value: state.specificDates,
              onValueChanged: (dates) {
                viewModel.setSpecificDates(
                  dates.whereType<DateTime>().toList(),
                );
              },
            ),
          ),
        ),
        if (state.specificDates.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.specificDates.map((date) {
              final label =
                  '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
              return Container(
                padding: const EdgeInsets.only(
                    left: 12, right: 6, top: 6, bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.body2Medium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => viewModel.removeSpecificDate(date),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── 시간 선택 ──

  Widget _buildTimePicker(
    BuildContext context,
    TaskDetailViewModel viewModel,
    TaskDetailState state,
  ) {
    final isAM = state.reminderHour < 12;
    final displayHour = state.reminderHour == 0
        ? 12
        : (state.reminderHour > 12
            ? state.reminderHour - 12
            : state.reminderHour);
    final hourText = displayHour.toString().padLeft(2, '0');
    final minuteText = state.reminderMinute.toString().padLeft(2, '0');

    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialEntryMode: TimePickerEntryMode.inputOnly,
          initialTime: TimeOfDay(
              hour: state.reminderHour, minute: state.reminderMinute),
        );
        if (time != null) {
          viewModel.setReminderTime(time.hour, time.minute);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          // 시 박스
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  hourText,
                  style: AppTextStyles.heading2Bold.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                ':',
                style: AppTextStyles.heading2Bold.copyWith(
                  color: AppColors.subtleText.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          // 분 박스
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  minuteText,
                  style: AppTextStyles.heading2Bold.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 오전/오후
          Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _buildPeriodCell('오전', isAM),
                  _buildPeriodCell('오후', !isAM),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodCell(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionBold.copyWith(
          color: isActive ? Colors.white : AppColors.subtleText,
        ),
      ),
    );
  }
}
