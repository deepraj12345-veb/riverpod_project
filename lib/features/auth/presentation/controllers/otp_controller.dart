import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:riverpod_project/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:riverpod_project/features/auth/presentation/controllers/login_controller.dart';

final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  return SendOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

class OtpNotifier extends StateNotifier<String> {
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final Ref _ref;

  OtpNotifier({
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required Ref ref,
  }) : _sendOtpUseCase = sendOtpUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _ref = ref,
       super('');

  Future<void> sendOtp() async {
    await _sendOtpUseCase.execute();
    state = '123456';
  }

  Future<bool> verifyOtp(String enteredOtp) async {
    final success = await _verifyOtpUseCase.execute(enteredOtp);
    if (success) {
      // Upon successful OTP, mark user as authenticated
      await _ref.read(authProvider.notifier).login();
    }
    return success;
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, String>((ref) {
  return OtpNotifier(
    sendOtpUseCase: ref.watch(sendOtpUseCaseProvider),
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    ref: ref,
  );
});
