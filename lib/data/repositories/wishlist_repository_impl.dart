import 'package:veggie_mart/data/datasources/wishlist_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getWishlist() {
    return remoteDataSource.getWishlist();
  }

  @override
  Future<List<ProductEntity>> addToWishlist(String productId) {
    return remoteDataSource.addToWishlist(productId);
  }

  @override
  Future<List<ProductEntity>> removeFromWishlist(String productId) {
    return remoteDataSource.removeFromWishlist(productId);
  }
}
