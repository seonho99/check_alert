import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/model/task_model.dart';

/// 체크 항목 카드 위젯
class CheckItemCard extends StatelessWidget {
  final TaskModel task;
  final bool isCompleted;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onCheckChanged;

  const CheckItemCard({
    super.key,
    required this.task,
    required this.isCompleted,
    this.subtitle,
    this.onTap,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.check_circle_outline, color: AppColors.primary),
          ),
        ),
        title: Text(
          task.name,
          style: AppTextStyles.body1Regular.copyWith(
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppColors.subtleText : AppColors.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTextStyles.captionRegular,
              )
            : null,
        trailing: Checkbox(
          value: isCompleted,
          onChanged: onCheckChanged != null ? (_) => onCheckChanged!() : null,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onTap: onTap ?? onCheckChanged,
      ),
    );
  }
}
