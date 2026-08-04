import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veg_king/core/widgets/custom_network_image.dart';
import 'package:veg_king/core/widgets/address_bottom_sheet.dart';
import 'package:veg_king/core/theme/app_theme.dart';
import 'package:veg_king/core/widgets/custom_text.dart';
import 'package:veg_king/presentation/providers/cart_controller.dart';
import 'package:veg_king/presentation/providers/orders_controller.dart';
import 'package:veg_king/presentation/providers/address_controller.dart';
import 'package:veg_king/domain/entities/address_entity.dart';
import 'package:veg_king/domain/entities/coupon_entity.dart';
import 'package:veg_king/core/constants/app_constants.dart';
import 'package:veg_king/presentation/providers/auth_provider.dart';
import 'package:veg_king/presentation/providers/auth_state.dart';
import 'package:veg_king/core/providers/app_providers.dart'
    hide cartProvider, cartTotalProvider;
import 'package:veg_king/presentation/providers/coupon_provider.dart';
import 'package:veg_king/domain/entities/cart_item_entity.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:veg_king/l10n/app_localizations.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  AddressEntity? _selectedAddress;
  String? _selectedPayment;

  late Razorpay _razorpay;
  double? _currentSubtotal;
  double? _currentTax;
  double? _currentDiscount;
  double? _currentTotal;
  List<CartItemEntity>? _currentCartItems;

  String _selectedDuration = 'One Time';
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Address is now loaded from real API via address_controller
    // We initialize after first frame when provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addresses =
          ref.read(addressControllerProvider).addressesAsync.valueOrNull ?? [];
      if (addresses.isNotEmpty && _selectedAddress == null) {
        setState(() {
          _selectedAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
        });
      }
    });
    if (AppConstants.paymentMethods.isNotEmpty) {
      _selectedPayment = AppConstants.paymentMethods.first;
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_currentCartItems != null) {
      _finalizeOrder(
        _currentTotal ?? 0,
        _currentTax ?? 0,
        _currentDiscount ?? 0,
        _currentSubtotal ?? 0,
        _currentCartItems!,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.paymentFailed(response.message ?? "Unknown error")),
        backgroundColor: AppTheme.accentRed,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.externalWallet(response.walletName ?? "")),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showAddressSheet() {
    showAddressBottomSheet(
      context,
      ref,
      selectedAddress: _selectedAddress,
      onSelect: (address) {
        setState(() => _selectedAddress = address);
      },
    );
  }

  Widget _buildCartSummaryBar(int itemCount) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Item count
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 6),
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          // Right: Clear all button
          InkWell(
            onTap: () => ref.read(cartProvider.notifier).clearCart(),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppTheme.accentRed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.clearAll,
                    style: const TextStyle(
                      color: AppTheme.accentRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                Text(
                  AppLocalizations.of(context)!.selectPaymentMethod,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ...AppConstants.paymentMethods.map((pm) {
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

    if (_selectedPayment == 'ONLINE') {
      _currentTotal = total;
      _currentTax = tax;
      _currentDiscount = discount;
      _currentSubtotal = subtotal;
      _currentCartItems = cartItems;
      

      final options = {
        'key': 'rzp_test_SoxQMJgDxGdtA1',
        'amount': (total * 100).toInt(),
        'name': 'Veg king',
        'description': 'Order Payment',
        'prefill': {
          'contact': ref.read(authProvider).maybeWhen(
                authenticated: (user) => user.mobileNo,
                orElse: () => '',
              ),
          'email': ref.read(authProvider).maybeWhen(
                authenticated: (user) => user.email,
                orElse: () => '',
              ),
        },
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint('Error opening Razorpay: $e');
      }
      return;
    }

    _finalizeOrder(total, tax, discount, subtotal, cartItems);
  }

  void _finalizeOrder(
    double total,
    double tax,
    double discount,
    double subtotal,
    List<CartItemEntity> cartItems,
  ) {
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
            Text(
              AppLocalizations.of(context)!.orderPlaced,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.orderSuccessMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                child: Text(
                  AppLocalizations.of(context)!.continueShopping,
                  style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    final cartItems = ref.watch(cartProvider);
    final isPremium = ref.watch(isPremiumUserProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final appliedCoupon = ref.watch(appliedCouponProvider);
    if (appliedCoupon != null && subtotal < appliedCoupon.minOrder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(appliedCouponProvider) != null) {
          ref.read(appliedCouponProvider.notifier).state = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Coupon "${appliedCoupon.code}" removed as cart total is less than ₹${appliedCoupon.minOrder.toStringAsFixed(0)}',
              ),
              backgroundColor: AppTheme.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      });
    }
    final discount =
        (appliedCoupon != null && subtotal >= appliedCoupon.minOrder)
        ? appliedCoupon.calculateDiscount(subtotal)
        : 0.0;
    final tax = subtotal * 0.05;

    final freeDeliveryThreshold = isPremium ? 100.0 : 199.0;
    final handlingFee = (isPremium || subtotal >= freeDeliveryThreshold)
        ? 0.0
        : 10.0;
    final deliveryFee = subtotal >= freeDeliveryThreshold ? 0.0 : 40.0;

    final total = subtotal + tax - discount + handlingFee + deliveryFee;

    final addresses =
        ref.watch(addressControllerProvider).addressesAsync.valueOrNull ?? [];
    final addr =
        _selectedAddress ??
        (addresses.isNotEmpty
            ? addresses.firstWhere(
                (a) => a.isDefault,
                orElse: () => addresses.first,
              )
            : null);
    final addressText = addr != null
        ? '${addr.label}: ${addr.addressLine}, ${addr.city}'
        : l10n.selectDeliveryAddress;

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: CustomText(
            l10n.myCart,
            style: const TextStyle(
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
            CustomText(
              l10n.myCart,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 3),
            InkWell(
              onTap: _showAddressSheet,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: CustomText(
                      addressText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _buildCartSummaryBar(cartItems.length),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
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
                    padding: const EdgeInsets.symmetric(vertical: 4),
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
                            child: CustomNetworkImage(
                              imageUrl: item.product.imageUrl,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
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
                          onIncrement: () {
                            if (item.quantity >= 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.maxTenUnits,
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                              );
                              return;
                            }
                            ref
                                .read(cartProvider.notifier)
                                .incrementQuantity(item.product.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
            // Subscription Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      AppLocalizations.of(context)!.orderTypeDeliverySchedule,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children:
                          [
                            'One Time',
                            '1 Week',
                            '15 Days',
                            '1 Month',
                            'Custom Dates',
                          ].asMap().entries.map((entry) {
                            final duration = entry.value;
                            final labels = [
                                AppLocalizations.of(context)!.oneTime,
                                AppLocalizations.of(context)!.oneWeek,
                                AppLocalizations.of(context)!.fifteenDays,
                                AppLocalizations.of(context)!.oneMonth,
                                AppLocalizations.of(context)!.customDates,
                            ];
                            final label = labels[entry.key];
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
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryGreen
                                      : AppTheme.bgLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CustomText(
                                  label,
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

            // Savings Corner Card (Above Bill Details)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSavingsCorner(
                context,
                appliedCoupon,
                subtotal,
                discount,
              ),
            ),
            const SizedBox(height: 16),

            // Bill Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      AppLocalizations.of(context)!.billDetails,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: AppLocalizations.of(context)!.itemTotal,
                      value: '₹ ${subtotal.toStringAsFixed(0)}',
                    ),
                    if (appliedCoupon != null && discount > 0)
                      _SummaryRow(
                        label: 'Discount (${appliedCoupon.code})',
                        value: '-₹ ${discount.toStringAsFixed(0)}',
                        valueColor: AppTheme.primaryGreen,
                      ),
                    _SummaryRow(
                      label: AppLocalizations.of(context)!.gst,
                      value: '₹ ${tax.toStringAsFixed(0)}',
                    ),
                    _SummaryRow(
                      label: AppLocalizations.of(context)!.handlingFee,
                      value: handlingFee == 0
                          ? 'FREE'
                          : '₹ ${handlingFee.toStringAsFixed(0)}',
                      valueColor: handlingFee == 0
                          ? AppTheme.primaryGreen
                          : AppTheme.textDark,
                    ),
                    _SummaryRow(
                      label: AppLocalizations.of(context)!.deliveryFee,
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
                        CustomText(
                          AppLocalizations.of(context)!.toPay,
                          style: const TextStyle(
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
                      CustomText(
                        AppLocalizations.of(context)!.payUsing,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const Spacer(),
                      CustomText(
                        _selectedPayment ?? AppLocalizations.of(context)!.selectPayment,
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
                            CustomText(
                              AppLocalizations.of(context)!.totalText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            CustomText(
                              AppLocalizations.of(context)!.placeOrder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
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

  Widget _buildSavingsCorner(
    BuildContext context,
    CouponEntity? appliedCoupon,
    double subtotal,
    double discount,
  ) {
    final isApplied =
        appliedCoupon != null && subtotal >= appliedCoupon.minOrder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isApplied ? AppTheme.cardLavender : AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isApplied
              ? AppTheme.primaryGreen.withValues(alpha: 0.4)
              : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.savingsCorner,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => context.push('/coupons'),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isApplied
                        ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                        : AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isApplied
                        ? Icons.verified_rounded
                        : Icons.local_offer_rounded,
                    color: isApplied
                        ? AppTheme.deepGreen
                        : AppTheme.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isApplied
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '"${appliedCoupon.code}" Applied!',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.deepGreen,
                              ),
                            ),
                            Text(
                              'You saved ₹${discount.toStringAsFixed(0)} on this order',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepGreen.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          AppLocalizations.of(context)!.applyCoupon,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                ),
                if (isApplied)
                  InkWell(
                    onTap: () {
                      ref.read(appliedCouponProvider.notifier).state = null;
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppTheme.deepGreen,
                        size: 18,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppTheme.textGrey,
                  ),
              ],
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
          const Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.yourCartIsEmpty,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.nothingInCart,
            textAlign: TextAlign.center,
            style: const TextStyle(
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
              child: Text(
                AppLocalizations.of(context)!.startShopping,
                style: const TextStyle(
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
