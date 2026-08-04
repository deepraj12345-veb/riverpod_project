import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veg_king/core/network/api_config.dart';
import 'package:veg_king/core/network/dio_client.dart';
import 'package:veg_king/data/datasources/product_remote_data_source.dart';
import 'package:veg_king/data/models/product_model.dart';
import 'package:veg_king/data/repositories/product_repository_impl.dart';
import 'package:veg_king/domain/repositories/product_repository.dart';
import 'package:veg_king/domain/entities/product_entity.dart';
import 'package:veg_king/domain/usecases/get_products_usecase.dart';
import 'package:veg_king/domain/usecases/toggle_favorite_usecase.dart';

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

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductEntity>>((ref) {
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

// Live API search provider — calls /products?search=query
final searchedProductsProvider =
    FutureProvider.family<List<ProductEntity>, String>((ref, query) async {
      if (query.trim().isEmpty) return [];
      final dio = ref.watch(dioClientProvider);
      final response = await dio.get(
        ApiConfig.products,
        queryParameters: {'search': query.trim(), 'page': 1, 'limit': 20},
      );
      final raw = response.data;
      final List list = raw is Map && raw.containsKey('data')
          ? (raw['data'] is List
                ? raw['data'] as List
                : (raw['data']['products'] ?? []) as List)
          : (raw is List ? raw : []);
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
