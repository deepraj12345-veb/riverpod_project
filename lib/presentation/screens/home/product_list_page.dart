import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veg_king/core/theme/app_theme.dart';
import 'package:veg_king/core/widgets/custom_text.dart';
import 'package:veg_king/core/widgets/product_card_widget.dart';
import 'package:veg_king/core/widgets/floating_cart_bar.dart';
import 'package:veg_king/domain/entities/product_entity.dart';
import 'package:veg_king/l10n/app_localizations.dart';

class ProductListPage extends ConsumerWidget {
  final String title;
  final List<ProductEntity> products;

  const ProductListPage({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenW = MediaQuery.of(context).size.width;
    // 3 columns layout matching the search page
    final cardW = (screenW - 16 - 16 - 8 - 8) / 3;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppTheme.textDark,
          ),
          onPressed: () => context.pop(),
        ),
        title: CustomText(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                CustomText(
                  AppLocalizations.of(context)!.itemsCount(products.length),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inbox_rounded,
                            size: 40,
                            color: AppTheme.textGrey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          AppLocalizations.of(context)!.noProductsFound,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      100,
                    ), // padding for FloatingCartBar
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: cardW / (cardW / 0.82 + 108.0),
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) =>
                        ProductCardWidget(product: products[i]),
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: FloatingCartBar(),
      ),
    );
  }
}
