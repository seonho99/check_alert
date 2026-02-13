import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 팔레트 정의
abstract class AppColors {
  AppColors._(); // 인스턴스화 방지를 위한 private 생성자

  // ====== 앱 기본 색상 (Teal Blue) ======

  // Primary — 틸 블루 계열
  static const Color primary = Color(0xFF0D9488);       // Teal 600
  static const Color primaryDark = Color(0xFF115E59);    // Teal 800
  static const Color primaryLight = Color(0xFFCCFBF1);   // Teal 50

  // Secondary
  static const Color secondary = Color(0xFF0EA5E9);     // Sky 500

  // Accent
  static const Color accent = Color(0xFFF59E0B);        // Amber 500

  // Background & Surface (iOS Grouped Style)
  static const Color background = Color(0xFFF2F2F7);    // iOS systemGroupedBackground
  static const Color surface = Color(0xFFFFFFFF);       // 흰색 (카드/AppBar/BottomNav)
  static const Color surfaceDim = Color(0xFFF2F2F7);    // 카드 내부 인풋/버튼 (배경과 동일 그레이)

  // Text
  static const Color onSurface = Color(0xFF1C1917);     // Stone 900
  static const Color subtleText = Color(0xFF78716C);    // Stone 500

  // Status
  static const Color error = Color(0xFFEF4444);         // Red 500
  static const Color success = Color(0xFF10B981);       // Emerald 500
  static const Color warning = Color(0xFFF59E0B);       // Amber 500

  // Divider
  static const Color divider = Color(0xFFE7E5E4);       // Stone 200

  // ====== 히트맵 (캘린더 달성률) ======

  static const Color heatmap0 = Color(0xFFE7E5E4);   // 0%  — Stone 200
  static const Color heatmap1 = Color(0xFFCCFBF1);   // 1-33%  — Teal 50
  static const Color heatmap2 = Color(0xFF5EEAD4);   // 34-66% — Teal 300
  static const Color heatmap3 = Color(0xFF14B8A6);   // 67-99% — Teal 500
  static const Color heatmap4 = Color(0xFF0F766E);   // 100%   — Teal 700

  /// 달성률에 따른 히트맵 색상 반환
  static Color heatmapColor(double rate) {
    if (rate <= 0) return heatmap0;
    if (rate <= 0.33) return heatmap1;
    if (rate <= 0.66) return heatmap2;
    if (rate < 1.0) return heatmap3;
    return heatmap4;
  }

  // ====== 월별 차트 색상 팔레트 ======

  /// 월별 지출 색상 팔레트 (1월~12월)
  static const List<Color> monthlyExpenseColors = [
    Color(0xFF4F46E5), // 1월 - 인디고
    Color(0xFF06B6D4), // 2월 - 시안
    Color(0xFF10B981), // 3월 - 에메랄드
    Color(0xFF84CC16), // 4월 - 라임
    Color(0xFFF59E0B), // 5월 - 앰버
    Color(0xFFEF4444), // 6월 - 레드
    Color(0xFFEC4899), // 7월 - 핑크
    Color(0xFF8B5CF6), // 8월 - 바이올렛
    Color(0xFF3B82F6), // 9월 - 블루
    Color(0xFF14B8A6), // 10월 - 틸
    Color(0xFFF97316), // 11월 - 오렌지
    Color(0xFF6366F1), // 12월 - 인디고
  ];

  /// 월별 수입 색상 팔레트 (1월~12월) - 지출과 다른 색상
  static const List<Color> monthlyIncomeColors = [
    Color(0xFF22C55E), // 1월 - 그린
    Color(0xFFFBBF24), // 2월 - 노랑
    Color(0xFFF472B6), // 3월 - 핑크
    Color(0xFF8B5CF6), // 4월 - 보라
    Color(0xFF06B6D4), // 5월 - 스카이블루
    Color(0xFFFB7185), // 6월 - 로즈
    Color(0xFF34D399), // 7월 - 민트
    Color(0xFFFDE047), // 8월 - 라임
    Color(0xFFA78BFA), // 9월 - 라벤더
    Color(0xFF60A5FA), // 10월 - 라이트블루
    Color(0xFFFF8A80), // 11월 - 코랄
    Color(0xFF81C784), // 12월 - 라이트그린
  ];

  /// 월 인덱스(1-12)에 해당하는 지출 색상 반환
  static Color getMonthlyExpenseColor(int month) {
    if (month < 1 || month > 12) return Colors.grey;
    return monthlyExpenseColors[month - 1];
  }

  /// 월 인덱스(1-12)에 해당하는 수입 색상 반환
  static Color getMonthlyIncomeColor(int month) {
    if (month < 1 || month > 12) return Colors.grey;
    return monthlyIncomeColors[month - 1];
  }
}
