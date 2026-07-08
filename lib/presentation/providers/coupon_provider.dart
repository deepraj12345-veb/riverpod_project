import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/data/datasources/coupon_remote_data_source.dart';
import 'package:veggie_mart/data/repositories/coupon_repository_impl.dart';
import 'package:veggie_mart/domain/entities/coupon_entity.dart';
import 'package:veggie_mart/domain/repositories/coupon_repository.dart';

final couponRemoteDataSourceProvider = Provider<CouponRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CouponRemoteDataSourceImpl(dio: dio);
});

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final remoteDataSource = ref.watch(couponRemoteDataSourceProvider);
  return CouponRepositoryImpl(remoteDataSource: remoteDataSource);
});

class CouponNotifier extends StateNotifier<AsyncValue<List<CouponEntity>>> {
  final CouponRepository repository;

  CouponNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    state = const AsyncValue.loading();
    try {
      final data = await repository.getCoupons();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final couponsProvider =
    StateNotifierProvider<CouponNotifier, AsyncValue<List<CouponEntity>>>((
      ref,
    ) {
      final repository = ref.watch(couponRepositoryProvider);
      return CouponNotifier(repository);
    });

final appliedCouponProvider = StateProvider<CouponEntity?>((ref) => null);
