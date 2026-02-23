import '../../../core/result/result.dart';
import '../../repository/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  DeleteAccountUseCase({required AuthRepository repository})
      : _repository = repository;

  Future<Result<void>> call() async {
    return await _repository.deleteAccount();
  }
}
