class CouponEntity {
  final String id;
  final String code;
  final String discountType; // 'percent' or 'flat'
  final double discountValue;
  final double minOrder;
  final int maxUses;
  final int usedCount;
  final String isActive;
  final String expiresAt;

  const CouponEntity({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrder,
    required this.maxUses,
    required this.usedCount,
    required this.isActive,
    required this.expiresAt,
  });

  bool get isValid {
    if (isActive != '1' && isActive.toLowerCase() != 'true') return false;
    if (maxUses > 0 && usedCount >= maxUses) return false;
    try {
      if (expiresAt.isNotEmpty) {
        final expiry = DateTime.parse(expiresAt);
        if (DateTime.now().isAfter(expiry)) return false;
      }
    } catch (_) {}
    return true;
  }

  String get discountLabel {
    if (discountType.toLowerCase() == 'percent') {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return '₹${discountValue.toStringAsFixed(0)} FLAT OFF';
    }
  }

  double calculateDiscount(double subtotal) {
    if (!isValid || subtotal < minOrder) return 0.0;
    if (discountType.toLowerCase() == 'percent') {
      final disc = subtotal * (discountValue / 100.0);
      return disc > subtotal ? subtotal : disc;
    } else {
      return discountValue > subtotal ? subtotal : discountValue;
    }
  }
}
