import 'package:veg_king/data/datasources/coupon_remote_data_source.dart';
import 'package:veg_king/domain/entities/coupon_entity.dart';
import 'package:veg_king/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponRemoteDataSource remoteDataSource;

  CouponRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CouponEntity>> getCoupons() async {
    return await remoteDataSource.getCoupons();
  }
}
