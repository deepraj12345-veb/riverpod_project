import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/custom_text.dart';
import 'package:riverpod_project/core/data/fake_data.dart';
import 'package:riverpod_project/core/models/models.dart';
import 'package:riverpod_project/features/cart/presentation/controllers/cart_controller.dart';
import 'package:riverpod_project/features/orders/presentation/controllers/orders_controller.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final double appliedDiscount;

  const CheckoutPage({super.key, required this.appliedDiscount});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  AddressModel? _selectedAddress;
  String? _selectedPayment;

  @override
  void initState() {
    super.initState();
    if (FakeData.addresses.isNotEmpty) {
      _selectedAddress = FakeData.addresses.firstWhere((a) => a.isDefault,
          orElse: () => FakeData.addresses.first);
    }
    if (FakeData.paymentMethods.isNotEmpty) {
      _selectedPayment = FakeData.paymentMethods.first;
    }
  }

  void _showOrderSuccess() {
    final cartItems = ref.read(cartProvider);
    final subtotal = ref.read(cartTotalProvider);
    final discount = subtotal * widget.appliedDiscount;
    final tax = subtotal * 0.05;
    final total = subtotal + tax - discount;

    ref.read(ordersProvider.notifier).addOrder(
          cartItems,
          subtotal,
          tax,
          discount,
          total,
          _selectedPayment ?? 'Unknown',
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.primaryGreen, size: 72),
            const SizedBox(height: 16),
            const CustomText(
              'Order Placed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const CustomText(
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
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const CustomText(
                'Continue Shopping',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartTotalProvider);
    final discount = subtotal * widget.appliedDiscount;
    final tax = subtotal * 0.05;
    final total = subtotal + tax - discount;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        title: const CustomText(
          'Checkout',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Delivery Address',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 12),
                  ...FakeData.addresses
                      .map((address) => _buildAddressTile(address))
                      .toList(),
                  const SizedBox(height: 24),
                  const CustomText(
                    'Payment Method',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 12),
                  ...FakeData.paymentMethods
                      .map((pm) => _buildPaymentTile(pm))
                      .toList(),
                  const SizedBox(height: 24),
                  const CustomText(
                    'Order Summary',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                            label: 'Subtotal',
                            value: 'Rs ${subtotal.toStringAsFixed(0)}'),
                        if (widget.appliedDiscount > 0)
                          _SummaryRow(
                            label:
                                'Discount (${(widget.appliedDiscount * 100).toInt()}%)',
                            value: '-Rs ${discount.toStringAsFixed(0)}',
                            valueColor: AppTheme.primaryGreen,
                          ),
                        _SummaryRow(
                            label: 'GST (5%)',
                            value: 'Rs ${tax.toStringAsFixed(0)}'),
                        const _SummaryRow(
                            label: 'Delivery',
                            value: 'FREE',
                            valueColor: AppTheme.primaryGreen),
                        const SizedBox(height: 8),
                        const Divider(color: AppTheme.borderColor),
                        const SizedBox(height: 8),
                        _SummaryRow(
                            label: 'Total Amount',
                            value: 'Rs ${total.toStringAsFixed(0)}',
                            isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText('Total',
                        style:
                            TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                    CustomText(
                      'Rs ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: _showOrderSuccess,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CustomText(
                          'Place Order',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
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

  Widget _buildAddressTile(AddressModel address) {
    final isSelected = _selectedAddress?.id == address.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddress = address),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(
                        address.title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const CustomText(
                            'DEFAULT',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    address.fullAddress,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textGrey, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(String paymentMethod) {
    final isSelected = _selectedPayment == paymentMethod;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = paymentMethod),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
              size: 22,
            ),
            const SizedBox(width: 12),
            CustomText(
              paymentMethod,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark),
            ),
          ],
        ),
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
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppTheme.textDark : AppTheme.textGrey,
            ),
          ),
          CustomText(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ??
                  (isBold ? AppTheme.textDark : AppTheme.textMedium),
            ),
          ),
        ],
      ),
    );
  }
}
