import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/product_card_widget.dart';
import 'package:veggie_mart/core/widgets/floating_cart_bar.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/presentation/providers/dashboard_provider.dart';

class SubcategoryPage extends ConsumerStatefulWidget {
  final String categoryName;

  const SubcategoryPage({super.key, required this.categoryName});

  @override
  ConsumerState<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends ConsumerState<SubcategoryPage> {
  late String selectedSub;

  @override
  void initState() {
    super.initState();
    selectedSub = widget.categoryName;
  }

  static const Map<String, String> _subEmoji = {
    'All': '📦',
    'Organic': '🌿',
    'On Sale': '🔥',
    'Fresh Today': '🌱',
    'Local Farms': '🚜',
    'Superfoods': '💪',
    'Bestsellers': '⭐',
    'New Arrivals': '✨',
    'Premium': '👑',
    'Berries & Other': '🍇',
    'Tropical Fruits': '🥭',
    'Roots, Herbs & Other': '🥕',
    'Basic Vegetables': '🥦',
    'Atta, Rice, Dal & More': '🌾',
    'Cold Drink, Energy Drinks & Juice': '🥤',
    'Tea, Coffee, Milk Drinks': '☕',
    'Dairy Product, Cheese & Eggs': '🧀',
    'Pharma & Wellness': '💊',
    'Snacks, Munchies, Ice-Creams & Sweets': '🍦',
    'Breakfast & Instant Food': '🥣',
    'Bakery, Biscuit & Baking Product': '🍞',
    'Masala, Oil & More': '🫙',
    'Baby Care': '👶',
    'Cleaning Essentials': '🧹',
    'Home, Office & Stationary': '🏠',
    'Personal Care': '🧴',
    'Pet Care': '🐾',
    'Mouth Fresheners & Candy': '🍬',
    'Frozen Chicken, Meat & Fish': '🍗',
    'Pickles, Sauces & Spreads': '🥫',
    'Dry Fruits, Nuts & Seeds': '🥜',
    'Papad, Fryums & More': '🍘',
    'Gifts': '🎁',
    'Electronics': '⚡',
    'Milk': '🥛',
    'Cheese': '🧀',
    'Curd & Yoghurt': '🍶',
    'Butter & Cream': '🧈',
    'Chips': '🥔',
    'Cookies': '🍪',
    'Nuts & Dry Fruits': '🥜',
    'Chocolates': '🍫',
  };

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      ),
      error: (error, _) => Scaffold(body: Center(child: Text('Error: $error'))),
      data: (dashboard) {
        final allCategories = dashboard.categories;

        final allProducts = dashboard.categories
            .expand<ProductEntity>((c) => c.products ?? [])
            .toList();

        final displayedProducts = allProducts
            .where((p) => p.category == selectedSub)
            .toList();

        final screenW = MediaQuery.of(context).size.width;
        final contentW = screenW - 80; // 80 is sidebar width
        final cardWidth =
            (contentW - 32) /
            2; // 16 padding on each side, 2 columns -> no spacing in between if we use grid aspect ratio

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
              onPressed: () => context.pop(),
            ),
            title: const CustomText(
              'Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textDark),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Left Sidebar
                    Container(
                      width: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(color: AppTheme.borderColor),
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: allCategories.length,
                        itemBuilder: (ctx, i) {
                          final subEntity = allCategories[i];
                          final subName = subEntity.name;
                          final isSelected = selectedSub == subName;
                          final emoji = _subEmoji[subName] ?? '📦';

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedSub = subName;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF0FDF4)
                                    : Colors.transparent,
                                border: isSelected
                                    ? const Border(
                                        left: BorderSide(
                                          color: AppTheme.primaryGreen,
                                          width: 3,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFF3F4F6),
                                      border: isSelected
                                          ? Border.all(
                                              color: AppTheme.primaryGreen,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Center(
                                      child:
                                          subEntity.imageUrl != null &&
                                              subEntity.imageUrl!.isNotEmpty
                                          ? ClipOval(
                                              child: CustomNetworkImage(
                                                imageUrl:
                                                    subEntity.imageUrl!
                                                        .startsWith('http')
                                                    ? subEntity.imageUrl!
                                                    : 'https://vegimart-backend.vercel.app${subEntity.imageUrl}',
                                                fit: BoxFit.cover,
                                                height: 56,
                                                width: 56,
                                                placeholder: CustomText(
                                                  emoji,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : CustomText(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: CustomText(
                                      subName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: AppTheme.textDark,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Right Grid
                    Expanded(
                      child: Container(
                        color: const Color(0xFFF9FAFB),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio:
                                    cardWidth / ((cardWidth / 0.82) + 108.0),
                              ),
                          itemCount: displayedProducts.length,
                          itemBuilder: (ctx, i) {
                            return ProductCardWidget(
                              product: displayedProducts[i],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const FloatingCartBar(),
            ],
          ),
        );
      },
    );
  }
}
