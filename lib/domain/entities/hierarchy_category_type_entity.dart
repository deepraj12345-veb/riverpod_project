import 'package:veggie_mart/domain/entities/category_entity.dart';

class HierarchyCategoryTypeEntity {
  final String id;
  final String name;
  final String? imageUrl;
  final List<CategoryEntity> categories;

  HierarchyCategoryTypeEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.categories,
  });
}
