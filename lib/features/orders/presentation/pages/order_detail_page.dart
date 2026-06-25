import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/features/orders/presentation/controllers/orders_controller.dart';
import 'package:veggie_mart/features/orders/domain/entities/order_entity.dart';
import 'package:veggie_mart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class OrderDetailPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => orders.first,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: CustomText(
          order.id,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppTheme.textDark),
          onPressed: () => context.go('/orders'),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tracker Section ──────────────────────────────────
            _OrderTracker(status: order.status),

            // ── Delivery Information ─────────────────────────────
            _InfoSection(
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              iconColor: AppTheme.primaryGreen,
              bgColor: AppTheme.cardMint,
              child: CustomText(
                order.deliveryAddress,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, height: 1.5),
              ),
            ),

            _InfoSection(
              title: 'Payment Details',
              icon: Icons.payment_outlined,
              iconColor: AppTheme.emeraldGreen,
              bgColor: AppTheme.cardLavender,
              child: CustomText(
                order.paymentMethod,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMedium),
              ),
            ),

            // ── Items List ───────────────────────────────────────
            _ItemsListSection(items: order.items),

            // ── Payment Summary ──────────────────────────────────
            _BillSummarySection(order: order),

            const SizedBox(height: 24),

            // ── Actions ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleReorder(context, ref, order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      SizedBox(width: 8),
                      CustomText(
                        'Reorder All Items',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _handleReorder(BuildContext context, WidgetRef ref, OrderEntity order) async {
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Add all products to cart
    for (final item in order.items) {
      // Repeat addToCart calls or run them in parallel
      await cartNotifier.addToCart(item.product);
      
      // If quantity is > 1, increment remaining times
      for (int i = 1; i < item.quantity; i++) {
        await cartNotifier.incrementQuantity(item.product.id);
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText('Added ${order.items.length} items to your cart!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Redirect to cart page
    context.go('/cart');
  }
}

class _OrderTracker extends StatelessWidget {
  final String status;

  const _OrderTracker({required this.status});

  @override
  Widget build(BuildContext context) {
    int currentStep = 0;
    if (status == 'Processing') currentStep = 1;
    if (status == 'On the way') currentStep = 2;
    if (status == 'Delivered') currentStep = 3;

    final steps = ['Placed', 'Processing', 'On the way', 'Delivered'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Order Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              final stepName = steps[index];
              final isActive = index <= currentStep;
              final isLast = index == 3;

              return Expanded(
                child: Row(
                  children: [
                    // Circle indicator
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isActive ? AppTheme.primaryGreen : const Color(0xFFE5E7EB),
                          ),
                          child: Center(
                            child: Icon(
                              index < currentStep ? Icons.check_rounded : Icons.circle_rounded,
                              size: index < currentStep ? 14 : 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomText(
                          stepName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AppTheme.textDark : AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                    // Line connector
                    if (!isLast)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Container(
                            height: 3,
                            color: index < currentStep ? AppTheme.primaryGreen : const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsListSection extends StatelessWidget {
  final List<OrderItemEntity> items;

  const _ItemsListSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            'Order Items (${items.length})',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(color: AppTheme.borderColor),
            itemBuilder: (ctx, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor, width: 0.8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: CustomNetworkImage(
                        imageUrl: item.product.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          CustomText(
                            '${item.product.unit}  •  Qty: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomText(
                      '₹ ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BillSummarySection extends StatelessWidget {
  final OrderEntity order;

  const _BillSummarySection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Bill Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Item Subtotal', value: '₹ ${order.subtotal.toStringAsFixed(0)}'),
          if (order.discount > 0)
            _SummaryRow(
              label: 'Promo Discount',
              value: '-₹ ${order.discount.toStringAsFixed(0)}',
              valueColor: AppTheme.primaryGreen,
            ),
          _SummaryRow(label: 'GST (5%)', value: '₹ ${order.tax.toStringAsFixed(0)}'),
          const _SummaryRow(
            label: 'Delivery Fee',
            value: 'FREE',
            valueColor: AppTheme.primaryGreen,
          ),
          const Divider(color: AppTheme.borderColor),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Grand Total',
            value: '₹ ${order.totalAmount.toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? AppTheme.textDark : AppTheme.textGrey,
            ),
          ),
          CustomText(
            value,
            style: TextStyle(
              fontSize: isBold ? 15 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: valueColor ?? (isBold ? AppTheme.textDark : AppTheme.textMedium),
            ),
          ),
        ],
      ),
    );
  }
}

