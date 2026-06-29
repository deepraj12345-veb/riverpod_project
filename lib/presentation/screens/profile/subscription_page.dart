import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/providers/app_providers.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/data/fake_data.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activeSubscriptionPlanProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const CustomText(
          'Premium Subscription',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomText(
              'Upgrade Your Experience',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const CustomText(
              'Unlock free deliveries, exclusive discounts, and prioritize your orders with Veggie Mart Premium.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textGrey,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _SubscriptionCard(
              title: 'Basic Monthly',
              price: '₹149',
              period: '/month',
              color: AppTheme.primaryGreen,
              features: const [
                'Free delivery on orders over ₹199',
                '5% off on all fresh vegetables',
                'Standard priority support',
              ],
              isActive: activePlan == 'Basic Monthly',
              onTap: () {
                _purchase(context, ref, 'Basic Monthly', '₹149');
              },
            ),
            const SizedBox(height: 16),
            _SubscriptionCard(
              title: 'Plus Quarterly',
              price: '₹399',
              period: '/3 months',
              color: AppTheme.primaryGreen,
              features: const [
                'Free delivery on orders over ₹149',
                '7% off on all fresh vegetables',
                'Priority support',
              ],
              isActive: activePlan == 'Plus Quarterly',
              onTap: () {
                _purchase(context, ref, 'Plus Quarterly', '₹399');
              },
            ),
            const SizedBox(height: 16),
            _SubscriptionCard(
              title: 'Elite Half-Yearly',
              price: '₹699',
              period: '/6 months',
              color: AppTheme.primaryGreen,
              features: const [
                'Free delivery on orders over ₹99',
                '10% off on all fresh vegetables',
                'Priority support',
                'Special festive offers',
              ],
              isActive: activePlan == 'Elite Half-Yearly',
              onTap: () {
                _purchase(context, ref, 'Elite Half-Yearly', '₹699');
              },
            ),
            const SizedBox(height: 16),
            _SubscriptionCard(
              title: 'Pro Yearly',
              price: '₹999',
              period: '/year',
              color: AppTheme.primaryGreen,
              features: const [
                'Free delivery on ALL orders',
                '10% off on all fresh vegetables',
                'High priority support',
                'Early access to seasonal fruits',
              ],
              isActive: activePlan == 'Pro Yearly',
              onTap: () {
                _purchase(context, ref, 'Pro Yearly', '₹999');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _purchase(
    BuildContext context,
    WidgetRef ref,
    String planName,
    String price,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String? selectedPayment = FakeData.paymentMethods.first;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Complete Payment ($price)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...FakeData.paymentMethods.map((pm) {
                      final isSelected = selectedPayment == pm;
                      return InkWell(
                        onTap: () {
                          setState(() => selectedPayment = pm);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryGreen.withValues(alpha: 0.05)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : AppTheme.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textGrey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomText(
                                  pm,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(isPremiumUserProvider.notifier).state = true;
                          ref
                                  .read(activeSubscriptionPlanProvider.notifier)
                                  .state =
                              planName;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Welcome to Premium!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                          context.pop(); // Go back to profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: CustomText(
                          'Pay $price',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final Color color;
  final bool isPopular;
  final List<String> features;
  final VoidCallback onTap;
  final bool isActive;

  const _SubscriptionCard({
    required this.title,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    required this.onTap,
    required this.isActive,
  }) : isPopular = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    price,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: CustomText(
                      period,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: color, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CustomText(
                          f,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isActive ? null : onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive ? Colors.grey.shade300 : color,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: CustomText(
                    isActive ? 'Currently Active' : 'Choose Plan',
                    style: TextStyle(
                      color: isActive ? Colors.grey.shade600 : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CustomText(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        if (isActive)
          Positioned(
            top: 16,
            right: 16,
            child: Icon(Icons.check_circle_rounded, color: color, size: 28),
          ),
      ],
    );
  }
}
