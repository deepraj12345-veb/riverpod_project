import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:veggie_mart/presentation/providers/category_provider.dart';
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
    final categoryTypesAsync = ref.watch(categoryTypesProvider);

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
      body: categoryTypesAsync.when(
        loading: () => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (ctx, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: 6,
                    itemBuilder: (ctx, i) {
                      return Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 60,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (categoryTypes) {
          if (categoryTypes.isEmpty) {
            return const Center(child: Text("No categories found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categoryTypes.length,
            itemBuilder: (ctx, index) {
              final type = categoryTypes[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomText(
                      type.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: type.categories.length,
                    itemBuilder: (ctx, i) {
                      final cat = type.categories[i];
                      final emoji = _subEmoji[cat.name] ?? '📦';

                      return GestureDetector(
                        onTap: () =>
                            context.push('/subcategory', extra: cat.name),
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child:
                                    cat.imageUrl != null &&
                                        cat.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CustomNetworkImage(
                                          imageUrl: cat.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: Center(
                                            child: CustomText(
                                              emoji,
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: CustomText(
                                          emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            CustomText(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
