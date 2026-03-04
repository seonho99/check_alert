import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/route/router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<SplashViewModel>().initializeApp();
      }
    });

    return Consumer<SplashViewModel>(
      builder: (context, viewModel, _) {
        _handleNavigation(context, viewModel);
        return const _SplashContent();
      },
    );
  }

  void _handleNavigation(BuildContext context, SplashViewModel viewModel) {
    if (!viewModel.isLoading && !viewModel.hasNavigated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;

        await viewModel.showAd();

        if (!context.mounted) return;

        viewModel.setNavigated();

        if (viewModel.isAuthenticated) {
          context.go(AppRoutes.home);
        } else {
          context.go(AppRoutes.signIn);
        }
      });
    }
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            const Spacer(),
            // 앱 로고
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            // 앱 이름
            Text(
              '체크 알리미',
              style: AppTextStyles.heading2Bold.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '매일 체크하는 습관 관리',
              style: AppTextStyles.body1Regular.copyWith(
                color: AppColors.subtleText,
              ),
            ),
            const Spacer(),
            // 로딩 인디케이터
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.primaryLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
        ),
      ),
    );
  }
}
