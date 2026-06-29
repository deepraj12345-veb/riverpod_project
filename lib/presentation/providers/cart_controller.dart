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
  final AddToCartUseCase _addToCartUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final UpdateQuantityUseCase _updateQuantityUseCase;
  final ClearCartUseCase _clearCartUseCase;

  CartNotifier({
    required AddToCartUseCase addToCartUseCase,
    required RemoveFromCartUseCase removeFromCartUseCase,
    required UpdateQuantityUseCase updateQuantityUseCase,
    required ClearCartUseCase clearCartUseCase,
  }) : _addToCartUseCase = addToCartUseCase,
       _removeFromCartUseCase = removeFromCartUseCase,
       _updateQuantityUseCase = updateQuantityUseCase,
       _clearCartUseCase = clearCartUseCase,
       super([]);

  Future<void> addToCart(ProductEntity product) async {
    state = await _addToCartUseCase.execute(product);
  }

  Future<void> removeFromCart(String productId) async {
    state = await _removeFromCartUseCase.execute(productId);
  }

  Future<void> incrementQuantity(String productId) async {
    state = await _updateQuantityUseCase.execute(productId, true);
  }

  Future<void> decrementQuantity(String productId) async {
    state = await _updateQuantityUseCase.execute(productId, false);
  }

  Future<void> clearCart() async {
    state = await _clearCartUseCase.execute();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemEntity>>((
  ref,
) {
  return CartNotifier(
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
