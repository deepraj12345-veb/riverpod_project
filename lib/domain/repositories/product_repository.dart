import 'package:veg_king/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<void> toggleFavorite(String productId);
}
