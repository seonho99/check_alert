import '../../../core/errors/failure.dart';
import '../../../core/result/result.dart';
import '../../model/user_model.dart';
import '../../repository/auth_repository.dart';

class GoogleSignInUseCase {
  final AuthRepository _repository;

  GoogleSignInUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<Result<UserModel>> call() async {
    try {
      return await _repository.signInWithGoogle();
    } catch (e) {
      return const Error(ServerFailure('Google 로그인 중 오류가 발생했습니다'));
    }
  }
}
