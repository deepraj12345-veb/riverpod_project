import 'package:veg_king/domain/entities/coupon_entity.dart';

abstract class CouponRepository {
  Future<List<CouponEntity>> getCoupons();
}
