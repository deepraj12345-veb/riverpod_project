import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/features/home/domain/entities/product_entity.dart';
import 'package:veggie_mart/features/cart/presentation/controllers/cart_controller.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/floating_cart_bar.dart';

class AddToCartButton extends ConsumerWidget {
  final ProductEntity product;
  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool isIconOnly;
  final double iconSize;

  const AddToCartButton({
    super.key,
    required this.product,
    this.width = 72.0,
    this.height = 30.0,
    this.borderRadius = 6.0,
    this.fontSize = 11.0,
    this.isIconOnly = false,
    this.iconSize = 12.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartQty = cartItems
        .where((item) => item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);

    if (cartQty == 0) {
      return GestureDetector(
        onTap: () {
          _triggerFlyAnimation(context);
          ref.read(cartProvider.notifier).addToCart(product);
        },
        child: Container(
          width: height,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppTheme.primaryColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: AppTheme.primaryColor,
              size: iconSize + 6,
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.primaryColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () =>
                ref.read(cartProvider.notifier).decrementQuantity(product.id),
            child: SizedBox(
              width: width != null ? (width! / 3.27) : height,
              height: height,
              child: Icon(
                Icons.remove,
                size: iconSize + 4,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: CustomText(
                '$cartQty',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: fontSize + 2,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _triggerFlyAnimation(context);
              ref.read(cartProvider.notifier).incrementQuantity(product.id);
            },
            child: SizedBox(
              width: width != null ? (width! / 3.27) : height,
              height: height,
              child: Icon(
                Icons.add,
                size: iconSize + 4,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerFlyAnimation(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final startPos = renderBox.localToGlobal(Offset.zero);

      // Target position of the overlapping thumbnails stack in FloatingCartBar
      final cartBox = FloatingCartBar.cartKey.currentContext?.findRenderObject()
          as RenderBox?;
      final endPos = cartBox != null
          ? cartBox.localToGlobal(Offset.zero).translate(20, 10)
          : Offset(40.0, MediaQuery.of(context).size.height - 120.0);

      FlyToCartOverlay.run(
        context: context,
        imageUrl: product.imageUrl,
        startPos: startPos,
        endPos: endPos,
        startSize: const Size(40, 40),
      );
    }
  }
}
