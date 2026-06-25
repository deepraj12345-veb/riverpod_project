import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/data/fake_data.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/product_card_widget.dart';
import 'package:veggie_mart/features/cart/presentation/controllers/cart_controller.dart';

class SubcategoryPage extends ConsumerStatefulWidget {
  final String categoryName;

  const SubcategoryPage({super.key, required this.categoryName});

  @override
  ConsumerState<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends ConsumerState<SubcategoryPage> {
  String selectedSub = 'All';

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
    final subcategories = FakeData.subcategories[widget.categoryName] ?? [];
    final allSubs = ['All', ...subcategories];

    // Filter products
    // Note: Since FakeData products don't have 'subcategory' explicitly,
    // we'll simulate filtering by checking tags or just show all if 'All'
    final categoryProducts = FakeData.products
        .where((p) => p.category == widget.categoryName)
        .toList();
    final displayedProducts = selectedSub == 'All'
        ? categoryProducts
        : categoryProducts
            .where((p) => p.tags.any((t) =>
                t.toLowerCase().contains(selectedSub.toLowerCase()) ||
                selectedSub.toLowerCase().contains(t.toLowerCase())))
            .toList();

    // If filtering by tags leaves 0 products for demo, just show all to avoid empty screen
    final finalProducts =
        displayedProducts.isEmpty ? categoryProducts : displayedProducts;

    final cartItems = ref.watch(cartProvider);
    final cartTotalItems =
        cartItems.fold(0, (sum, item) => sum + item.quantity);
    final cartTotalPrice = cartItems.fold(
        0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final cartTotalOriginalPrice = cartItems.fold(
        0.0, (sum, item) => sum + (item.product.originalPrice * item.quantity));
    final totalSavings = cartTotalOriginalPrice - cartTotalPrice;

    final screenW = MediaQuery.of(context).size.width;
    final contentW = screenW - 80; // 80 is sidebar width
    final cardWidth = (contentW - 32) /
        2; // 16 padding on each side, 2 columns -> no spacing in between if we use grid aspect ratio
    final listHeight = cardWidth / 0.48;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
        title: CustomText(
          widget.categoryName,
          style: const TextStyle(
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
                    border:
                        Border(right: BorderSide(color: AppTheme.borderColor)),
                  ),
                  child: ListView.builder(
                    itemCount: allSubs.length,
                    itemBuilder: (ctx, i) {
                      final sub = allSubs[i];
                      final isSelected = selectedSub == sub;
                      final emoji = _subEmoji[sub] ?? '📦';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedSub = sub;
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
                                        color: AppTheme.primaryGreen, width: 3))
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
                                          width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: CustomText(emoji,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: CustomText(
                                  sub,
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
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            0.56, // To match the ProductCardWidget aspect ratio
                      ),
                      itemCount: finalProducts.length,
                      itemBuilder: (ctx, i) {
                        return ProductCardWidget(product: finalProducts[i]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Cart Bar (if items in cart)
          if (cartTotalItems > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (totalSavings > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: 8),
                          CustomText(
                            'Saved ₹${totalSavings.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          CustomText(
                            '₹${cartTotalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(color: AppTheme.borderColor, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_cart_outlined,
                            color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            'Cart',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.textDark,
                            ),
                          ),
                          CustomText(
                            '$cartTotalItems items',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go('/cart'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF1E3A8A), // Navy blue from screenshot
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              CustomText(
                                'View Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

