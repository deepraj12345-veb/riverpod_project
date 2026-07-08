import 'package:veggie_mart/data/datasources/coupon_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/coupon_entity.dart';
import 'package:veggie_mart/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CouponEntity>> getCoupons() async {
    return await remoteDataSource.getCoupons();
  }
}
