import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_project/core/data/fake_data.dart';
import 'package:riverpod_project/core/theme/app_theme.dart';
import 'package:riverpod_project/features/home/presentation/controllers/home_controller.dart';

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
    final categories = FakeData.categories.where((c) => c != 'All').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
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
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const Divider(height: 36, color: AppTheme.borderColor),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final subs = FakeData.subcategories[cat] ?? [];
          final color = _catColor[cat] ?? AppTheme.cardMint;
          return _CategorySection(
            category: cat,
            subcategories: subs,
            color: color,
            subEmojiMap: _subEmoji,
            onSeeAll: () {
              ref.read(selectedCategoryProvider.notifier).state = cat;
              context.go('/home');
            },
            onSubTap: (_) {
              ref.read(selectedCategoryProvider.notifier).state = cat;
              context.go('/home');
            },
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<String> subcategories;
  final Color color;
  final Map<String, String> subEmojiMap;
  final VoidCallback onSeeAll;
  final ValueChanged<String> onSubTap;

  const _CategorySection({
    required this.category,
    required this.subcategories,
    required this.color,
    required this.subEmojiMap,
    required this.onSeeAll,
    required this.onSubTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show max 8 subcategories, link to see all if more
    final visible = subcategories.length > 8
        ? subcategories.sublist(0, 8)
        : subcategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See all →',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: visible.length,
          itemBuilder: (ctx, i) {
            final sub = visible[i];
            final emoji = subEmojiMap[sub] ?? '📦';
            return GestureDetector(
              onTap: () => onSubTap(sub),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: color.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sub,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textDark,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (subcategories.length > 8) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onSeeAll,
            child: Center(
              child: Text(
                'View all ${subcategories.length} subcategories →',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
