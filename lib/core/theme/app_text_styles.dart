import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 개선된 텍스트 스타일 정의
/// 모든 텍스트는 Roboto 폰트를 기본으로 사용합니다.
/// 참고: 모든 텍스트 스타일은 copyWith() 메서드를 통해 유연하게 조정할 수 있습니다.
/// 예시:
/// ```dart
/// Text(
///   'Hello, World!',
///   style: AppTextStyles.displayBold.copyWith(color: Colors.red),
/// )
/// ```
/// 위와 같이 사용하면 displayBold 스타일을 기반으로 색상만 빨간색으로 변경됩니다.
abstract class AppTextStyles {
  AppTextStyles._(); // 인스턴스화 방지를 위한 private 생성자

  // ====== 색상 정의 ======
  static const Color _textPrimary = Color(0xFF141414);
  static const Color _textSecondary = Color(0xFF737373);
  static const Color _textTertiary = Color(0xFF9CA3AF);

  // ====== 기본 설정 ======
  static const String _fontFamily = 'Roboto';

  // 폰트 가중치 (사용 가능한 폰트 파일에 맞춤)
  static const FontWeight regular = FontWeight.w400;  // Roboto-Regular.ttf
  static const FontWeight medium = FontWeight.w500;   // Roboto-Medium.ttf
  static const FontWeight bold = FontWeight.w700;     // Roboto-Bold.ttf
  static const FontWeight black = FontWeight.w900;    // Roboto-Black.ttf

  // ====== Display 스타일 ======

