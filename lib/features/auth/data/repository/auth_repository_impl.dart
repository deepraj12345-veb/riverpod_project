import 'package:riverpod_project/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:riverpod_project/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:riverpod_project/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<bool> login() async {
    final success = await remoteDataSource.login();
    if (success) {
      await localDataSource.saveToken('mock_session_token');
    }
    return success;
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteToken();
  }

  @override
  Future<void> sendOtp() async {
    await remoteDataSource.sendOtp();
  }

  @override
  Future<bool> verifyOtp(String enteredOtp) async {
    final success = await remoteDataSource.verifyOtp(enteredOtp);
    if (success) {
      await localDataSource.saveToken('mock_session_token');
    }
    return success;
  }
}
