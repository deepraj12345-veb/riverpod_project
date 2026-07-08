import 'package:veggie_mart/domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    required super.discountType,
    required super.discountValue,
    required super.minOrder,
    required super.maxUses,
    required super.usedCount,
    required super.isActive,
    required super.expiresAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'percent',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minOrder: (json['min_order'] as num?)?.toDouble() ?? 0.0,
      maxUses: (json['max_uses'] as num?)?.toInt() ?? 0,
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active']?.toString() ?? '1',
      expiresAt: json['expires_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order': minOrder,
      'max_uses': maxUses,
      'used_count': usedCount,
      'is_active': isActive,
      'expires_at': expiresAt,
    };
  }
}
