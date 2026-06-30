import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/suggestion_field.dart';
import 'package:veggie_mart/presentation/providers/cart_controller.dart';
import 'package:veggie_mart/presentation/providers/orders_controller.dart';
import 'package:veggie_mart/core/constants/fake_data.dart';
import 'package:veggie_mart/core/constants/data/models/models.dart';
import 'package:veggie_mart/core/providers/app_providers.dart'
    hide cartProvider, cartTotalProvider;

import 'package:veggie_mart/domain/entities/cart_item_entity.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _promoCtrl = TextEditingController();
  bool _promoApplied = false;
  double _appliedDiscount = 0.0;

  AddressModel? _selectedAddress;
  String? _selectedPayment;

  String _selectedDuration = 'One Time';
  DateTimeRange? _customDateRange;

  Map<String, double> get _currentPromoDiscounts {
    final isPremium = ref.read(isPremiumUserProvider);
    if (isPremium) {
      return {
        'PREMIUM20': 0.20,
        'PREMIUM50': 0.50,
        'FRESH30': 0.30,
        'VEGGIE15': 0.15,
        'GREEN50': 0.50,
        'VIPDELIGHT': 0.40,
        'CASHBACK10': 0.10,
      };
    }
    return {'SAVE10': 0.10, 'WELCOME': 0.10, 'NEWUSER': 0.20, 'LOYALTY5': 0.05};
  }

  @override
  void initState() {
    super.initState();
    if (FakeData.addresses.isNotEmpty) {
      _selectedAddress = FakeData.addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => FakeData.addresses.first,
      );
    }
    if (FakeData.paymentMethods.isNotEmpty) {
      _selectedPayment = FakeData.paymentMethods.first;
    }
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoCtrl.text.trim().toUpperCase();
    final promos = _currentPromoDiscounts;
    if (promos.containsKey(code)) {
      final disc = promos[code] ?? 0.0;
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
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid promo code'),
          backgroundColor: AppTheme.accentRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showAddressSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...FakeData.addresses.map((address) {
                  final isSelected = _selectedAddress?.id == address.id;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedAddress = address);
                      Navigator.pop(ctx);
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.fullAddress,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...FakeData.paymentMethods.map((pm) {
                  final isSelected = _selectedPayment == pm;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedPayment = pm);
                      Navigator.pop(ctx);
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
                            child: Text(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
            datePickerTheme: const DatePickerThemeData(
              headerHeadlineStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: TextStyle(fontSize: 12),
              dayStyle: TextStyle(fontSize: 12),
              weekdayStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              yearStyle: TextStyle(fontSize: 12),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDuration = 'Custom Dates';
        _customDateRange = picked;
      });
    } else {
      if (_customDateRange == null) {
        setState(() => _selectedDuration = 'One Time');
      }
    }
  }

  void _placeOrder(
    double total,
    double tax,
    double discount,
    double subtotal,
    List<CartItemEntity> cartItems,
  ) {
    if (cartItems.isEmpty) return;

    ref
        .read(ordersProvider.notifier)
        .addOrder(
          cartItems,
          subtotal,
          tax,
          discount,
          total,
          _selectedPayment ?? 'Unknown',
          _selectedAddress?.id ?? '',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.primaryGreen,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully.\nExpected delivery in 30 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final discount = subtotal * _appliedDiscount;
    final tax = subtotal * 0.05;

    final handlingFee = isPremium ? 0.0 : 10.0;
    final freeDeliveryThreshold = isPremium ? 100.0 : 200.0;
    final deliveryFee = subtotal >= freeDeliveryThreshold ? 0.0 : 40.0;

    final total = subtotal + tax - discount + handlingFee + deliveryFee;

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const CustomText(
            'My Cart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        body: const _EmptyCartView(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              'My Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            CustomText(
              '${cartItems.length} ${cartItems.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => ref.read(cartProvider.notifier).clearCart(),
            child: const CustomText(
              'Clear all',
              style: TextStyle(
                color: AppTheme.accentRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final item = cartItems[i];
                final cardColor =
                    AppTheme.cardColors[item.product.id.hashCode.abs() %
                        AppTheme.cardColors.length];
                return Dismissible(
                  key: Key(item.product.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppTheme.accentRed,
                    child: const Icon(
                      Icons.delete_sweep_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  onDismissed: (_) => ref
                      .read(cartProvider.notifier)
                      .removeFromCart(item.product.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: cardColor,
                            child: CachedNetworkImage(
                              imageUrl: item.product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => const SizedBox(),
                            ),
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              CustomText(
                                item.product.unit,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CustomText(
                                '₹ ${item.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _QtyControl(
                          quantity: item.quantity,
                          onDecrement: () => ref
                              .read(cartProvider.notifier)
                              .decrementQuantity(item.product.id),
                          onIncrement: () => ref
                              .read(cartProvider.notifier)
                              .incrementQuantity(item.product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Delivery Address Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          'Deliver to',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        InkWell(
                          onTap: _showAddressSheet,
                          child: const CustomText(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedAddress != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppTheme.primaryGreen,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  _selectedAddress!.title,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  _selectedAddress!.fullAddress,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textGrey,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Subscription Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Order Type & Delivery Schedule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            'One Time',
                            '1 Week',
                            '15 Days',
                            '1 Month',
                            'Custom Dates',
                          ].map((duration) {
                            final isSelected = _selectedDuration == duration;
                            return InkWell(
                              onTap: () {
                                if (duration == 'Custom Dates') {
                                  _selectCustomDateRange();
                                } else {
                                  setState(() {
                                    _selectedDuration = duration;
                                    _customDateRange = null;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : AppTheme.bgLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CustomText(
                                  duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    if (_selectedDuration == 'Custom Dates' &&
                        _customDateRange != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.date_range_rounded,
                              color: AppTheme.primaryGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            CustomText(
                              '${_customDateRange!.start.day}/${_customDateRange!.start.month}/${_customDateRange!.start.year} - ${_customDateRange!.end.day}/${_customDateRange!.end.month}/${_customDateRange!.end.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bill Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Bill Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SuggestionField(
                            controller: _promoCtrl,
                            label: 'Promo Code',
                            hint: 'Try FRESH30...',
                            icon: Icons.local_offer_outlined,
                            suggestions: _currentPromoDiscounts.keys.toList(),
                            onSelected: (code) => _promoCtrl.text = code,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _applyPromo,
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CustomText(
                                _promoApplied ? 'Applied ✓' : 'Apply',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Item Total',
                      value: '₹ ${subtotal.toStringAsFixed(0)}',
                    ),
                    if (_promoApplied)
                      _SummaryRow(
                        label: 'Discount',
                        value: '-₹ ${discount.toStringAsFixed(0)}',
                        valueColor: AppTheme.primaryGreen,
                      ),
                    _SummaryRow(
                      label: 'GST (5%)',
                      value: '₹ ${tax.toStringAsFixed(0)}',
                    ),
                    _SummaryRow(
                      label: 'Handling Fee',
                      value: handlingFee == 0
                          ? 'FREE'
                          : '₹ ${handlingFee.toStringAsFixed(0)}',
                      valueColor: handlingFee == 0
                          ? AppTheme.primaryGreen
                          : AppTheme.textDark,
                    ),
                    _SummaryRow(
                      label: 'Delivery Fee',
                      value: deliveryFee == 0
                          ? 'FREE'
                          : '₹ ${deliveryFee.toStringAsFixed(0)}',
                      valueColor: deliveryFee == 0
                          ? AppTheme.primaryGreen
                          : AppTheme.textDark,
                    ),
                    const SizedBox(height: 5),
                    const Divider(color: AppTheme.borderColor),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                          'To Pay',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        CustomText(
                          '₹ ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Payment Method Selector
              InkWell(
                onTap: _showPaymentSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 20,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      const CustomText(
                        'Pay using',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const Spacer(),
                      CustomText(
                        _selectedPayment ?? 'Select Payment',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 20,
                        color: AppTheme.textDark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Place Order Button
              InkWell(
                onTap: () =>
                    _placeOrder(total, tax, discount, subtotal, cartItems),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              '₹ ${total.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const CustomText(
                              'TOTAL',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            CustomText(
                              'Place Order',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Looks like you haven\'t added\nanything to your cart yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 54,
            child: TextButton(
              onPressed: () => context.go('/home'),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove,
            onTap: onDecrement,
            color: quantity > 1 ? AppTheme.textDark : AppTheme.accentRed,
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ),
          _Btn(
            icon: Icons.add,
            onTap: onIncrement,
            color: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _Btn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        color: Colors.transparent,
        child: Center(child: Icon(icon, size: 16, color: color)),
      ),
    );
  }
}

// ── Summary row ────────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGrey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
