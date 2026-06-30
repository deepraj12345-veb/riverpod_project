import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:veggie_mart/core/constants/fake_data.dart';
import 'package:veggie_mart/core/theme/app_theme.dart';
import 'package:veggie_mart/core/widgets/custom_text.dart';
import 'package:veggie_mart/core/widgets/product_card_widget.dart';
import 'package:veggie_mart/presentation/providers/home_controller.dart';
import 'package:veggie_mart/core/widgets/suggestion_field.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _searchCtrl;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(searchQueryProvider);
    _searchCtrl = TextEditingController(text: initialQuery);

    // Auto focus on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchedProducts = ref.watch(searchedProductsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final productSuggestions = FakeData.products.map((p) => p.name).toList()
      ..addAll(FakeData.categories.where((c) => c != 'All'))
      ..addAll(FakeData.products.expand((p) => p.tags).toSet());

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppTheme.textDark,
          ),
          onPressed: () {
            ref.read(searchQueryProvider.notifier).state = '';
            context.pop();
          },
        ),
        title: SuggestionField(
          controller: _searchCtrl,
          focusNode: _focusNode,
          label: '',
          hint: 'Search products, brands, tags...',
          icon: Icons.search_rounded,
          suggestions: productSuggestions,
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
          onSelected: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
        titleSpacing: 0,
        actions: const [SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          if (searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  CustomText(
                    'Results for "$searchQuery"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomText(
                      '${searchedProducts.length} items',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: searchQuery.isEmpty
                ? const _EmptySearchState()
                : searchedProducts.isEmpty
                ? const _NoResultsState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          ((MediaQuery.of(context).size.width - 44) / 2) /
                          (((MediaQuery.of(context).size.width - 44) / 2) /
                                  0.82 +
                              108.0),
                    ),
                    itemCount: searchedProducts.length,
                    itemBuilder: (ctx, i) {
                      return ProductCardWidget(product: searchedProducts[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 60,
            color: AppTheme.textGrey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const CustomText(
            'What are you looking for?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const CustomText(
            'Search for fresh veggies, fruits & more',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
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
              Icons.search_off_rounded,
              size: 40,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          const CustomText(
            'No products found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const CustomText(
            'Try checking for typos or searching a general term',
            style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }
}
