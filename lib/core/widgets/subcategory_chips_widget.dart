import 'package:flutter/material.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class SubcategoryChipsWidget extends StatelessWidget {
  final List<String> subcategories;
  final String selected;
  final ValueChanged<String> onSelect;

  const SubcategoryChipsWidget({
    super.key,
    required this.subcategories,
    required this.selected,
    required this.onSelect,
  });

  static const Map<String, String> _emojiMap = {
    // All
    'Organic': '🌿',
    'On Sale': '🔥',
    'Fresh Today': '🌱',
    'Local Farms': '🏡',
    'Superfoods': '💪',
    'Bestsellers': '⭐',
    'New Arrivals': '🆕',
    'Premium': '👑',
    // Fruits
    'Berries & Other': '🍇',
    'Tropical Fruits': '🥭',
    // Vegetables
    'Roots, Herbs & Other': '🥕',
    'Basic Vegetables': '🥦',
    // Groceries
    'Atta, Rice, Dal & More': '🌾',
    'Cold Drink, Energy Drinks & Juice': '🥤',
    'Tea, Coffee, Milk Drinks': '☕',
    'Dairy Product, Cheese & Eggs': '🥛',
    'Pharma & Wellness': '💊',
    'Snacks, Munchies, Ice-Creams & Sweets': '🍿',
    'Breakfast & Instant Food': '🍳',
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
    'Papad, Fryums & More': '🥘',
    'Gifts': '🎁',
    'Electronics': '📱',
    // Dairy
    'Milk': '🥛',
    'Cheese': '🧀',
    'Curd & Yoghurt': '🍦',
    'Butter & Cream': '🧈',
    // Snacks
    'Chips': '🥔',
    'Cookies': '🍪',
    'Nuts & Dry Fruits': '🥜',
    'Chocolates': '🍫',
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subcategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final sub = subcategories[i];
          final isSelected = sub == selected;
          final emoji = _emojiMap[sub] ?? '🏷️';

          return GestureDetector(
            onTap: () => onSelect(isSelected ? '' : sub),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : AppTheme.borderColor,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  CustomText(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
