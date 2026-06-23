import 'package:riverpod_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:riverpod_project/features/cart/domain/repository/cart_repository.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<List<CartItemEntity>> execute(ProductEntity product) {
    return repository.addToCart(product);
  }
}
