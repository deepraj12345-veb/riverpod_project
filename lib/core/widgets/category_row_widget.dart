import 'package:flutter/material.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class CategoryRowWidget extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const CategoryRowWidget({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  String _getEmojiForCategory(String category) {
    if (category == 'All') return '🛒';

    final lower = category.toLowerCase();
    if (lower.contains('veg')) return '🥦';
    if (lower.contains('fruit')) return '🍎';
    if (lower.contains('dair') || lower.contains('milk')) return '🥛';
    if (lower.contains('groc')) return '🛍️';
    if (lower.contains('snack')) return '🍿';
    if (lower.contains('meat') || lower.contains('chicken')) return '🥩';
    if (lower.contains('bread') || lower.contains('bakery')) return '🍞';
    if (lower.contains('drink') || lower.contains('beverage')) return '🥤';

    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          final emoji = _getEmojiForCategory(cat);

          return GestureDetector(
            onTap: () => onSelect(cat),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.bgLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.borderColor,
                    ),
                  ),
                  child: Center(
                    child: CustomText(
                      emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                CustomText(
                  cat,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
