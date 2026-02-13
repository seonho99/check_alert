/// 입력값 검증 유틸리티
class Validators {
  Validators._();

  /// 이메일 정규식
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// 이메일 형식 검증
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return '유효하지 않은 이메일 형식입니다';
    }
    return null;
  }

  /// 비밀번호 검증 (최소 6자)
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }

  /// 비밀번호 확인 검증
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  /// 필수 입력 검증
  static String? validateRequired(String? value, [String fieldName = '값']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// 체크 항목 이름 검증
  static String? validateTaskName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '항목 이름을 입력해주세요';
    }
    if (value.trim().length > 30) {
      return '항목 이름은 30자 이하로 입력해주세요';
    }
    return null;
  }
}
