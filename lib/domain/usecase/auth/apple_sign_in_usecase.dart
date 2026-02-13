import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../../model/user_model.dart';
import '../../repository/auth_repository.dart';

class AppleSignInUseCase {
  final AuthRepository _repository;

  AppleSignInUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<Result<UserModel>> call() async {
    try {
      return await _repository.signInWithApple();
    } catch (e) {
      return const Error(ServerFailure('Apple 로그인 중 오류가 발생했습니다'));
    }
  }
}
