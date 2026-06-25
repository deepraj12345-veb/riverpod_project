import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/features/auth/domain/usecases/login_usecase.dart';
import 'package:veggie_mart/features/auth/domain/usecases/logout_usecase.dart';
import 'package:veggie_mart/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:veggie_mart/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:veggie_mart/features/auth/data/repository/auth_repository_impl.dart';
import 'package:veggie_mart/features/auth/domain/repository/auth_repository.dart';

enum AuthState { unauthenticated, authenticated }

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       super(AuthState.unauthenticated);

  Future<void> login() async {
    final success = await _loginUseCase.execute();
    if (success) {
      state = AuthState.authenticated;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase.execute();
    state = AuthState.unauthenticated;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(),
    localDataSource: AuthLocalDataSourceImpl(),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});

