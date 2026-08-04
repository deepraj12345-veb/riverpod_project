import 'package:veg_king/domain/entities/cart_item_entity.dart';
import 'package:veg_king/domain/repositories/cart_repository.dart';

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<List<CartItemEntity>> execute() {
    return repository.clearCart();
  }
}
