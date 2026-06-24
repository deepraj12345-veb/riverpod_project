import 'package:riverpod_project/features/auth/domain/repository/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<void> execute() {
    return repository.sendOtp();
  }
}
