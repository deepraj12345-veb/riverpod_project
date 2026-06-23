import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/suggestion_field.dart';
import 'package:riverpod_project/features/cart/presentation/controllers/cart_controller.dart';

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

  void _applyPromo() {
    final code = _promoCtrl.text.trim().toUpperCase();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid promo code'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final discount = subtotal * _appliedDiscount;
    final tax = subtotal * 0.05;
    final total = subtotal + tax - discount;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              '${cartItems.length} ${cartItems.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ],
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              child: const Text(
                'Clear all',
                style: TextStyle(color: AppTheme.accentRed, fontSize: 13),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? const _EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.delete_sweep_rounded,
                            color: AppTheme.accentRed,
                            size: 26,
                          ),
                        ),
                        onDismissed: (_) => ref
                            .read(cartProvider.notifier)
                            .removeFromCart(item.product.id),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.borderColor,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Product image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  color: cardColor,
                                  padding: const EdgeInsets.all(6),
                                  child: CachedNetworkImage(
                                    imageUrl: item.product.imageUrl,
                                    fit: BoxFit.contain,
                                    placeholder: (ctx, url) =>
                                        const SizedBox(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.product.unit,
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
                                          'Rs ${item.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textDark,
                                          ),
                                        ),
                                        _QtyControl(
                                          quantity: item.quantity,
                                          onDecrement: () => ref
                                              .read(cartProvider.notifier)
                                              .decrementQuantity(
                                                  item.product.id),
                                          onIncrement: () => ref
                                              .read(cartProvider.notifier)
                                              .incrementQuantity(
                                                  item.product.id),
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
                ),

                // ── Order summary panel ──────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Promo code
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SuggestionField(
                              controller: _promoCtrl,
                              label: 'Promo Code',
                              hint: 'Try FRESH30, VEGGIE15…',
                              icon: Icons.local_offer_outlined,
                              suggestions: _promoDiscounts.keys.toList(),
                              onSelected: (code) => _promoCtrl.text = code,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: GestureDetector(
                              onTap: _applyPromo,
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  color: _promoApplied
                                      ? AppTheme.primaryGreen.withValues(
                                          alpha: 0.1)
                                      : AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _promoApplied ? 'Applied ✓' : 'Apply',
                                    style: TextStyle(
                                      color: _promoApplied
                                          ? AppTheme.primaryGreen
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.borderColor),
                      const SizedBox(height: 12),

                      // Bill details
                      _SummaryRow(label: 'Subtotal', value: 'Rs ${subtotal.toStringAsFixed(0)}'),
                      if (_promoApplied)
                        _SummaryRow(
                          label: 'Discount (${(_appliedDiscount * 100).toInt()}%)',
                          value: '-Rs ${discount.toStringAsFixed(0)}',
                          valueColor: AppTheme.primaryGreen,
                        ),
                      _SummaryRow(label: 'GST (5%)', value: 'Rs ${tax.toStringAsFixed(0)}'),
                      const _SummaryRow(
                        label: 'Delivery',
                        value: 'FREE',
                        valueColor: AppTheme.primaryGreen,
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: AppTheme.borderColor),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Total Amount',
                        value: 'Rs ${total.toStringAsFixed(0)}',
                        isBold: true,
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => _showOrderSuccess(context, ref),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Proceed to Checkout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
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
    );
  }

  void _showOrderSuccess(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppTheme.primaryGreen, size: 72),
            SizedBox(height: 16),
            Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your order has been placed successfully.\nExpected delivery in 30 minutes.',
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
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.pop(ctx);
                context.go('/home');
              },
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty cart view ────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add fresh veggies & fruits\nto get started',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Shop Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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

// ── Quantity control ───────────────────────────────────────────────────────────

class _QtyControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyControl({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.remove_rounded,
                  size: 16, color: AppTheme.primaryGreen),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.add_rounded,
                  size: 16, color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary row ────────────────────────────────────────────────────────────────

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
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: isBold ? AppTheme.textDark : AppTheme.textGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: valueColor ?? (isBold ? AppTheme.textDark : AppTheme.textMedium),
            ),
          ),
        ],
      ),
    );
  }
}
