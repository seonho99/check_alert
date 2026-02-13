import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../result/result.dart';
import 'exceptions.dart';
import 'failure.dart';

/// Exception을 Failure로 변환하는 매퍼
class FailureMapper {
  FailureMapper._();

  /// Exception → Failure 변환
  static Failure mapExceptionToFailure(Object e, [StackTrace? stackTrace]) {
    // 커스텀 예외
    if (e is ServerException) {
      return ServerFailure(e.message, stackTrace);
    }
    if (e is NetworkException) {
      return NetworkFailure(e.message, stackTrace);
    }
    if (e is UnauthorizedException) {
      return UnauthorizedFailure(e.message, stackTrace);
    }
    if (e is NotFoundException) {
      return NotFoundFailure(e.message, stackTrace);
    }

    // Firebase Auth 예외
    if (e is FirebaseAuthException) {
      return _mapFirebaseAuthException(e, stackTrace);
    }

    // Firebase Firestore 예외
    if (e is FirebaseException) {
      return ServerFailure('Firebase 오류: ${e.message}', stackTrace);
    }

    // 네트워크 예외
    if (e is SocketException) {
      return const NetworkFailure('네트워크 연결을 확인해주세요');
    }

    // 기타 예외
    return UnknownFailure(e.toString(), stackTrace);
  }

  /// FirebaseAuthException → Failure 변환 (한국어 메시지)
  static Failure _mapFirebaseAuthException(
    FirebaseAuthException e, [
    StackTrace? stackTrace,
  ]) {
    final message = switch (e.code) {
      'user-not-found' => '등록되지 않은 이메일입니다',
      'wrong-password' => '비밀번호가 올바르지 않습니다',
      'email-already-in-use' => '이미 사용 중인 이메일입니다',
      'invalid-email' => '유효하지 않은 이메일 형식입니다',
      'weak-password' => '비밀번호가 너무 약합니다',
      'user-disabled' => '비활성화된 계정입니다',
      'too-many-requests' => '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요',
      'operation-not-allowed' => '허용되지 않은 작업입니다',
      'requires-recent-login' => '보안을 위해 다시 로그인해주세요',
      'invalid-credential' => '이메일 또는 비밀번호가 올바르지 않습니다',
      _ => '인증 오류: ${e.message}',
    };

    return ServerFailure(message, stackTrace);
  }
}
