import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../../model/user_model.dart';
import '../../repository/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<Result<UserModel>> call({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    // 1. 필수 입력 검증
    if (email.trim().isEmpty) {
      return const Error(ValidationFailure('이메일을 입력해주세요'));
    }
    if (password.trim().isEmpty) {
      return const Error(ValidationFailure('비밀번호를 입력해주세요'));
    }
    if (confirmPassword.trim().isEmpty) {
      return const Error(ValidationFailure('비밀번호 확인을 입력해주세요'));
    }

    // 2. 이메일 형식 검증
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email.trim())) {
      return const Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // 3. 비밀번호 강도 검증
    if (password.length < 6) {
      return const Error(ValidationFailure('비밀번호는 6자 이상이어야 합니다'));
    }

    // 4. 비밀번호 확인
    if (password != confirmPassword) {
      return const Error(ValidationFailure('비밀번호가 일치하지 않습니다'));
    }

    // 5. Repository 호출
    return await _repository.signUpWithEmailAndPassword(
      email: email.trim(),
      password: password,
      displayName: displayName?.trim(),
    );
  }
}
