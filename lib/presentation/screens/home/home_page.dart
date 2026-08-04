import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veg_king/core/theme/app_theme.dart';
import 'package:veg_king/core/widgets/product_card_widget.dart';
import 'package:veg_king/core/widgets/section_header_widget.dart';
import 'package:veg_king/domain/entities/product_entity.dart';
import 'package:veg_king/domain/entities/category_entity.dart';
import 'package:veg_king/presentation/providers/home_controller.dart';
import 'package:veg_king/core/widgets/home_banner_widget.dart';
import 'package:veg_king/core/widgets/subcategory_chips_widget.dart';
import 'package:veg_king/core/widgets/custom_text.dart';
import 'package:veg_king/core/widgets/home_page_skeleton.dart';
import 'package:veg_king/presentation/providers/dashboard_provider.dart';
import 'package:veg_king/presentation/providers/address_controller.dart';
import 'package:veg_king/core/widgets/address_bottom_sheet.dart';
import 'package:veg_king/l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _selectedSub = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
    });
  }

  _fetchCategories() {
    ref.read(dashboardProvider.notifier).fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final dashboardAsync = ref.watch(dashboardProvider);

    ref.listen(selectedCategoryProvider, (prev, next) {
      if (prev != next) setState(() => _selectedSub = '');
    });

    return dashboardAsync.when(
      loading: () => const HomePageSkeleton(),
      error: (error, st) => Scaffold(
        body: SingleChildScrollView(
          child: Center(child: Text('Error: $error\n\nStackTrace:\n$st')),
        ),
      ),
      data: (dashboard) {
        final List<ProductEntity> allProducts = ref.watch(productsProvider);

        // Find the selected CategoryType object (if not 'All')
        final selectedCatType = dashboard.categoryTypes
            .where((c) => c.name == selectedCategory)
            .firstOrNull;

        // Find relevant Categories (Subcategories)
        List<CategoryEntity> relevantCategories;
        if (selectedCategory == 'All' || selectedCatType == null) {
          relevantCategories = dashboard.categories;
        } else {
          relevantCategories = dashboard.categories
              .where((c) => c.typeId == selectedCatType.id)
              .toList();
        }

        // Build subcategory chips from real API data
        List<String> currentSubs = relevantCategories
            .map((c) => c.name)
            .toList();

        // Filter products
        List<ProductEntity> filteredProducts = [];
        if (_selectedSub.isNotEmpty) {
          filteredProducts = allProducts
              .where((p) => p.category == _selectedSub)
              .toList();
        } else if (selectedCategory == 'All') {
          filteredProducts = allProducts;
        } else {
          final validCatNames = relevantCategories.map((c) => c.name).toSet();
          filteredProducts = allProducts
              .where((p) => validCatNames.contains(p.category))
              .toList();
        }

        final showDefault = selectedCategory == 'All' && _selectedSub.isEmpty;
        final displayProducts = filteredProducts;

        final chefsPicks = dashboard.bestsellers;
        final trendingProducts = dashboard.trendingNearYou;

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
                const SliverToBoxAdapter(child: AppHeader()),

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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppTheme.primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            CustomText(
                              l10n.searchProducts,
                              style: const TextStyle(
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

                // // ── Category row ────────────────────────────────────
                // SliverToBoxAdapter(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 14),
                //     child: CategoryRowWidget(
                //       categories: apiCategories,
                //       selected: selectedCategory,
                //       onSelect: (cat) =>
                //           ref.read(selectedCategoryProvider.notifier).state =
                //               cat,
                //     ),
                //   ),
                // ),
                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // ── Default view (no filter / search) ───────────────
                if (showDefault) ...[
                  // Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: HomeBannerWidget(
                        banners: dashboard.banners,
                        bannerHeight: bannerH,
                      ),
                    ),
                  ),

                  // Chef's Picks header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                      child: SectionHeaderWidget(
                        title: l10n.chefsPicksBestsellers,
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
                        title: l10n.trendingNearYou,
                        subtitle: l10n.discoverTopProducts,
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
                      child: SectionHeaderWidget(title: l10n.shopByType),
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
                        title: l10n.allProducts,
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
                              fontWeight: FontWeight.w500,
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
                              color: AppTheme.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomText(
                              l10n.itemsCount(displayProducts.length),
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
      },
    );
  }
}

// ── Header widget ──────────────────────────────────────────────────────────────

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final addressState = ref.watch(addressControllerProvider);
    final addresses = addressState.addressesAsync.valueOrNull ?? [];
    final defaultAddress = addresses.isNotEmpty
        ? addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          )
        : null;

    final addressText = defaultAddress != null
        ? '${defaultAddress.label}: ${defaultAddress.addressLine}, ${defaultAddress.city}'
        : l10n.selectDeliveryAddress;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          // Logo
          ClipOval(
            child: Image.asset(
              'assets/app-logo-square.png',
              width: 42,
              height: 42,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  l10n.freshVeggieMart,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                InkWell(
                  onTap: () => showAddressBottomSheet(context, ref),
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: CustomText(
                          addressText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppTheme.textDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const HeaderIconBtn(icon: Icons.notifications_outlined),
        ],
      ),
    );
  }
}

class HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const HeaderIconBtn({super.key, required this.icon});

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
          CustomText(
            AppLocalizations.of(context)!.noProductsFound,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          CustomText(
            AppLocalizations.of(context)!.tryDifferentSearch,
            style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
