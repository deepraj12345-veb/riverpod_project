import 'package:veg_king/domain/repositories/product_repository.dart';

class ToggleFavoriteUseCase {
  final ProductRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> execute(String productId) {
    return repository.toggleFavorite(productId);
  }
}
