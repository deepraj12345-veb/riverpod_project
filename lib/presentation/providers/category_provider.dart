import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/data/datasources/category_remote_data_source.dart';
import 'package:veggie_mart/data/repositories/category_repository_impl.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/domain/entities/subcategory_entity.dart';
import 'package:veggie_mart/domain/repositories/category_repository.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return CategoryRemoteDataSourceImpl(dio: dio);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource: remoteDataSource);
});

final categoriesProvider = FutureProvider<List<CategoryEntity>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategories();
});

final subcategoriesProvider = FutureProvider<List<SubcategoryEntity>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getSubcategories();
});

// Family provider: get subcategories filtered by a parent category's ID
final subcategoriesByCategoryProvider =
    FutureProvider.family<List<SubcategoryEntity>, String>((ref, categoryId) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getSubcategories(categoryId: categoryId);
});
