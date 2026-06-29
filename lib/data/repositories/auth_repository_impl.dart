import 'package:veggie_mart/data/datasources/auth_remote_data_source.dart';
import 'package:veggie_mart/data/datasources/auth_local_data_source.dart';
import 'package:veggie_mart/domain/repositories/auth_repository.dart';
import 'package:veggie_mart/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  @override
  Future<void> sendOtp(String mobileNo) async {
    await remoteDataSource.sendOtp(mobileNo);
  }

  @override
  Future<UserModel> verifyOtp(String mobileNo, String otp, String name) async {
    final response = await remoteDataSource.verifyOtp(mobileNo, otp, name);

    final token = response['token'] as String?;
    
    // The user data is inside the 'user' key
    final userData = response['user'] as Map<String, dynamic>;
    
    // We need to map the backend keys to our UserModel keys if they don't match,
    // or ideally update the UserModel. For now, let's map them manually before fromJson
    // to avoid breaking the existing Freezed model if it hasn't been re-generated.
    final mappedUserData = <String, dynamic>{
      'id': userData['id'] ?? '',
      'name': userData['name'] ?? '',
      'email': userData['email'] ?? '',
      'phone': userData['mobile_no'] ?? '',
      'avatarUrl': userData['profile_image'] ?? '',
      'address': '', // Backend doesn't send this
      'token': token,
    };
    
    final user = UserModel.fromJson(mappedUserData);

    if (token != null) {
      await localDataSource.saveToken(token);
      await localDataSource.saveUser(user);
    }

    return user;
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    final token = await localDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      final user = await localDataSource.getUser();
      return user;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
  }
}
