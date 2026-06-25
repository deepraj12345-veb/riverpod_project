import 'package:veggie_mart/features/cart/data/datasource/cart_local_data_source.dart';
import 'package:veggie_mart/features/cart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/features/cart/domain/repository/cart_repository.dart';
import 'package:veggie_mart/features/home/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItemEntity>> getCartItems() {
    return localDataSource.getItems();
  }

  @override
  Future<List<CartItemEntity>> addToCart(ProductEntity product) {
    return localDataSource.addItem(product);
  }

  @override
  Future<List<CartItemEntity>> removeFromCart(String productId) {
    return localDataSource.removeItem(productId);
  }

  @override
  Future<List<CartItemEntity>> incrementQuantity(String productId) {
    return localDataSource.incrementQty(productId);
  }

  @override
  Future<List<CartItemEntity>> decrementQuantity(String productId) {
    return localDataSource.decrementQty(productId);
  }

  @override
  Future<List<CartItemEntity>> clearCart() {
    return localDataSource.clear();
  }
}

