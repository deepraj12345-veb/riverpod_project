import 'package:veggie_mart/features/home/domain/entities/product_entity.dart';
import 'package:veggie_mart/features/home/domain/repository/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() {
    return repository.getProducts();
  }
}

