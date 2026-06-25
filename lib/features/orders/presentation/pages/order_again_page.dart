import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/data/fake_data.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/product_card_widget.dart';
import 'package:veggie_mart/features/home/presentation/controllers/home_controller.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';

class OrderAgainPage extends ConsumerWidget {
  const OrderAgainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(productsProvider);
    final ordered = allProducts
        .where((p) => FakeData.orderedProductIds.contains(p.id))
        .toList();


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              'Order Again',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            CustomText(
              '${ordered.length} previously ordered items',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
            ),
          ],
        ),
      ),
      body: ordered.isEmpty
          ? const _EmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.48,
              ),
              itemCount: ordered.length,
              itemBuilder: (ctx, i) => ProductCardWidget(product: ordered[i]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppTheme.cardMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 50,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const CustomText(
            'No orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const CustomText(
            'Your past orders will appear here',
            style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}

