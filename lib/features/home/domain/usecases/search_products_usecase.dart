import 'package:veggie_mart/features/home/domain/entities/product_entity.dart';

class SearchProductsUseCase {
  Future<List<ProductEntity>> execute(List<ProductEntity> products, String query) async {
    if (query.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.category.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}

