abstract class AuthRemoteDataSource {
  Future<bool> login();
  Future<void> sendOtp();
  Future<bool> verifyOtp(String enteredOtp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String _mockOtp = '123456';

  @override
  Future<bool> login() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<void> sendOtp() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> verifyOtp(String enteredOtp) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return enteredOtp == _mockOtp;
  }
}

