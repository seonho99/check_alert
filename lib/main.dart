import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/services/local_notification_service.dart';
import 'data/datasource/task_firebase_datasource_impl.dart';
import 'data/mapper/task_model_mapper.dart';
import 'domain/model/task_model.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/route/router.dart';
import 'core/di/core_providers.dart';
import 'core/di/data_providers.dart';
import 'core/di/domain_providers.dart';
import 'core/di/viewmodel_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화
  await Firebase.initializeApp();

  // 2. 날짜 포맷 초기화 (한국어)
  await initializeDateFormatting('ko_KR', null);

  // 3. 로컬 알림 초기화
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();

  // 4. 로그인된 사용자가 있으면 알림 재스케줄링 (재부팅 대응)
  _rescheduleNotifications(localNotificationService);

  runApp(const CheckAlertApp());
}

/// 앱 시작 시 알림 재스케줄링 (비동기로 백그라운드 실행)
Future<void> _rescheduleNotifications(
    LocalNotificationService notificationService) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .get();

    final tasks = snapshot.docs
        .map((doc) => TaskFirebaseDataSourceImpl.documentToTaskDto(doc).toModel())
        .whereType<TaskModel>()
        .toList();

    await notificationService.rescheduleAll(tasks);
    debugPrint('알림 재스케줄링 완료: ${tasks.length}개 태스크');
  } catch (e) {
    debugPrint('알림 재스케줄링 실패: $e');
  }
}

class CheckAlertApp extends StatelessWidget {
  const CheckAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...buildCoreProviders(),
        ...buildDataProviders(),
        ...buildDomainProviders(),
        ...buildViewModelProviders(),
      ],
      child: MaterialApp.router(
        title: '체크 알리미',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.onSurface,
            titleTextStyle: AppTextStyles.heading6Bold,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: AppColors.surface,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.subtleText,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primaryLight,
            labelStyle: AppTextStyles.body2Regular,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.background,
            labelStyle: AppTextStyles.body2Regular,
            hintStyle: AppTextStyles.withColor(
              AppTextStyles.body2Regular,
              AppColors.subtleText,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: AppTextStyles.button1Medium,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.button2Regular,
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: AppColors.divider,
            thickness: 1,
            space: 1,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.surface,
            // 시/분 입력 박스
            hourMinuteColor: AppColors.background,
            hourMinuteTextColor: AppColors.onSurface,
            hourMinuteTextStyle: AppTextStyles.heading2Bold,
            hourMinuteShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            // 다이얼 (시계)
            dialBackgroundColor: AppColors.background,
            dialHandColor: AppColors.primary,
            dialTextColor: AppColors.onSurface,
            dialTextStyle: AppTextStyles.body1Medium,
            // 오전/오후
            dayPeriodColor: AppColors.background,
            dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.subtleText;
            }),
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            dayPeriodBorderSide: BorderSide.none,
            dayPeriodTextStyle: AppTextStyles.body2Bold,
            // 헤더/제목
            helpTextStyle: AppTextStyles.captionMedium.copyWith(
              color: AppColors.subtleText,
            ),
            // 전체 형태
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            // 입력 모드
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
            // 확인/취소 버튼
            confirmButtonStyle: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.button1Medium,
            ),
            cancelButtonStyle: TextButton.styleFrom(
              foregroundColor: AppColors.subtleText,
              textStyle: AppTextStyles.button2Regular,
            ),
            entryModeIconColor: AppColors.subtleText,
          ),
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ko', 'KR'),
      ),
    );
  }
}
