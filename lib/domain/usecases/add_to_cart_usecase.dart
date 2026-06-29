import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/repositories/cart_repository.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<List<CartItemEntity>> execute(ProductEntity product) {
    return repository.addToCart(product);
  }
}
