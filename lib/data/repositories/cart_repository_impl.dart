import 'package:veggie_mart/data/datasources/cart_local_data_source.dart';
import 'package:veggie_mart/data/datasources/cart_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/repositories/cart_repository.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    try {
      final items = await remoteDataSource.getCart();
      return items;
    } catch (e) {
      // Fallback to local data source if remote fails
      return localDataSource.getItems();
    }
  }

  @override
  Future<List<CartItemEntity>> addToCart(ProductEntity product) async {
    try {
      return await remoteDataSource.toggleCartItem(product.id, 'add');
    } catch (e) {
      return await localDataSource.addItem(product);
    }
  }

  @override
  Future<List<CartItemEntity>> removeFromCart(String productId) async {
    try {
      return await remoteDataSource.toggleCartItem(productId, 'remove');
    } catch (e) {
      return await localDataSource.removeItem(productId);
    }
  }

  @override
  Future<List<CartItemEntity>> incrementQuantity(String productId) async {
    try {
      return await remoteDataSource.toggleCartItem(productId, 'add');
    } catch (e) {
      return await localDataSource.incrementQty(productId);
    }
  }

  @override
  Future<List<CartItemEntity>> decrementQuantity(String productId) async {
    try {
      return await remoteDataSource.toggleCartItem(productId, 'remove');
    } catch (e) {
      return await localDataSource.decrementQty(productId);
    }
  }

  @override
  Future<List<CartItemEntity>> clearCart() async {
    try {
      return await remoteDataSource.clearCart();
    } catch (e) {
      return await localDataSource.clear();
    }
  }
}
