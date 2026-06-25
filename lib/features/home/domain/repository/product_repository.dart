import 'package:veggie_mart/features/home/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<void> toggleFavorite(String productId);
}

