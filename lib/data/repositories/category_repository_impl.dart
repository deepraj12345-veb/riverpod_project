import 'package:veggie_mart/data/datasources/category_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/domain/entities/subcategory_entity.dart';
import 'package:veggie_mart/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<List<SubcategoryEntity>> getSubcategories({String? categoryId}) async {
    return await remoteDataSource.getSubcategories(categoryId: categoryId);
  }
}
