import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() {
    return repository.getProducts();
  }
}
