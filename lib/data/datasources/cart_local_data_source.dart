import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

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

  List<CartItemEntity> _merge(List<CartItemEntity> items) {
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

  @override
  Future<List<CartItemEntity>> getItems() async {
    final merged = _merge(_cartItems);
    _cartItems.clear();
    _cartItems.addAll(merged);
    return List.unmodifiable(_cartItems);
  }

  @override
  Future<List<CartItemEntity>> addItem(ProductEntity product) async {
    final cleanName = product.name.toLowerCase().trim();
    final index = _cartItems.indexWhere(
      (item) => item.product.id == product.id || (item.product.name.isNotEmpty && item.product.name.toLowerCase().trim() == cleanName),
    );
    if (index == -1) {
      _cartItems.add(CartItemEntity(product: product, quantity: 1));
    } else {
      final current = _cartItems[index];
      if (current.quantity < 10) {
        _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
      }
    }
    final merged = _merge(_cartItems);
    _cartItems.clear();
    _cartItems.addAll(merged);
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
      if (current.quantity < 10) {
        _cartItems[index] = current.copyWith(quantity: current.quantity + 1);
      }
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
