import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veg_king/data/datasources/cart_local_data_source.dart';
import 'package:veg_king/data/repositories/cart_repository_impl.dart';
import 'package:veg_king/domain/repositories/cart_repository.dart';
import 'package:veg_king/domain/entities/cart_item_entity.dart';
import 'package:veg_king/domain/usecases/get_cart_items_usecase.dart';
import 'package:veg_king/domain/usecases/add_to_cart_usecase.dart';
import 'package:veg_king/domain/usecases/remove_from_cart_usecase.dart';
import 'package:veg_king/domain/usecases/update_quantity_usecase.dart';
import 'package:veg_king/domain/usecases/clear_cart_usecase.dart';
import 'package:veg_king/domain/entities/product_entity.dart';
import 'package:veg_king/data/datasources/cart_remote_data_source.dart';
import 'package:veg_king/core/network/dio_client.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localDataSource: CartLocalDataSourceImpl(),
    remoteDataSource: CartRemoteDataSourceImpl(dio: ref.watch(dioClientProvider)),
  );
});

final getCartItemsUseCaseProvider = Provider<GetCartItemsUseCase>((ref) {
  return GetCartItemsUseCase(ref.watch(cartRepositoryProvider));
});

final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.watch(cartRepositoryProvider));
});

final removeFromCartUseCaseProvider = Provider<RemoveFromCartUseCase>((ref) {
  return RemoveFromCartUseCase(ref.watch(cartRepositoryProvider));
});

final updateQuantityUseCaseProvider = Provider<UpdateQuantityUseCase>((ref) {
  return UpdateQuantityUseCase(ref.watch(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.watch(cartRepositoryProvider));
});

class CartNotifier extends StateNotifier<List<CartItemEntity>> {
  final GetCartItemsUseCase _getCartItemsUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final UpdateQuantityUseCase _updateQuantityUseCase;
  final ClearCartUseCase _clearCartUseCase;

  CartNotifier({
    required GetCartItemsUseCase getCartItemsUseCase,
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required UpdateQuantityUseCase updateQuantityUseCase,
    required ClearCartUseCase clearCartUseCase,
  }) : _getCartItemsUseCase = getCartItemsUseCase,
       _addToCartUseCase = addToCartUseCase,
       _removeFromCartUseCase = removeFromCartUseCase,
       _updateQuantityUseCase = updateQuantityUseCase,
       _clearCartUseCase = clearCartUseCase,
       super([]) {
    _loadCart();
  }

  bool _isSameProduct(CartItemEntity item, String idOrName) {
    final clean = idOrName.toLowerCase().trim();
    return item.product.id == idOrName ||
        (item.product.name.isNotEmpty &&
            item.product.name.toLowerCase().trim() == clean);
  }

  List<CartItemEntity> _mergeDuplicates(List<CartItemEntity> items) {
    final Map<String, CartItemEntity> merged = {};
    for (final item in items) {
      final key = item.product.name.toLowerCase().trim().isNotEmpty
          ? item.product.name.toLowerCase().trim()
          : item.product.id;
      if (merged.containsKey(key)) {
        final existing = merged[key]!;
        final newQty = existing.quantity + item.quantity;
        merged[key] = existing.copyWith(
          quantity: newQty > 10 ? 10 : newQty,
        );
      } else {
        merged[key] = item.quantity > 10
            ? item.copyWith(quantity: 10)
            : item;
      }
    }
    return merged.values.toList();
  }

  Future<void> _loadCart() async {
    try {
      final items = await _getCartItemsUseCase.execute();
      state = _mergeDuplicates(items);
    } catch (_) {}
  }

  Future<void> addToCart(ProductEntity product) async {
    // Instant optimistic update
    final existingIndex = state.indexWhere(
      (i) => _isSameProduct(i, product.id) || _isSameProduct(i, product.name),
    );
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      if (item.quantity >= 10) return; // Maximum 10 limit enforced
      state = [
        ...state.sublist(0, existingIndex),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [
        ...state,
        CartItemEntity(product: product, quantity: 1),
      ];
    }
    state = _mergeDuplicates(state);

    // Background backend sync
    _addToCartUseCase.execute(product).catchError((_) => state);
  }

  Future<void> removeFromCart(String productId) async {
    // Instant optimistic update
    state = state.where((item) => !_isSameProduct(item, productId)).toList();
    state = _mergeDuplicates(state);

    // Background backend sync
    _removeFromCartUseCase.execute(productId).catchError((_) => state);
  }

  Future<void> incrementQuantity(String productId) async {
    // Instant optimistic update
    final existingIndex = state.indexWhere((i) => _isSameProduct(i, productId));
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      if (item.quantity >= 10) return; // Maximum 10 limit enforced
      state = [
        ...state.sublist(0, existingIndex),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    }
    state = _mergeDuplicates(state);

    // Background backend sync
    _updateQuantityUseCase.execute(productId, true).catchError((_) => state);
  }

  Future<void> decrementQuantity(String productId) async {
    // Instant optimistic update
    final existingIndex = state.indexWhere((i) => _isSameProduct(i, productId));
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      if (item.quantity > 1) {
        state = [
          ...state.sublist(0, existingIndex),
          item.copyWith(quantity: item.quantity - 1),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = state.where((i) => !_isSameProduct(i, productId)).toList();
      }
    }
    state = _mergeDuplicates(state);

    // Background backend sync
    _updateQuantityUseCase.execute(productId, false).catchError((_) => state);
  }

  Future<void> clearCart() async {
    state = [];
    _clearCartUseCase.execute().catchError((_) => state);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemEntity>>((
  ref,
) {
  return CartNotifier(
    getCartItemsUseCase: ref.watch(getCartItemsUseCaseProvider),
    addToCartUseCase: ref.watch(addToCartUseCaseProvider),
    removeFromCartUseCase: ref.watch(removeFromCartUseCaseProvider),
    updateQuantityUseCase: ref.watch(updateQuantityUseCaseProvider),
    clearCartUseCase: ref.watch(clearCartUseCaseProvider),
  );
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});
