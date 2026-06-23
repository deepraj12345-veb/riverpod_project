import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_project/core/data/fake_data.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/core/widgets/product_card_widget.dart';
import 'package:riverpod_project/core/widgets/section_header_widget.dart';
import 'package:riverpod_project/core/widgets/suggestion_field.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';
import 'package:riverpod_project/features/home/presentation/controllers/home_controller.dart';
import 'package:riverpod_project/features/home/presentation/widgets/category_row_widget.dart';
import 'package:riverpod_project/features/home/presentation/widgets/home_banner_widget.dart';
import 'package:riverpod_project/features/home/presentation/widgets/subcategory_chips_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchCtrl = TextEditingController();
  String _selectedSub = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final allProducts = ref.watch(productsProvider);
    final searchedProducts = ref.watch(searchedProductsProvider);

    // Reset subcategory when main category changes
    ref.listen(selectedCategoryProvider, (prev, next) {
      if (prev != next) setState(() => _selectedSub = '');
    });

    final showDefault = searchQuery.isEmpty && selectedCategory == 'All';
    final displayProducts =
        searchQuery.isNotEmpty ? searchedProducts : filteredProducts;

    final chefsPicks =
        allProducts.where((p) => p.rating >= 4.7).take(4).toList();

    final trendingProducts = (List<ProductEntity>.from(allProducts)
          ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount)))
        .take(5)
        .toList();

    final productSuggestions = FakeData.products.map((p) => p.name).toList()
      ..addAll(FakeData.categories.where((c) => c != 'All'))
      ..addAll(FakeData.products.expand((p) => p.tags).toSet());

    final currentSubs =
        FakeData.subcategories[selectedCategory] ?? FakeData.subcategories['All']!;

    // ── Responsive values ───────────────────────────────────────────────────────
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW >= 600;
    final isLargeTablet = screenW >= 900;
    final crossAxisCount = isLargeTablet ? 4 : (isTablet ? 3 : 2);
    final hCardWidth = isTablet ? 180.0 : 155.0;
    final hListHeight = isTablet ? 275.0 : 238.0;
    final bannerH = isTablet ? 190.0 : 148.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: const _AppHeader(),
            ),

            // ── Search bar ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SuggestionField(
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
              ),
            ),

            // ── Category row ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: CategoryRowWidget(
                  categories: FakeData.categories,
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
                    title: '🔥 Trending Near You',
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: const SectionHeaderWidget(title: 'Shop by Type'),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
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
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Results for "$searchQuery"'
                            : selectedCategory,
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
                        child: Text(
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
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.63,
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0)),
        ),
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
                  child: Text('🥗', style: TextStyle(fontSize: 19)),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fresh Veggie Mart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      'Fresh fruits & vegetables delivered',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              _HeaderIconBtn(icon: Icons.notifications_outlined),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: _HeaderIconBtn(icon: Icons.person_outline_rounded),
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
              const Text(
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
                child: const Text(
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
    this.height = 238,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
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
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search or category',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
