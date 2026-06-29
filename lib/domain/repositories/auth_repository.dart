import 'package:veggie_mart/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> sendOtp(String mobileNo);
  Future<UserModel> verifyOtp(String mobileNo, String otp, String name);
  Future<UserModel?> checkAuthStatus();
  Future<void> logout();
}
