import '../result/result.dart';

/// 서버 오류 (Firebase, API 등)
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.stackTrace]);
}

/// 네트워크 오류
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.stackTrace]);
}

/// 입력값 검증 오류
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.stackTrace]);
}

/// 인증 오류 (미로그인, 토큰 만료 등)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, [super.stackTrace]);
}

/// 권한 오류 (접근 거부)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, [super.stackTrace]);
}

/// 데이터 없음
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.stackTrace]);
}

/// 알 수 없는 오류
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.stackTrace]);
}
