import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/domain/entities/subcategory_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<SubcategoryEntity>> getSubcategories({String? categoryId});
}
