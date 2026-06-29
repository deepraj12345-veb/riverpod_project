import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/repositories/cart_repository.dart';

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
