import 'package:flutter/foundation.dart';
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
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> addToWishlist(ProductEntity product) async {
    final previousState = state;
    if (!state.any((e) => e.id == product.id)) {
      state = [...state, product];
    }
    try {
      final items = await _repository.addToWishlist(product.id);
      state = items;
    } catch (e) {
      state = previousState;
      debugPrint('Error adding to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final previousState = state;
    state = state.where((e) => e.id != productId).toList();
    try {
      final items = await _repository.removeFromWishlist(productId);
      state = items;
    } catch (e) {
      state = previousState;
      debugPrint('Error removing from wishlist: $e');
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
