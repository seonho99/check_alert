/// 서버 예외 (Firebase, API 등)
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

/// 네트워크 예외
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// 인증 예외
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// 데이터 없음 예외
class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}
