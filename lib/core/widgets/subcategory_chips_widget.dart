import 'package:flutter/material.dart';
import 'package:veg_king/core/theme/app_theme.dart';
import 'package:veg_king/core/widgets/custom_text.dart';
import 'package:veg_king/domain/entities/category_entity.dart';
import 'package:veg_king/core/widgets/custom_network_image.dart';

class SubcategoryChipsWidget extends StatelessWidget {
  final List<CategoryEntity> subcategories;
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

  static String _getEmoji(String sub) {
    if (_emojiMap.containsKey(sub)) return _emojiMap[sub]!;
    
    final lower = sub.toLowerCase();
    if (lower.contains('exotic')) return '🥑';
    if (lower.contains('leaf')) return '🥬';
    if (lower.contains('vegetable') || lower.contains('veg')) return '🥦';
    if (lower.contains('fruit')) return '🍎';
    if (lower.contains('dairy') || lower.contains('milk')) return '🥛';
    if (lower.contains('snack')) return '🍿';
    if (lower.contains('grocery') || lower.contains('groceries')) return '🛒';
    if (lower.contains('meat') || lower.contains('chicken')) return '🍗';
    if (lower.contains('fish') || lower.contains('seafood')) return '🐟';
    if (lower.contains('spice') || lower.contains('masala')) return '🌶️';
    if (lower.contains('drink') || lower.contains('beverage')) return '🥤';
    if (lower.contains('sweet') || lower.contains('dessert')) return '🍩';
    if (lower.contains('bakery') || lower.contains('bread')) return '🍞';
    if (lower.contains('care') || lower.contains('personal')) return '🧴';
    if (lower.contains('clean')) return '🧹';
    if (lower.contains('baby')) return '👶';
    if (lower.contains('pet')) return '🐾';
    if (lower.contains('oil')) return '🫙';
    if (lower.contains('dal') || lower.contains('pulse')) return '🥣';
    if (lower.contains('rice')) return '🍚';
    if (lower.contains('herb')) return '🌿';
    
    return '🏷️';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subcategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final subCat = subcategories[i];
          final sub = subCat.name;
          final isSelected = sub == selected;
          final emoji = _getEmoji(sub);
          final hasImage = subCat.imageUrl != null && subCat.imageUrl!.isNotEmpty;

          return GestureDetector(
            onTap: () => onSelect(isSelected ? '' : sub),
            child: SizedBox(
              width: 76,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppTheme.primaryGreen, width: 2)
                          : Border.all(color: AppTheme.borderColor, width: 1),
                    ),
                    child: Center(
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: CustomNetworkImage(
                                  imageUrl: subCat.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: CustomText(emoji, style: const TextStyle(fontSize: 28)),
                                  errorWidget: CustomText(emoji, style: const TextStyle(fontSize: 28)),
                                ),
                              ),
                            )
                          : CustomText(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomText(
                    sub,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
                      height: 1.1,
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
