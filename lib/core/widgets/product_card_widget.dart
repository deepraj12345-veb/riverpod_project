import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:riverpod_project/core/widgets/custom_network_image.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';
import 'package:riverpod_project/features/home/presentation/controllers/home_controller.dart';
import 'package:riverpod_project/core/widgets/add_to_cart_button.dart';
import 'package:riverpod_project/core/widgets/custom_text.dart';

class ProductCardWidget extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final double imageHeight;

  final bool showFavoriteButton;
  final bool showAddButton;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    this.imageHeight = 120.0,
    this.showFavoriteButton = true,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discount = product.discountPercent.toInt();
    final isOutOfStock = !product.inStock;

    return GestureDetector(
      onTap: onTap ?? () => context.push('/product/${product.id}'),
      child: Opacity(
        opacity: isOutOfStock ? 0.72 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOutOfStock
                    ? const Color(0xFFD1D5DB)
                    : AppTheme.borderColor,
                width: 0.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image section ──────────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? const Color(0xFFF3F4F6)
                            : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(11),
                        ),
                      ),
                      child: isOutOfStock
                          ? CustomNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: const SizedBox(),
                              errorWidget: const Icon(
                                Icons.image_outlined,
                                color: AppTheme.textGrey,
                                size: 32,
                              ),
                            )
                          : CustomNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorWidget: const Icon(
                                Icons.image_outlined,
                                color: AppTheme.textGrey,
                                size: 32,
                              ),
                            ),
                    ),

                    // Out-of-stock banner across image
                    if (isOutOfStock)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1F2937),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.zero,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const CustomText(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                    ///. add to cart button
                    if (showAddButton)
                      Positioned(
                        bottom: -15,
                        right: 0,
                        child: Center(
                          child: isOutOfStock
                              ? Container(
                                  width: 72,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    border: Border.all(
                                        color: const Color(0xFFD1D5DB),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      size: 14,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                )
                              : AddToCartButton(
                                  product: product,
                                  width: 72.0,
                                  height: 30.0,
                                  borderRadius: 6.0,
                                  fontSize: 11.0,
                                  iconSize: 12.0,
                                ),
                        ),
                      ),
                    // Favourite heart
                    if (showFavoriteButton)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(productsProvider.notifier)
                              .toggleFavorite(product.id),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                product.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: product.isFavorite
                                    ? AppTheme.accentRed
                                    : AppTheme.textGrey,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // ── Info section ───────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          product.unit,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        CustomText(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            // height: 1.3,
                            color: isOutOfStock
                                ? AppTheme.textGrey
                                : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        CustomText(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              '₹ ${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isOutOfStock
                                    ? AppTheme.textGrey
                                    : AppTheme.textDark,
                              ),
                            ),
                            if (product.originalPrice > product.price)
                              CustomText(
                                'MRP ₹ ${product.originalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textGrey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
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
