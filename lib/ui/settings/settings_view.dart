import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/route/router.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/banner_ad_widget.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecase/auth/sign_out_usecase.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthRepository>().currentUserId ?? '로그인 필요';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정'),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // 알림 섹션
          _buildSectionLabel('알림'),
          const SizedBox(height: 8),
          _buildCard(
            children: [
              _buildTile(
                icon: Icons.notifications_active_outlined,
                iconColor: AppColors.primary,
                title: '알림 권한 요청',
                subtitle: '알림을 받으려면 권한이 필요합니다',
                trailing: const Icon(Icons.chevron_right, color: AppColors.subtleText, size: 20),
                onTap: () async {
                  final notificationService =
                      context.read<LocalNotificationService>();
                  final granted = await notificationService.requestPermission();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          granted ? '알림 권한이 허용되었습니다' : '알림 권한이 거부되었습니다',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 앱 정보 섹션
          _buildSectionLabel('앱 정보'),
          const SizedBox(height: 8),
          _buildCard(
            children: [
              _buildTile(
                icon: Icons.info_outline,
                iconColor: AppColors.subtleText,
                title: '버전',
                trailing: Text(
                  '1.0.0',
                  style: AppTextStyles.body2Regular.copyWith(
                    color: AppColors.subtleText,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildTile(
                icon: Icons.shield_outlined,
                iconColor: AppColors.subtleText,
                title: '개인정보처리방침',
                trailing: const Icon(Icons.chevron_right, color: AppColors.subtleText, size: 20),
                onTap: () => context.push(AppRoutes.legalPrivacy),
              ),
              const Divider(height: 1, indent: 56),
              _buildTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.subtleText,
                title: '서비스 이용약관',
                trailing: const Icon(Icons.chevron_right, color: AppColors.subtleText, size: 20),
                onTap: () => context.push(AppRoutes.legalTerms),
              ),
              // const Divider(height: 1, indent: 56),
              // _buildTile(
              //   icon: Icons.code_outlined,
              //   iconColor: AppColors.subtleText,
              //   title: '오픈소스 라이선스',
              //   trailing: const Icon(Icons.chevron_right, color: AppColors.subtleText, size: 20),
              //   onTap: () => showLicensePage(
              //     context: context,
              //     applicationName: '체크 알리미',
              //     applicationVersion: '1.0.0',
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 24),

          // 계정 섹션
          _buildSectionLabel('계정'),
          const SizedBox(height: 8),
          _buildCard(
            children: [
              _buildTile(
                icon: Icons.person_outline,
                iconColor: AppColors.primary,
                title: '계정 정보',
                subtitle: userId,
              ),
              const Divider(height: 1, indent: 56),
              _buildTile(
                icon: Icons.logout_outlined,
                iconColor: AppColors.error,
                title: '로그아웃',
                titleColor: AppColors.error,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.captionMedium.copyWith(
          color: AppColors.subtleText,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1Medium.copyWith(
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.captionRegular.copyWith(
                color: AppColors.subtleText,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_outlined,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text('로그아웃', style: AppTextStyles.subtitle1Bold),
            const SizedBox(height: 8),
            Text(
              '정말 로그아웃하시겠습니까?',
              style: AppTextStyles.body2Regular.copyWith(
                color: AppColors.subtleText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
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
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      final signOutUseCase = context.read<SignOutUseCase>();
                      await signOutUseCase();
                      if (context.mounted) {
                        context.go(AppRoutes.signIn);
                      }
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
                      '로그아웃',
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
