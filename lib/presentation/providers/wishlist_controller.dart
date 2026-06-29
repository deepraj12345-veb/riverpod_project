import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/domain/repositories/wishlist_repository.dart';
import 'package:veggie_mart/data/repositories/wishlist_repository_impl.dart';
import 'package:veggie_mart/data/datasources/wishlist_remote_data_source.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(
    remoteDataSource: WishlistRemoteDataSourceImpl(dio: ref.watch(dioClientProvider)),
  );
});

class WishlistNotifier extends StateNotifier<List<ProductEntity>> {
  final WishlistRepository _repository;

  WishlistNotifier(this._repository) : super([]) {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    try {
      final items = await _repository.getWishlist();
      state = items;
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> addToWishlist(ProductEntity product) async {
    try {
      final items = await _repository.addToWishlist(product.id);
      state = items;
    } catch (e) {
      print('Error adding to wishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      final items = await _repository.removeFromWishlist(productId);
      state = items;
    } catch (e) {
      print('Error removing from wishlist: $e');
      rethrow;
    }
  }

  bool isInWishlist(String productId) {
    return state.any((element) => element.id == productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<ProductEntity>>(
  (ref) {
    return WishlistNotifier(ref.watch(wishlistRepositoryProvider));
  },
);
