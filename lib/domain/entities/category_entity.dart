import 'package:veggie_mart/domain/entities/product_entity.dart';

class CategoryEntity {
  final String id;
  final String name;
  final String? typeId;
  final String? imageUrl;
  final List<ProductEntity>? products;

  CategoryEntity({
    required this.id,
    required this.name,
    this.typeId,
    this.imageUrl,
    this.products,
  });
}
