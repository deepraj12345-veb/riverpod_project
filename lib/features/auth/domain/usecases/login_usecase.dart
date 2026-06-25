import 'package:veggie_mart/features/auth/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<bool> execute() {
    return repository.login();
  }
}

