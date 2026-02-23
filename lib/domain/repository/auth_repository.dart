import '../../core/result/result.dart';
import '../model/user_model.dart';

/// Auth Repository 인터페이스
abstract class AuthRepository {
  /// 이메일/비밀번호 회원가입
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// 이메일/비밀번호 로그인
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Google 로그인
  Future<Result<UserModel>> signInWithGoogle();

  /// Apple 로그인
  Future<Result<UserModel>> signInWithApple();

  /// 로그아웃
  Future<Result<void>> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// 현재 로그인된 사용자 정보 조회
  Future<Result<UserModel>> getCurrentUser();

  /// 인증 상태 변화 스트림
  Stream<UserModel?> get authStateChanges;

  /// 로그인 여부
  bool get isSignedIn;

  /// 현재 사용자 UID
  String? get currentUserId;

  /// 회원 탈퇴
  Future<Result<void>> deleteAccount();
}
