import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:veggie_mart/presentation/providers/dashboard_provider.dart';
import 'package:veggie_mart/presentation/providers/home_controller.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  static const Map<String, Color> _catColor = {
    'Fruits': Color(0xFFFFF3CD),
    'Vegetables': Color(0xFFDCFCE7),
    'Groceries': Color(0xFFEDE9FE),
    'Dairy': Color(0xFFE0F2FE),
    'Snacks': Color(0xFFFEE2E2),
  };

  static const Map<String, String> _subEmoji = {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const CustomText(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppTheme.textDark),
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = 'All';
              context.go('/home');
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (dashboard) {
          final allCategories = dashboard.categories;

          if (allCategories.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: allCategories.length,
            itemBuilder: (ctx, i) {
              final cat = allCategories[i];
              final color = _catColor[cat.name] ?? AppTheme.cardMint;
              final emoji = _subEmoji[cat.name] ?? '📦';

              return GestureDetector(
                onTap: () => context.push('/subcategory', extra: cat.name),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Center(
                          child:
                              cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: CustomNetworkImage(
                                    imageUrl: cat.imageUrl!,
                                    fit: BoxFit.contain,
                                    placeholder: CustomText(
                                      emoji,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                )
                              : CustomText(
                                  emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Removed _CategorySection since it's a flat structure now
