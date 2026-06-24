import 'package:riverpod_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:riverpod_project/features/cart/domain/repository/cart_repository.dart';

class UpdateQuantityUseCase {
  final CartRepository repository;

  UpdateQuantityUseCase(this.repository);

  Future<List<CartItemEntity>> execute(String productId, bool increment) {
    if (increment) {
      return repository.incrementQuantity(productId);
    } else {
      return repository.decrementQuantity(productId);
    }
  }
}
