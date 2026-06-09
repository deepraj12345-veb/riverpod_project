import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_project/core/providers/app_providers.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/suggestion_field.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _promoCtrl = TextEditingController();
  bool _promoApplied = false;
  double _appliedDiscount = 0.0;

  static const _promoDiscounts = {
    'SAVE10': 0.10,
    'SAVE20': 0.20,
    'FREESHIP': 0.0,
    'VEGGIE15': 0.15,
    'WELCOME': 0.10,
    'SUMMER25': 0.25,
    'FRESH30': 0.30,
    'GREEN50': 0.50,
    'NEWUSER': 0.20,
    'LOYALTY5': 0.05,
  };

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartTotalProvider);
    final discount = totalAmount * _appliedDiscount;

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      appBar: AppBar(
        backgroundColor:  AppTheme.bgWhite,
        title: Column(
          children: [
            const Text(
              'Cart List 🛒',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              '${cartItems.length} ${cartItems.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: const Text(
                'Clear',
                style: TextStyle(color: AppTheme.accentRed, fontSize: 13),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _EmptyCart()
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) {
                      final item = cartItems[i];
                      final cardColor = AppTheme.cardColors[
                          item.product.id.hashCode.abs() %
                              AppTheme.cardColors.length];
                      return Dismissible(
                        key: Key(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            color: AppTheme.accentRed,
                            size: 28,
                          ),
                        ),
                        onDismissed: (_) => ref
                            .read(cartProvider.notifier)
                            .removeFromCart(item.product.id),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Product image with pastel bg
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: cardColor,
                                  padding: const EdgeInsets.all(6),
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.imageUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (ctx, url) => const SizedBox(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.product.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${item.totalPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.priceOrange,
                                          ),
                                        ),
                                        // Quantity controls
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () => ref
                                                    .read(cartProvider.notifier)
                                                    .decrementQuantity(
                                                        item.product.id),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.remove_rounded,
                                                    color: AppTheme.textGrey,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.textDark,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => ref
                                                    .read(cartProvider.notifier)
                                                    .incrementQuantity(
                                                        item.product.id),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    Icons.add_rounded,
                                                    color: AppTheme.textDark,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                // ─── Order Summary + Checkout ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Promo Code Field
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SuggestionField(
                              controller: _promoCtrl,
                              label: 'Promo Code',
                              hint: 'Try SAVE10, FRESH30...',
                              icon: Icons.local_offer_outlined,
                              suggestions: _promoDiscounts.keys.toList(),
                              onSelected: (code) {
                                _promoCtrl.text = code;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: GestureDetector(
                              onTap: () {
                                final code =
                                    _promoCtrl.text.trim().toUpperCase();
                                if (_promoDiscounts.containsKey(code)) {
                                  final disc = _promoDiscounts[code] ?? 0.0;
                                  setState(() {
                                    _promoApplied = true;
                                    _appliedDiscount = disc;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Code applied! ${(disc * 100).toInt()}% OFF'),
                                      backgroundColor: AppTheme.primaryGreen,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invalid promo code'),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _promoApplied ? 'Applied' : 'Apply',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_promoApplied) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount (${(_appliedDiscount * 100).toInt()}%)',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '-\$${discount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),
                      _SummaryRow(
                        label: 'Subtotal',
                        value: totalAmount,
                      ),
                      const SizedBox(height: 8),
                      const _SummaryRow(
                        label: 'Shipping',
                        value: 0,
                        valueText: 'FREE',
                        valueColor: AppTheme.accentGreen,
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Tax (8%)',
                        value: totalAmount * 0.08,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Color(0xFFEEEEEE)),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: totalAmount + (totalAmount * 0.08) - discount,
                        isBold: true,
                      ),
                      const SizedBox(height: 20),
                      // Checkout button
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.accentGreen,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Order Placed! 🎉',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Your order has been placed\nsuccessfully!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textGrey,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).clearCart();
                                    Navigator.pop(ctx);
                                    context.go('/home');
                                  },
                                  child: const Text(
                                    'Continue Shopping',
                                    style: TextStyle(color: AppTheme.accentRed),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.accentRed.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Proceed to Checkout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.cardYellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 52,
              color: AppTheme.priceOrange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cart is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Browse products and tap Buy\nto add items here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.accentRed,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentRed.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String? valueText;
  final Color? valueColor;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueText,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppTheme.textDark : AppTheme.textGrey,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          valueText ?? '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: valueColor ??
                (isBold ? AppTheme.priceOrange : AppTheme.textDark),
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
