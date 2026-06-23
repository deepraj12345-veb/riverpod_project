import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';
import 'package:riverpod_project/features/home/domain/repository/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<ProductEntity>> execute() {
    return repository.getProducts();
  }
}
