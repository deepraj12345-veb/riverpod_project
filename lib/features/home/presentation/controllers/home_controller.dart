import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/features/home/data/datasource/product_remote_data_source.dart';
import 'package:riverpod_project/features/home/data/repository/product_repository_impl.dart';
import 'package:riverpod_project/features/home/domain/repository/product_repository.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';
import 'package:riverpod_project/features/home/domain/usecases/get_products_usecase.dart';
import 'package:riverpod_project/features/home/domain/usecases/toggle_favorite_usecase.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(remoteDataSource: ProductRemoteDataSourceImpl());
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(productRepositoryProvider));
});

class ProductsNotifier extends StateNotifier<List<ProductEntity>> {
  final GetProductsUseCase _getProductsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  ProductsNotifier({
    required GetProductsUseCase getProductsUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
  }) : _getProductsUseCase = getProductsUseCase,
       _toggleFavoriteUseCase = toggleFavoriteUseCase,
       super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    final products = await _getProductsUseCase.execute();
    state = List.from(products);
  }

  Future<void> toggleFavorite(String productId) async {
    await _toggleFavoriteUseCase.execute(productId);
    final products = await _getProductsUseCase.execute();
    state = List.from(products);
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<ProductEntity>>((ref) {
  return ProductsNotifier(
    getProductsUseCase: ref.watch(getProductsUseCaseProvider),
    toggleFavoriteUseCase: ref.watch(toggleFavoriteUseCaseProvider),
  );
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

final filteredProductsProvider = Provider<List<ProductEntity>>((ref) {
  final products = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (category == 'All') return products;
  return products.where((p) => p.category == category).toList();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedProductsProvider = Provider<List<ProductEntity>>((ref) {
  final products = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return products;
  return products
      .where(
        (p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();
});
