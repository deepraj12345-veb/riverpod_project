import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';
import 'package:riverpod_project/features/home/presentation/controllers/home_controller.dart';
import 'package:riverpod_project/features/cart/presentation/controllers/cart_controller.dart';

class ProductCardWidget extends ConsumerWidget {
  final ProductEntity product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discount = product.discountPercent.toInt();
    final isOutOfStock = !product.inStock;

    final cartItems = ref.watch(cartProvider);
    final cartQty = cartItems
        .where((item) => item.product.id == product.id)
        .fold(0, (sum, item) => sum + item.quantity);

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Opacity(
        opacity: isOutOfStock ? 0.72 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOutOfStock ? const Color(0xFFD1D5DB) : AppTheme.borderColor,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image section ──────────────────────────────────
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? const Color(0xFFF3F4F6)
                          : AppTheme.cardColors[
                              product.id.hashCode.abs() % AppTheme.cardColors.length],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(11),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: isOutOfStock
                        ? ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                            child: CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (ctx, url) => const SizedBox(),
                              errorWidget: (ctx, url, err) => const Icon(
                                Icons.image_outlined,
                                color: AppTheme.textGrey,
                                size: 32,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (ctx, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            errorWidget: (ctx, url, err) => const Icon(
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
                        child: const Text(
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

                  // Discount badge (only when in stock)
                  if (discount > 0 && !isOutOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3A00),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '$discount%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                  // Favourite heart
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
                              color: Colors.black.withValues(alpha: 0.12),
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
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name — 2 lines so longer names aren't cut off
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: isOutOfStock
                              ? AppTheme.textGrey
                              : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Unit and Rating row (side-by-side to save space)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.unit,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textGrey,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Color(0xFFFFBE21),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _fmtCount(product.reviewCount),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Price & Action button side-by-side
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price column (stacked Price & Original Price)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rs ${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isOutOfStock
                                        ? AppTheme.textGrey
                                        : AppTheme.textDark,
                                  ),
                                ),
                                if (product.originalPrice > product.price)
                                  Text(
                                    'Rs ${product.originalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textGrey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Compact Action Button
                          SizedBox(
                            width: 72,
                            height: 30,
                            child: isOutOfStock
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
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
                                : cartQty == 0
                                    ? GestureDetector(
                                        onTap: () => ref.read(cartProvider.notifier).addToCart(product),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'ADD',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => ref
                                                  .read(cartProvider.notifier)
                                                  .decrementQuantity(product.id),
                                              child: const SizedBox(
                                                width: 22,
                                                height: 30,
                                                child: Icon(Icons.remove, size: 12, color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  '$cartQty',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => ref
                                                  .read(cartProvider.notifier)
                                                  .incrementQuantity(product.id),
                                              child: const SizedBox(
                                                width: 22,
                                                height: 30,
                                                child: Icon(Icons.add, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
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
    );
  }
}

String _fmtCount(int count) {
  if (count >= 1000) {
    final k = count / 1000;
    return '(${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k)';
  }
  return '($count)';
}
