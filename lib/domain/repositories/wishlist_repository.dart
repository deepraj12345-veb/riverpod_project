import 'package:veggie_mart/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  Future<List<ProductEntity>> getWishlist();
  Future<List<ProductEntity>> addToWishlist(String productId);
  Future<List<ProductEntity>> removeFromWishlist(String productId);
}
