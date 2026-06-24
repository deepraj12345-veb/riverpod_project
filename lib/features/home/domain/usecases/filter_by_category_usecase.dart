import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';

class FilterByCategoryUseCase {
  Future<List<ProductEntity>> execute(List<ProductEntity> products, String category) async {
    if (category == 'All') return products;
    return products.where((p) => p.category == category).toList();
  }
}
