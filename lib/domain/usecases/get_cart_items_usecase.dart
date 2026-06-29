import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/repositories/cart_repository.dart';

class GetCartItemsUseCase {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  Future<List<CartItemEntity>> execute() {
    return repository.getCartItems();
  }
}
