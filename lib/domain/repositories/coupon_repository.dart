import 'package:veggie_mart/domain/entities/coupon_entity.dart';

abstract class CouponRepository {
  Future<List<CouponEntity>> getCoupons();
}
