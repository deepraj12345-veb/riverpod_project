import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/presentation/providers/home_controller.dart';
import 'package:veggie_mart/core/widgets/add_to_cart_button.dart';
import 'package:veggie_mart/core/widgets/product_card_widget.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class ProductDetailPage extends ConsumerWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => products.first,
    );
    final discount = product.discountPercent.toInt();

    // Fetch similar products
    final similarProducts = products
        .where((p) => p.category == product.category && p.id != product.id)
        .toList();

    final screenW = MediaQuery.of(context).size.width;
    final cardWidth = (screenW - 48) / 3;
    final listHeight = (cardWidth / 0.82) + 108.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Scrollable content with SliverAppBar ──────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 340,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leadingWidth: 56,
                  leading: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: _CircleBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                      ),
                    ),
                  ),
                  actions: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _CircleBtn(
                          icon: Icons.shopping_cart_outlined,
                          onTap: () => context.go('/cart'),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: product.inStock
                          ? Colors.white
                          : const Color(0xFFF3F4F6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Product image
                          product.inStock
                              ? CustomNetworkImage(
                                  imageUrl: product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: const Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: AppTheme.textGrey,
                                  ),
                                )
                              : ColorFiltered(
                                  colorFilter: const ColorFilter.matrix([
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    1,
                                    0,
                                  ]),
                                  child: CustomNetworkImage(
                                    imageUrl: product.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: const SizedBox(),
                                    errorWidget: const Icon(
                                      Icons.image_outlined,
                                      size: 60,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ),
                          // Discount badge
                          if (discount > 0 && product.inStock)
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3A00),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomText(
                                  '$discount% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          // Out of stock overlay label
                          if (!product.inStock)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1F2937),
                                ),
                                alignment: Alignment.center,
                                child: const CustomText(
                                  'OUT OF STOCK',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          // Favourite
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: GestureDetector(
                              onTap: () => ref
                                  .read(productsProvider.notifier)
                                  .toggleFavorite(product.id),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  product.isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: product.isFavorite
                                      ? AppTheme.accentRed
                                      : AppTheme.textGrey,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ── Product info ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + stock badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textDark,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.inStock
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomText(
                                    product.inStock
                                        ? 'In Stock'
                                        : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: product.inStock
                                          ? AppTheme.primaryGreen
                                          : AppTheme.accentRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 0),
                            CustomText(
                              product.unit,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textGrey,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // Price row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  'Rs ${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: CustomText(
                                    'MRP Rs ${product.originalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textGrey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (discount > 0 && product.inStock)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: CustomText(
                                      '$discount% OFF',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // ── Benefits Info Row ──
                            const Row(
                              children: [
                                Expanded(
                                  child: _BenefitCard(
                                    emoji: '🌿',
                                    title: '100% Organic',
                                    subtitle: 'Naturally grown',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _BenefitCard(
                                    emoji: '⏳',
                                    title: '3-5 Days',
                                    subtitle: 'Shelf life',
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: _BenefitCard(
                                    emoji: '⚡',
                                    title: '30 Mins',
                                    subtitle: 'Fast delivery',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            const Divider(color: AppTheme.borderColor),
                            const SizedBox(height: 10),

                            // Description
                            const CustomText(
                              'Description',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomText(
                              product.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textGrey,
                                height: 1.7,
                              ),
                            ),

                            const SizedBox(height: 10),
                            const Divider(color: AppTheme.borderColor),
                            const SizedBox(height: 8),

                            // Accordions
                            Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: const ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                iconColor: AppTheme.primaryGreen,
                                collapsedIconColor: AppTheme.textGrey,
                                title: CustomText(
                                  'Storage & Handling',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: CustomText(
                                      'Store in a cool, dry place. Keep away from direct sunlight. To maintain absolute freshness, wrap in organic wrap and store in your refrigerator vegetable crisper drawer.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textGrey,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //  const Divider(color: AppTheme.borderColor),
                            Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: const ExpansionTile(
                                childrenPadding: EdgeInsets.zero,
                                tilePadding: EdgeInsets.zero,
                                iconColor: AppTheme.primaryGreen,
                                collapsedIconColor: AppTheme.textGrey,
                                title: CustomText(
                                  'Nutrition & Benefits',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: CustomText(
                                      'Naturally rich in vitamins A, C, and K. Packed with dietary fiber which supports gut health and digestion. Source of organic minerals that promote healthy metabolism and robust immunity.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textGrey,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: AppTheme.borderColor),
                            const SizedBox(height: 10),

                            // Similar Products
                            if (similarProducts.isNotEmpty) ...[
                              const CustomText(
                                'Similar Products',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: listHeight,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: similarProducts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (ctx, i) {
                                    return SizedBox(
                                      width: cardWidth,
                                      child: ProductCardWidget(
                                        product: similarProducts[i],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom bar with counter ──────────────────────────
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(color: AppTheme.borderColor),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Price info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Rs ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        CustomText(
                          'MRP Rs ${product.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Counter
                  if (!product.inStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 16,
                            color: AppTheme.textGrey,
                          ),
                          SizedBox(width: 6),
                          CustomText(
                            'Notify Me',
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AddToCartButton(
                      product: product,
                      width: 80,
                      height: 38.0,
                      borderRadius: 12.0,
                      fontSize: 16.0,
                      isIconOnly: false,
                      iconSize: 20.0,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textDark),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _BenefitCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.8),
      ),
      child: Column(
        children: [
          CustomText(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          CustomText(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          CustomText(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
