import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/data/datasources/category_remote_data_source.dart';
import 'package:veggie_mart/data/repositories/category_repository_impl.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/domain/entities/subcategory_entity.dart';
import 'package:veggie_mart/domain/repositories/category_repository.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/domain/entities/hierarchy_category_type_entity.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
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

final subcategoriesProvider = FutureProvider<List<SubcategoryEntity>>((
  ref,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getSubcategories();
});

// Family provider: get subcategories filtered by a parent category's ID
final subcategoriesByCategoryProvider =
    FutureProvider.family<List<SubcategoryEntity>, String>((
      ref,
      categoryId,
    ) async {
      final repository = ref.watch(categoryRepositoryProvider);
      return await repository.getSubcategories(categoryId: categoryId);
    });

final categoryTypesProvider = FutureProvider<List<HierarchyCategoryTypeEntity>>(
  (ref) async {
    final dio = ref.watch(dioClientProvider);
    final response = await dio.get(ApiConfig.hierarchyCategoryTypes);
    final data = response.data['data'] as List;
    return data.map((e) {
      final cats = (e['categories'] as List? ?? [])
          .map(
            (c) => CategoryEntity(
              id: c['_id'] ?? '',
              name: c['name'] ?? '',
              imageUrl: c['image'],
              typeId: c['cat_type_id'],
            ),
          )
          .toList();
      return HierarchyCategoryTypeEntity(
        id: e['_id'] ?? '',
        name: e['name'] ?? '',
        imageUrl: e['image'],
        categories: cats,
      );
    }).toList();
  },
);
