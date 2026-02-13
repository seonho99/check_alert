import '../../../core/result/result.dart';
import '../../repository/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<Result<void>> call() async {
    return await _repository.signOut();
  }
}
