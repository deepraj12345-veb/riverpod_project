import 'package:veggie_mart/features/auth/domain/repository/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<bool> execute(String code) {
    return repository.verifyOtp(code);
  }
}

