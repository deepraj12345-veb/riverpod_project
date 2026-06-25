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
          width: width,
          height: height,
          margin: const EdgeInsets.only(right: 2),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF8BC34A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: isIconOnly
                ? Icon(
                    Icons.add,
                    color: Colors.white,
                    size: iconSize + 6,
                  )
                : CustomText(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(borderRadius),
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
                size: iconSize,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: CustomText(
                '$cartQty',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: fontSize,
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
                size: iconSize,
                color: Colors.white,
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
