import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 원형 진행률 위젯
class CircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;

  const CircularProgress({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final color = progressColor ??
        (progress >= 1.0 ? AppColors.success : AppColors.primary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          if (child != null) Center(child: child),
        ],
      ),
    );
  }
}
