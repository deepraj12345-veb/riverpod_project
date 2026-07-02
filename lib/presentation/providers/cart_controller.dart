import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/data/datasources/cart_local_data_source.dart';
import 'package:veggie_mart/data/repositories/cart_repository_impl.dart';
import 'package:veggie_mart/domain/repositories/cart_repository.dart';
import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/usecases/get_cart_items_usecase.dart';
import 'package:veggie_mart/domain/usecases/add_to_cart_usecase.dart';
import 'package:veggie_mart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:veggie_mart/domain/usecases/update_quantity_usecase.dart';
import 'package:veggie_mart/domain/usecases/clear_cart_usecase.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/data/datasources/cart_remote_data_source.dart';
import 'package:veggie_mart/core/network/dio_client.dart';

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

  Future<void> _loadCart() async {
    try {
      state = await _getCartItemsUseCase.execute();
    } catch (_) {}
  }

  Future<void> addToCart(ProductEntity product) async {
    // Optimistic update
    final existingIndex = state.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItemEntity(product: product, quantity: 1)];
    }

    try {
      state = await _addToCartUseCase.execute(product);
    } catch (_) {}
  }

  Future<void> removeFromCart(String productId) async {
    // Optimistic update
    state = state.where((item) => item.product.id != productId).toList();

    try {
      state = await _removeFromCartUseCase.execute(productId);
    } catch (_) {}
  }

  Future<void> incrementQuantity(String productId) async {
    // Optimistic update
    final existingIndex = state.indexWhere((i) => i.product.id == productId);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        item.copyWith(quantity: item.quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    }

    try {
      state = await _updateQuantityUseCase.execute(productId, true);
    } catch (_) {}
  }

  Future<void> decrementQuantity(String productId) async {
    // Optimistic update
    final existingIndex = state.indexWhere((i) => i.product.id == productId);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      if (item.quantity > 1) {
        state = [
          ...state.sublist(0, existingIndex),
          item.copyWith(quantity: item.quantity - 1),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = state.where((i) => i.product.id != productId).toList();
      }
    }

    try {
      state = await _updateQuantityUseCase.execute(productId, false);
    } catch (_) {}
  }

  Future<void> clearCart() async {
    state = [];
    try {
      state = await _clearCartUseCase.execute();
    } catch (_) {}
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
