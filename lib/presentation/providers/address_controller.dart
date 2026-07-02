import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/data/datasources/address_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/address_entity.dart';

// ── DataSource provider ──────────────────────────────────────────────────────
final addressRemoteDataSourceProvider =
    Provider<AddressRemoteDataSource>((ref) {
  return AddressRemoteDataSourceImpl(dio: ref.watch(dioClientProvider));
});

// ── Address state ────────────────────────────────────────────────────────────
class AddressState {
  final AsyncValue<List<AddressEntity>> addressesAsync;
  final bool isMutating; // true when add/update/delete/setDefault in progress
  final String? mutationError;
  final bool mutationSuccess;

  const AddressState({
    this.addressesAsync = const AsyncValue.loading(),
    this.isMutating = false,
    this.mutationError,
    this.mutationSuccess = false,
  });

  AddressState copyWith({
    AsyncValue<List<AddressEntity>>? addressesAsync,
    bool? isMutating,
    String? mutationError,
    bool? mutationSuccess,
    bool clearError = false,
  }) {
    return AddressState(
      addressesAsync: addressesAsync ?? this.addressesAsync,
      isMutating: isMutating ?? this.isMutating,
      mutationError: clearError ? null : (mutationError ?? this.mutationError),
      mutationSuccess: mutationSuccess ?? this.mutationSuccess,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────
class AddressNotifier extends StateNotifier<AddressState> {
  final AddressRemoteDataSource _dataSource;

  AddressNotifier(this._dataSource) : super(const AddressState()) {
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    state = state.copyWith(addressesAsync: const AsyncValue.loading());
    try {
      final list = await _dataSource.getAddresses();
      state = state.copyWith(addressesAsync: AsyncValue.data(list));
    } catch (e, st) {
      state = state.copyWith(addressesAsync: AsyncValue.error(e, st));
    }
  }

  Future<bool> addAddress(AddressEntity address) async {
    state = state.copyWith(
        isMutating: true, clearError: true, mutationSuccess: false);
    try {
      final newAddr = await _dataSource.addAddress(address);
      final current = state.addressesAsync.valueOrNull ?? [];
      state = state.copyWith(
        addressesAsync: AsyncValue.data([...current, newAddr]),
        isMutating: false,
        mutationSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          isMutating: false, mutationError: e.toString(), mutationSuccess: false);
      return false;
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    state = state.copyWith(
        isMutating: true, clearError: true, mutationSuccess: false);
    try {
      final updated = await _dataSource.updateAddress(id, data);
      final current = state.addressesAsync.valueOrNull ?? [];
      final newList = current.map((a) => a.id == id ? updated : a).toList();
      state = state.copyWith(
        addressesAsync: AsyncValue.data(newList),
        isMutating: false,
        mutationSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          isMutating: false, mutationError: e.toString(), mutationSuccess: false);
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    state = state.copyWith(
        isMutating: true, clearError: true, mutationSuccess: false);
    try {
      await _dataSource.deleteAddress(id);
      final current = state.addressesAsync.valueOrNull ?? [];
      final newList = current.where((a) => a.id != id).toList();
      state = state.copyWith(
        addressesAsync: AsyncValue.data(newList),
        isMutating: false,
        mutationSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          isMutating: false, mutationError: e.toString(), mutationSuccess: false);
      return false;
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _dataSource.setDefaultAddress(id);
      final current = state.addressesAsync.valueOrNull ?? [];
      final newList = current
          .map((a) => AddressEntity(
                id: a.id,
                label: a.label,
                name: a.name,
                mobile: a.mobile,
                addressLine: a.addressLine,
                city: a.city,
                state: a.state,
                pincode: a.pincode,
                isDefault: a.id == id,
              ))
          .toList();
      state = state.copyWith(
        addressesAsync: AsyncValue.data(newList),
        isMutating: false,
        mutationSuccess: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
          isMutating: false, mutationError: e.toString());
      return false;
    }
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────
final addressControllerProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(ref.watch(addressRemoteDataSourceProvider));
});

// ── Convenience count provider ─────────────────────────────────────────────
final addressCountProvider = Provider<int>((ref) {
  return ref
          .watch(addressControllerProvider)
          .addressesAsync
          .valueOrNull
          ?.length ??
      0;
});
