import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/data/fake_data.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/product_card_widget.dart';
import 'package:veggie_mart/core/widgets/section_header_widget.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/presentation/providers/home_controller.dart';
import 'package:veggie_mart/core/widgets/category_row_widget.dart';
import 'package:veggie_mart/core/widgets/home_banner_widget.dart';
import 'package:veggie_mart/core/widgets/subcategory_chips_widget.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/presentation/providers/category_provider.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/domain/entities/subcategory_entity.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _selectedSub = '';

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final allProducts = ref.watch(productsProvider);

    // Reset subcategory when main category changes
    ref.listen(selectedCategoryProvider, (prev, next) {
      if (prev != next) setState(() => _selectedSub = '');
    });

    final showDefault = selectedCategory == 'All';
    final displayProducts = filteredProducts;

    final chefsPicks = allProducts
        .where((p) => p.rating >= 4.7)
        .take(4)
        .toList();

    final trendingProducts = (List<ProductEntity>.from(
      allProducts,
    )..sort((a, b) => b.reviewCount.compareTo(a.reviewCount))).take(5).toList();

    final categoriesAsync = ref.watch(categoriesProvider);
    final subcategoriesAsync = ref.watch(subcategoriesProvider);

    // Build category list: while loading, show only 'All'
    final apiCategories = categoriesAsync.when(
      data: (cats) => ['All', ...cats.map((c) => c.name)],
      loading: () => const <String>['All'],
      error: (_, __) => const <String>['All'],
    );

    final allSubcats = subcategoriesAsync.maybeWhen(
      data: (subs) => subs,
      orElse: () => <SubcategoryEntity>[],
    );

    // Build subcategory chips from real API data
    List<String> currentSubs;
    if (selectedCategory == 'All') {
      currentSubs = allSubcats.map((e) => e.name).take(12).toList();
    } else {
      final selectedCatObj = categoriesAsync.value
          ?.cast<CategoryEntity?>()
          .firstWhere((c) => c?.name == selectedCategory, orElse: () => null);
      currentSubs = selectedCatObj != null
          ? allSubcats
                .where((e) => e.categoryId == selectedCatObj.id)
                .map((e) => e.name)
                .toList()
          : <String>[];
    }

    // ── Responsive values ───────────────────────────────────────────────────────
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW >= 600;
    final hCardWidth = (screenW - 48) / 3;
    const textHeight = 108.0;
    final imageH = hCardWidth / 0.82;
    final hListHeight = imageH + textHeight;
    final bannerH = isTablet ? 190.0 : 148.0;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top header ──────────────────────────────────────
            const SliverToBoxAdapter(child: _AppHeader()),

            // ── Dummy Search bar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        CustomText(
                          'Search products, brands, tags…',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Category row ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: CategoryRowWidget(
                  categories: apiCategories,
                  selected: selectedCategory,
                  onSelect: (cat) =>
                      ref.read(selectedCategoryProvider.notifier).state = cat,
                ),
              ),
            ),

            // ── Default view (no filter / search) ───────────────
            if (showDefault) ...[
              // Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  child: HomeBannerWidget(
                    banners: FakeData.banners,
                    bannerHeight: bannerH,
                  ),
                ),
              ),

              // Chef's Picks header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: SectionHeaderWidget(
                    title: "Chef's Picks & Bestsellers",
                    onSeeAll: () {},
                  ),
                ),
              ),
              // Chef's Picks list
              SliverToBoxAdapter(
                child: _HorizontalProductList(
                  products: chefsPicks,
                  cardWidth: hCardWidth,
                  height: hListHeight,
                ),
              ),

              // Trending Near You header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: SectionHeaderWidget(
                    title: 'Trending Near You',
                    subtitle: 'Discover the top products trending today',
                    onSeeAll: () {},
                  ),
                ),
              ),
              // Trending list
              SliverToBoxAdapter(
                child: _HorizontalProductList(
                  products: trendingProducts,
                  cardWidth: hCardWidth,
                  height: hListHeight,
                ),
              ),

              // Shop by Type header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: SectionHeaderWidget(title: 'Shop by Type'),
                ),
              ),
              // Subcategory chips
              SliverToBoxAdapter(
                child: SubcategoryChipsWidget(
                  subcategories: currentSubs,
                  selected: _selectedSub,
                  onSelect: (sub) => setState(() => _selectedSub = sub),
                ),
              ),

              // All Products header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: SectionHeaderWidget(
                    title: 'All Products',
                    onSeeAll: null,
                  ),
                ),
              ),
            ] else ...[
              // Subcategory chips for filtered view
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SubcategoryChipsWidget(
                    subcategories: currentSubs,
                    selected: _selectedSub,
                    onSelect: (sub) => setState(() => _selectedSub = sub),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      CustomText(
                        selectedCategory,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomText(
                          '${displayProducts.length} items',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // ── Product grid (responsive) ─────────────────────────
            displayProducts.isEmpty
                ? SliverToBoxAdapter(child: _EmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio:
                            hCardWidth / (hCardWidth / 0.82 + 108.0),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            ProductCardWidget(product: displayProducts[i]),
                        childCount: displayProducts.length,
                      ),
                    ),
                  ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

// ── Header widget ──────────────────────────────────────────────────────────────

class _AppHeader extends ConsumerWidget {
  const _AppHeader();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CustomText('🥗', style: TextStyle(fontSize: 19)),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Fresh Veggie Mart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    CustomText(
                      'Fresh fruits & vegetables delivered',
                      style: TextStyle(fontSize: 11, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
              const _HeaderIconBtn(icon: Icons.notifications_outlined),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: const _HeaderIconBtn(icon: Icons.person_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 15,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 4),
              const CustomText(
                'Deliver to Jaipur',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 17,
                color: AppTheme.textGrey,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const CustomText(
                  '⚡ 30 min delivery',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Icon(icon, size: 20, color: AppTheme.textDark),
    );
  }
}

// ── Horizontal product list ────────────────────────────────────────────────────

class _HorizontalProductList extends StatelessWidget {
  final List<ProductEntity> products;
  final double cardWidth;
  final double height;

  const _HorizontalProductList({
    required this.products,
    this.cardWidth = 155,
    this.height = 310,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => SizedBox(
          width: cardWidth,
          child: ProductCardWidget(product: products[i]),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppTheme.bgLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 44,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          const CustomText(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const CustomText(
            'Try a different search or category',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
