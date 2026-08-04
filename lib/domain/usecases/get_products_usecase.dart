import 'package:veg_king/domain/entities/product_entity.dart';
import 'package:veg_king/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() {
    return repository.getProducts();
  }
}
