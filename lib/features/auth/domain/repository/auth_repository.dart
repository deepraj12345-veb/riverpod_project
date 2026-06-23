abstract class AuthRepository {
  Future<bool> login();
  Future<void> logout();
  Future<void> sendOtp();
  Future<bool> verifyOtp(String enteredOtp);
}
