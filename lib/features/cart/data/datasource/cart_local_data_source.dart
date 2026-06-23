import 'package:riverpod_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemEntity>> getItems();
  Future<List<CartItemEntity>> addItem(ProductEntity product);
  Future<List<CartItemEntity>> removeItem(String productId);
  Future<List<CartItemEntity>> incrementQty(String productId);
  Future<List<CartItemEntity>> decrementQty(String productId);
  Future<List<CartItemEntity>> clear();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final List<CartItemEntity> _cartItems = [];

  @override
  Future<List<CartItemEntity>> getItems() async {
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<List<CartItemEntity>> addItem(ProductEntity product) async {
    final index = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _cartItems.add(CartItemEntity(product: product, quantity: 1));
    } else {
      final current = _cartItems[index];
      _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
    }
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<List<CartItemEntity>> removeItem(String productId) async {
    _cartItems.removeWhere((item) => item.product.id == productId);
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<List<CartItemEntity>> incrementQty(String productId) async {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      final current = _cartItems[index];
      _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
    }
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<List<CartItemEntity>> decrementQty(String productId) async {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      final current = _cartItems[index];
      if (current.quantity <= 1) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = current.copyWith(quantity: current.quantity - 1);
      }
    }
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<List<CartItemEntity>> clear() async {
    _cartItems.clear();
    return List.unmodifiable(_cartItems);
  }
}
