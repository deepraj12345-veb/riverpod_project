import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:riverpod_project/core/data/fake_data.dart';
import 'package:riverpod_project/core/models/models.dart';
import 'package:riverpod_project/core/providers/app_providers.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/suggestion_field.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchCtrl = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchedProducts = ref.watch(searchedProductsProvider);
    final displayProducts =
        searchQuery.isNotEmpty ? searchedProducts : filteredProducts;

    // Build product-name suggestion list from all products
    final productSuggestions = FakeData.products.map((p) => p.name).toList()
      ..addAll(FakeData.categories.where((c) => c != 'All'))
      ..addAll(FakeData.products.expand((p) => p.tags).toSet());

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ────────────────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with action icons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Online Shop',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            badges.Badge(
                              showBadge: cartCount > 0,
                              badgeContent: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              badgeStyle: const badges.BadgeStyle(
                                badgeColor: AppTheme.primaryGreen,
                                padding: EdgeInsets.all(4),
                              ),
                              child: _IconButton(
                                icon: Icons.shopping_bag_outlined,
                                onTap: () => context.go('/cart'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            badges.Badge(
                              badgeContent: const Text(
                                '3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              badgeStyle: const badges.BadgeStyle(
                                badgeColor: AppTheme.primaryGreen,
                                padding: EdgeInsets.all(4),
                              ),
                              child: _IconButton(
                                icon: Icons.notifications_outlined,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ─── Search bar with live product suggestions ──────────────────
                    SuggestionField(
                      controller: _searchCtrl,
                      label: 'Search',
                      hint: 'Search products, brands, tags…',
                      icon: Icons.search_rounded,
                      suggestions: productSuggestions,
                      onChanged: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                      onSelected: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                    ),

                    const SizedBox(height: 16),

                    // ─── Category Chips ──────────────────────────────────────
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: FakeData.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final cat = FakeData.categories[i];
                          final isSelected = cat == selectedCategory;
                          return GestureDetector(
                            onTap: () => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = cat,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.textDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.textDark
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textGrey,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ─── Section Header ──────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Results (${displayProducts.length})'
                              : selectedCategory == 'All'
                                  ? 'Recommendation'
                                  : selectedCategory,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: const Icon(
                              Icons.grid_view_rounded,
                              size: 18,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ─── Product Grid ─────────────────────────────────────────────────
            displayProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: AppTheme.textGrey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverMasonryGrid(
                      gridDelegate:
                          const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _ProductCard(
                            product: displayProducts[index],
                            cardColor: AppTheme.cardColors[
                                displayProducts[index].id.hashCode.abs() %
                                    AppTheme.cardColors.length],
                          );
                        },
                        childCount: displayProducts.length,
                      ),
                    ),
                  ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }
}

// ─── Small icon button ────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 20),
      ),
    );
  }
}

// ─── Product Card — matches reference image exactly ───────────────────────────

class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  final Color cardColor;

  const _ProductCard({required this.product, required this.cardColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.go('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image container with pastel background ──
            Stack(
              children: [
                // Pastel background
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      fit: BoxFit.fitWidth,
                      placeholder: (ctx, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.textGrey.withValues(alpha: 0.4),
                        ),
                      ),
                      errorWidget: (ctx, url, err) => Icon(
                        Icons.image_outlined,
                        color: AppTheme.textGrey.withValues(alpha: 0.4),
                        size: 40,
                      ),
                    ),
                  ),
                ),
                // Heart / Favourite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(productsProvider.notifier)
                        .toggleFavorite(product.id),
                    child: Icon(
                      product.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: product.isFavorite
                          ? AppTheme.accentRed
                          : AppTheme.textGrey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // ── Product info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Orange price
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.priceOrange,
                        ),
                      ),
                      // Black "Buy" button
                      GestureDetector(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added! 🛒'),
                              backgroundColor: AppTheme.textDark,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.buyBlack,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Buy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
  }
}
