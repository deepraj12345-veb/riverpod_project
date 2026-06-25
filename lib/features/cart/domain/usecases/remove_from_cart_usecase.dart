import 'package:veggie_mart/features/cart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/features/cart/domain/repository/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<List<CartItemEntity>> execute(String productId) {
    return repository.removeFromCart(productId);
  }
}

