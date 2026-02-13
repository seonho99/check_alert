import '../dto/user_model_dto.dart';

/// Auth DataSource 인터페이스 - Firebase 의존성 제거
abstract class AuthDataSource {
  /// 이메일/비밀번호 회원가입 → UID 반환
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// 이메일/비밀번호 로그인 → UID 반환
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email);

  /// 사용자 정보 Firestore에 저장
  Future<void> saveUser(UserModelDto user);

  /// 사용자 정보 Firestore에서 조회
  Future<UserModelDto?> getUser(String uid);

  /// Google 로그인 → UID 반환
  Future<String> signInWithGoogle();

  /// Apple 로그인 → UID 반환
  Future<String> signInWithApple();

  /// 현재 로그인된 사용자 UID (null이면 미로그인)
  String? get currentUserId;

  /// 로그인 여부
  bool get isSignedIn;

  /// 인증 상태 변화 스트림 (UID or null)
  Stream<String?> get authStateChanges;
}
