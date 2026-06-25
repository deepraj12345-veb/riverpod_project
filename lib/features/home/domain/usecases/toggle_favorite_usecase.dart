import 'package:veggie_mart/features/home/domain/repository/product_repository.dart';

class ToggleFavoriteUseCase {
  final ProductRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> execute(String productId) {
    return repository.toggleFavorite(productId);
  }
}

