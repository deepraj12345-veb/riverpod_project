import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/domain/repositories/auth_repository.dart';
import 'package:veggie_mart/data/repositories/auth_repository_impl.dart';
import 'package:veggie_mart/data/datasources/auth_remote_data_source.dart';
import 'package:veggie_mart/data/datasources/auth_local_data_source.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/presentation/providers/auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(dio: dio),
    localDataSource: AuthLocalDataSourceImpl(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial());

  Future<bool> sendOtp(String mobileNo) async {
    state = const AuthState.loading();
    try {
      await _repository.sendOtp(mobileNo);
      state = const AuthState.otpSent();
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String mobileNo, String otp, String name) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.verifyOtp(mobileNo, otp, name);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.checkAuthStatus();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final notifier = AuthNotifier(repository);
  notifier.checkAuthStatus(); // Check auth status on initialization
  return notifier;
});
