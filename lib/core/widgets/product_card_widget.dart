import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/presentation/providers/wishlist_controller.dart';
import 'package:veggie_mart/core/widgets/add_to_cart_button.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class ProductCardWidget extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  final bool showFavoriteButton;
  final bool showAddButton;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    this.showFavoriteButton = true,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discount = product.discountPercent.toInt();
    final isOutOfStock = !product.inStock;

    final cardContent = Opacity(
      opacity: isOutOfStock ? 0.72 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ──────────────────────────────────
            AspectRatio(
              aspectRatio: 0.82,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: const Color(0xFFF3F4F6),
                      child: CustomNetworkImage(
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
                  ),

                  // Trending tag
                  if (product.tags.contains('Trending') ||
                      product.id.hashCode % 3 == 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const CustomText(
                          'TRENDING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Out-of-stock banner
                  if (isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: const CustomText(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),

                  // Bookmark / Favorite Icon
                  if (showFavoriteButton)
                    Consumer(
                      builder: (context, ref, child) {
                        final wishlist = ref.watch(wishlistProvider);
                        final isFavorite = wishlist.any((p) => p.id == product.id);
                        return Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              if (isFavorite) {
                                ref.read(wishlistProvider.notifier).removeFromWishlist(product.id);
                              } else {
                                ref.read(wishlistProvider.notifier).addToWishlist(product);
                              }
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? AppTheme.primaryColor
                                  : Colors.black38,
                              size: 20,
                              shadows: [
                                if (!isFavorite)
                                  const Shadow(
                                    color: Colors.white70,
                                    blurRadius: 2,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),

                  if (showAddButton)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: isOutOfStock
                          ? Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                size: 18,
                                color: AppTheme.textGrey,
                              ),
                            )
                          : AddToCartButton(
                              product: product,
                              width: 80.0,
                              height: 30.0,
                              borderRadius: 12.0,
                              fontSize: 12.0,
                              iconSize: 15.0,
                            ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Unit
                      CustomText(
                        product.unit,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Product Name
                      CustomText(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isOutOfStock
                              ? AppTheme.textGrey
                              : AppTheme.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Discount
                      if (discount > 0)
                        CustomText(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      const SizedBox(height: 2),

                      // Price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isOutOfStock
                                  ? AppTheme.textGrey
                                  : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (product.originalPrice > product.price)
                            CustomText(
                              '₹${product.originalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
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
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap ?? () => context.push('/product/${product.id}', extra: product),
      child: cardContent,
    );
  }
}