  /// DisplayBold - 56px
  /// 특대형 제목, 배너, 랜딩 페이지 등 매우 큰 텍스트에 사용
  static const TextStyle displayBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 56,
    fontWeight: black, // extraBold → black (실제 폰트 파일에 맞춤)
    height: 1.2, // line-height: 67.2px
    color: _textPrimary,
    letterSpacing: -0.5,
  );

  /// DisplayRegular - 56px
  /// 특대형 제목의 일반 가중치 버전
  static const TextStyle displayRegular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 56,
    fontWeight: regular,
    height: 1.2, // line-height: 67.2px
    color: _textPrimary,
    letterSpacing: -0.5,
  );

  // ====== Heading 스타일 ======

  /// Heading1Bold - 40px
  /// 메인 제목, 섹션 구분 등 큰 텍스트에 사용
  static const TextStyle heading1Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: bold,
    height: 1.2, // line-height: 48px
    color: _textPrimary,
    letterSpacing: -0.4,
  );

  /// Heading1Regular - 40px
  /// 메인 제목의 일반 가중치 버전
  static const TextStyle heading1Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 40,
    fontWeight: regular,
    height: 1.2, // line-height: 48px
    color: _textPrimary,
    letterSpacing: -0.4,
  );

  /// Heading2Bold - 32px
  /// 서브 제목, 주요 섹션 내 제목 등에 사용
  static const TextStyle heading2Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2, // line-height: 38.4px
    color: _textPrimary,
    letterSpacing: -0.3,
  );

  /// Heading2Regular - 32px
  /// 서브 제목의 일반 가중치 버전
  static const TextStyle heading2Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: regular,
    height: 1.2, // line-height: 38.4px
    color: _textPrimary,
    letterSpacing: -0.3,
  );

  /// Heading3Bold - 28px (누락된 크기 추가)
  /// 중간 제목에 사용
  static const TextStyle heading3Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.2, // line-height: 33.6px
    color: _textPrimary,
    letterSpacing: -0.2,
  );

  /// Heading3Regular - 28px
  /// 중간 제목의 일반 가중치 버전
  static const TextStyle heading3Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: regular,
    height: 1.2, // line-height: 33.6px
    color: _textPrimary,
    letterSpacing: -0.2,
  );

  /// Heading4Bold - 24px (기존 heading3를 heading4로 변경)
  /// 소제목, 카드 제목 등에 사용
  static const TextStyle heading4Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: bold,
    height: 1.2, // line-height: 28.8px
    color: _textPrimary,
    letterSpacing: -0.1,
  );

  /// Heading4Regular - 24px
  /// 소제목의 일반 가중치 버전
  static const TextStyle heading4Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: regular,
    height: 1.2, // line-height: 28.8px
    color: _textPrimary,
    letterSpacing: -0.1,
  );

  /// Heading5Bold - 22px (누락된 크기 추가)
  /// 작은 섹션 제목에 사용
  static const TextStyle heading5Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: bold,
    height: 1.2, // line-height: 26.4px
    color: _textPrimary,
  );

  /// Heading5Regular - 22px
  /// 작은 섹션 제목의 일반 가중치 버전
  static const TextStyle heading5Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: regular,
    height: 1.2, // line-height: 26.4px
    color: _textPrimary,
  );

  /// Heading6Bold - 20px
  /// 작은 제목, 리스트 아이템 제목 등에 사용
  static const TextStyle heading6Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: bold,
    height: 1.2, // line-height: 24px
    color: _textPrimary,
  );

  /// Heading6Regular - 20px
  /// 작은 제목의 일반 가중치 버전
  static const TextStyle heading6Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: regular,
    height: 1.2, // line-height: 24px
    color: _textPrimary,
  );

  // ====== Subtitle 스타일 ======

  /// Subtitle1Bold - 18px
  /// 부제목, 강조 텍스트에 사용
  static const TextStyle subtitle1Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: bold,
    height: 1.3, // line-height: 23.4px (가독성 개선)
    color: _textPrimary,
  );

  /// Subtitle1Medium - 18px
  /// 부제목의 중간 가중치 버전
  static const TextStyle subtitle1Medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: medium,
    height: 1.3, // line-height: 23.4px
    color: _textPrimary,
  );

  /// Subtitle1Regular - 18px (일관성을 위해 추가)
  /// 부제목의 일반 가중치 버전
  static const TextStyle subtitle1Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: regular,
    height: 1.3, // line-height: 23.4px
    color: _textPrimary,
  );

  /// Subtitle2Bold - 16px (일관성을 위해 추가)
  /// 작은 부제목에 사용
  static const TextStyle subtitle2Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: bold,
    height: 1.3, // line-height: 20.8px
    color: _textPrimary,
  );

  /// Subtitle2Medium - 16px (일관성을 위해 추가)
  /// 작은 부제목의 중간 가중치 버전
  static const TextStyle subtitle2Medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.3, // line-height: 20.8px
    color: _textPrimary,
  );

  /// Subtitle2Regular - 16px
  /// 일반 부제목, 메뉴 항목 등에 사용
  static const TextStyle subtitle2Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.3, // line-height: 20.8px (가독성 개선)
    color: _textPrimary,
  );

  // ====== Body 스타일 ======

  /// Body1Bold - 16px (크기 개선: 14px → 16px)
  /// 강조된 본문 텍스트에 사용
  static const TextStyle body1Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: bold,
    height: 1.5, // line-height: 24px (읽기 편한 간격)
    color: _textPrimary,
  );

  /// Body1Medium - 16px (새로 추가)
  /// 중요한 본문 텍스트에 사용
  static const TextStyle body1Medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.5, // line-height: 24px
    color: _textPrimary,
  );

  /// Body1Regular - 16px (크기 개선: 14px → 16px)
  /// 기본 본문 텍스트에 사용
  static const TextStyle body1Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5, // line-height: 24px (가독성 개선)
    color: _textPrimary,
  );

  /// Body2Bold - 14px (새로 추가)
  /// 작은 강조 본문 텍스트에 사용
  static const TextStyle body2Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: bold,
    height: 1.4, // line-height: 19.6px
    color: _textPrimary,
  );

  /// Body2Medium - 14px (새로 추가)
  /// 작은 중요 본문 텍스트에 사용
  static const TextStyle body2Medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.4, // line-height: 19.6px
    color: _textPrimary,
  );

  /// Body2Regular - 14px
  /// 작은 본문 텍스트, 설명 등에 사용 (중복 제거)
  static const TextStyle body2Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.4, // line-height: 19.6px
    color: _textPrimary,
  );

  // ====== Button 스타일 ======

  /// Button1Bold - 16px (새로 추가)
  /// 주요 버튼 텍스트에 사용 (강조)
  static const TextStyle button1Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: bold,
    height: 1.2, // line-height: 19.2px
    color: _textPrimary,
    letterSpacing: 0.5,
  );

  /// Button1Medium - 16px
  /// 주요 버튼 텍스트에 사용
  static const TextStyle button1Medium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.2, // line-height: 19.2px
    color: _textPrimary,
    letterSpacing: 0.5,
  );

  /// Button2Bold - 14px (새로 추가)
  /// 보조 버튼 텍스트에 사용 (강조)
  static const TextStyle button2Bold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: bold,
    height: 1.2, // line-height: 16.8px
    color: _textPrimary,
    letterSpacing: 0.3,
  );

  /// Button2Regular - 14px
  /// 보조 버튼 텍스트에 사용
  static const TextStyle button2Regular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.2, // line-height: 16.8px
    color: _textPrimary,
    letterSpacing: 0.3,
  );

  // ====== Caption & Label 스타일 ======

  /// CaptionBold - 12px (새로 추가)
  /// 강조된 캡션, 주석에 사용
  static const TextStyle captionBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: bold,
    height: 1.3, // line-height: 15.6px
    color: _textSecondary,
  );

  /// CaptionMedium - 12px (새로 추가)
  /// 중요한 캡션에 사용
  static const TextStyle captionMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.3, // line-height: 15.6px
    color: _textSecondary,
  );

  /// CaptionRegular - 12px
  /// 캡션, 주석, 작은 설명 등에 사용
  static const TextStyle captionRegular = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.3, // line-height: 15.6px (가독성 개선)
    color: _textSecondary, // 색상 개선
  );

  /// Overline - 10px (새로 추가)
  /// 오버라인, 라벨, 태그 등에 사용
  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: medium,
    height: 1.2, // line-height: 12px
    color: _textTertiary,
    letterSpacing: 1.2,
  );

  /// Label - 11px (새로 추가)
  /// 폼 라벨, 카테고리 라벨 등에 사용
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: medium,
    height: 1.2, // line-height: 13.2px
    color: _textSecondary,
    letterSpacing: 0.5,
  );

  // ====== 시맨틱 색상 스타일 ======

  /// Primary 텍스트 색상 스타일들
  static const TextStyle bodyPrimary = body1Regular;
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    color: _textSecondary,
  );
  static const TextStyle bodyTertiary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    color: _textTertiary,
  );

  // ====== 확장된 유틸리티 함수 ======

  /// 텍스트 스타일에 색상 변경하기
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 텍스트 스타일에 줄 간격 변경하기
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// 텍스트 스타일에 투명도 적용하기
  static TextStyle withOpacity(TextStyle style, double opacity) {
    if (style.color == null) return style;
    final int newAlpha = (style.color!.a * opacity).round();
    return style.copyWith(
      color: Color.fromARGB(
        newAlpha,
        style.color!.r.round(),
        style.color!.g.round(),
        style.color!.b.round(),
      ),
    );
  }

  /// 텍스트 스타일에 자간 변경하기
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }

  /// 텍스트 스타일에 밑줄 추가하기
  static TextStyle withUnderline(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.underline);
  }

  /// 텍스트 스타일에 취소선 추가하기
  static TextStyle withStrikethrough(TextStyle style) {
    return style.copyWith(decoration: TextDecoration.lineThrough);
  }

  /// 텍스트 스타일에 그림자 추가하기
  static TextStyle withShadow(TextStyle style, List<Shadow> shadows) {
    return style.copyWith(shadows: shadows);
  }

  /// 텍스트 스타일에 배경색 추가하기
  static TextStyle withBackground(TextStyle style, Color backgroundColor) {
    return style.copyWith(backgroundColor: backgroundColor);
  }

  // ====== 반응형 지원 함수 ======

  /// 화면 크기에 따른 텍스트 스케일링
  static TextStyle responsive(TextStyle style, BuildContext context, {
    double minScale = 0.8,
    double maxScale = 1.2,
  }) {
    final textScaler = MediaQuery.of(context).textScaler;
    final double baseFontSize = style.fontSize ?? 16; // Provide a default if fontSize is null
    final double minAllowedFontSize = baseFontSize * minScale;
    final double maxAllowedFontSize = baseFontSize * maxScale;

    // Apply the system's text scaling to the base font size
    final double scaledFontSize = textScaler.scale(baseFontSize);

    // Clamp the scaled font size within the defined min and max
    final double finalFontSize = scaledFontSize.clamp(minAllowedFontSize, maxAllowedFontSize);

    return style.copyWith(fontSize: finalFontSize);
  }

  // ====== 편의 팩토리 메서드 ======

  /// 에러 텍스트 스타일
  static TextStyle error({double? fontSize}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 14,
      fontWeight: regular,
      height: 1.4,
      color: Colors.red,
    );
  }

  /// 성공 텍스트 스타일
  static TextStyle success({double? fontSize}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 14,
      fontWeight: regular,
      height: 1.4,
      color: Colors.green,
    );
  }

  /// 경고 텍스트 스타일
  static TextStyle warning({double? fontSize}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 14,
      fontWeight: regular,
      height: 1.4,
      color: Colors.orange,
    );
  }

  /// 링크 텍스트 스타일
  static TextStyle link({double? fontSize}) {
    return TextStyle(
      fontFamily: _fontFamily,
      fontSize: fontSize ?? 16,
      fontWeight: regular,
      height: 1.5,
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );
  }
}