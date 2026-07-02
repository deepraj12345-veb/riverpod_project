import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/data/datasources/profile_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/user_entity.dart';

// ── DataSource provider ─────────────────────────────────────────────────────
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProfileRemoteDataSourceImpl(dio: dio);
});

// ── Profile state ────────────────────────────────────────────────────────────
class ProfileState {
  final AsyncValue<UserEntity> userAsync;
  final bool isUpdating;
  final String? updateError;
  final bool updateSuccess;

  const ProfileState({
    this.userAsync = const AsyncValue.loading(),
    this.isUpdating = false,
    this.updateError,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    AsyncValue<UserEntity>? userAsync,
    bool? isUpdating,
    String? updateError,
    bool? updateSuccess,
    bool clearError = false,
  }) {
    return ProfileState(
      userAsync: userAsync ?? this.userAsync,
      isUpdating: isUpdating ?? this.isUpdating,
      updateError: clearError ? null : (updateError ?? this.updateError),
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRemoteDataSource _dataSource;

  ProfileNotifier(this._dataSource) : super(const ProfileState()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = state.copyWith(userAsync: const AsyncValue.loading());
    try {
      final user = await _dataSource.getProfile();
      
      // Fetch wallet balance separately to ensure it is up-to-date
      try {
        final walletBalance = await _dataSource.getWalletBalance();
        final updatedUser = UserEntity(
          id: user.id,
          name: user.name,
          email: user.email,
          mobileNo: user.mobileNo,
          avatarUrl: user.avatarUrl,
          address: user.address,
          walletBalance: walletBalance,
        );
        state = state.copyWith(userAsync: AsyncValue.data(updatedUser));
      } catch (e) {
        // Fallback to the balance provided by profile API if wallet API fails
        state = state.copyWith(userAsync: AsyncValue.data(user));
      }
    } catch (e, st) {
      state = state.copyWith(userAsync: AsyncValue.error(e, st));
    }
  }

  Future<void> fetchWalletBalance() async {
    try {
      final balance = await _dataSource.getWalletBalance();
      state.userAsync.whenData((user) {
        final updatedUser = UserEntity(
          id: user.id,
          name: user.name,
          email: user.email,
          mobileNo: user.mobileNo,
          avatarUrl: user.avatarUrl,
          address: user.address,
          walletBalance: balance,
        );
        state = state.copyWith(userAsync: AsyncValue.data(updatedUser));
      });
    } catch (e) {
      // Silently ignore or handle wallet specific errors
    }
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    state = state.copyWith(
      isUpdating: true,
      clearError: true,
      updateSuccess: false,
    );
    try {
      final updated = await _dataSource.updateProfile(name: name, email: email);
      state = state.copyWith(
        userAsync: AsyncValue.data(updated),
        isUpdating: false,
        updateSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        updateError: e.toString(),
        updateSuccess: false,
      );
      return false;
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────
final profileControllerProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final dataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileNotifier(dataSource);
});

// ── Convenience provider: current user (non-null) ────────────────────────────
final userProvider = Provider<UserEntity>((ref) {
  return ref.watch(profileControllerProvider).userAsync.maybeWhen(
        data: (u) => u,
        orElse: () => const UserEntity(
          id: '',
          name: 'Loading...',
          email: '',
          mobileNo: '',
        ),
      );
});
