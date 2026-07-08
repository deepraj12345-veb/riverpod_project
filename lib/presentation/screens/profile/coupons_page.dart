import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/domain/entities/coupon_entity.dart';
import 'package:veggie_mart/presentation/providers/coupon_provider.dart';
import 'package:veggie_mart/presentation/providers/cart_controller.dart'
    show cartTotalProvider;

class CouponsPage extends ConsumerWidget {
  const CouponsPage({super.key});

  void _applyCoupon(
    BuildContext context,
    WidgetRef ref,
    CouponEntity coupon,
    double currentSubtotal,
  ) {
    if (!coupon.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This coupon is no longer active or expired.'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final deficit = coupon.minOrder - currentSubtotal;
    if (deficit > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add items worth ₹${deficit.toStringAsFixed(0)} more to avail this offer.',
          ),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    ref.read(appliedCouponProvider.notifier).state = coupon;
    Clipboard.setData(ClipboardData(text: coupon.code));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 "${coupon.code}" applied! (${coupon.discountLabel})'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    context.go('/cart');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsProvider);
    final appliedCoupon = ref.watch(appliedCouponProvider);
    final currentSubtotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppTheme.textDark,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Coupons & Offers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: couponsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load coupons\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(couponsProvider.notifier).fetchCoupons(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (coupons) {
          if (coupons.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: AppTheme.textGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Coupons Available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Check back later for exciting offers and discounts!',
                    style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () => ref.read(couponsProvider.notifier).fetchCoupons(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              itemCount: coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final coupon = coupons[i];
                final isApplied = appliedCoupon?.id == coupon.id;
                final isValid = coupon.isValid;
                final deficit = coupon.minOrder - currentSubtotal;
                final isEligible = isValid && deficit <= 0;

                return _CouponCard(
                  coupon: coupon,
                  isApplied: isApplied,
                  isValid: isValid,
                  isEligible: isEligible,
                  deficit: deficit > 0 ? deficit : 0.0,
                  onApply: () =>
                      _applyCoupon(context, ref, coupon, currentSubtotal),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final CouponEntity coupon;
  final bool isApplied;
  final bool isValid;
  final bool isEligible;
  final double deficit;
  final VoidCallback onApply;

  const _CouponCard({
    required this.coupon,
    required this.isApplied,
    required this.isValid,
    required this.isEligible,
    required this.deficit,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (isValid && isEligible) ? 1.0 : 0.65,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isApplied ? AppTheme.primaryGreen : const Color(0xFFE2E8F0),
            width: isApplied ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Green Banner
                Container(
                  width: 50,
                  color: isApplied
                      ? AppTheme.primaryGreen
                      : ((isValid && isEligible)
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF94A3B8)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        coupon.discountType == 'percent'
                            ? Icons.percent_rounded
                            : Icons.currency_rupee_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isValid ? (isEligible ? 'OFFER' : 'LOCK') : 'EXPIRED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: const Color(0xFF86EFAC),
                                ),
                              ),
                              child: Text(
                                coupon.code,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isApplied)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'APPLIED',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (!isEligible && deficit > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Add items worth ₹${deficit.toStringAsFixed(0)} more to avail this offer.',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          coupon.discountLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Min. order ₹${coupon.minOrder.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right Action Button
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied
                            ? const Color(0xFFDCFCE7)
                            : (isEligible
                                ? AppTheme.primaryGreen
                                : const Color(0xFFF1F5F9)),
                        foregroundColor: isApplied
                            ? const Color(0xFF15803D)
                            : (isEligible
                                ? Colors.white
                                : const Color(0xFF94A3B8)),
                        elevation: 0,
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isApplied ? 'APPLIED ✓' : 'APPLY',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
