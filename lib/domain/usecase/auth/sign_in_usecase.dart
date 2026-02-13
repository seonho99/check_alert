import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../../model/user_model.dart';
import '../../repository/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<Result<UserModel>> call({
    required String email,
    required String password,
  }) async {
    // 1. 필수 입력 검증
    if (email.trim().isEmpty) {
      return const Error(ValidationFailure('이메일을 입력해주세요'));
    }
    if (password.trim().isEmpty) {
      return const Error(ValidationFailure('비밀번호를 입력해주세요'));
    }

    // 2. 이메일 형식 검증
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(email.trim())) {
      return const Error(ValidationFailure('유효하지 않은 이메일 형식입니다'));
    }

    // 3. Repository 호출
    return await _repository.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}
