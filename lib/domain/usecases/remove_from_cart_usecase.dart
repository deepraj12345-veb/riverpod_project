import 'package:veg_king/domain/entities/cart_item_entity.dart';
import 'package:veg_king/domain/repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  Future<List<CartItemEntity>> execute(String productId) {
    return repository.removeFromCart(productId);
  }
}
