import 'package:veg_king/data/datasources/category_remote_data_source.dart';
import 'package:veg_king/domain/entities/category_entity.dart';
import 'package:veg_king/domain/entities/subcategory_entity.dart';
import 'package:veg_king/domain/repositories/category_repository.dart';

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
