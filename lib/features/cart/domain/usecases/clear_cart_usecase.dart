import 'package:riverpod_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:riverpod_project/features/cart/domain/repository/cart_repository.dart';

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<List<CartItemEntity>> execute() {
    return repository.clearCart();
  }
}
