import 'package:riverpod_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<List<CartItemEntity>> addToCart(ProductEntity product);
  Future<List<CartItemEntity>> removeFromCart(String productId);
  Future<List<CartItemEntity>> incrementQuantity(String productId);
  Future<List<CartItemEntity>> decrementQuantity(String productId);
  Future<List<CartItemEntity>> clearCart();
}
