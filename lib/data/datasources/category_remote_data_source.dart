import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/data/models/category_model.dart';
import 'package:veggie_mart/data/models/subcategory_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<SubcategoryModel>> getSubcategories({String? categoryId});
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get(
        ApiConfig.categories,
        queryParameters: {'limit': 100},
      );
      final raw = response.data;
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        // Try common wrapper keys
        list = (raw['data'] ?? raw['categories'] ?? raw['results'] ?? []) as List;
      } else {
        list = [];
      }
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<SubcategoryModel>> getSubcategories({String? categoryId}) async {
    try {
      final params = <String, dynamic>{'limit': 200};
      if (categoryId != null) params['category_id'] = categoryId;

      final response = await dio.get(
        ApiConfig.subcategories,
        queryParameters: params,
      );
      final raw = response.data;
      List<dynamic> list;
      if (raw is List) {
        list = raw;
      } else if (raw is Map) {
        list = (raw['data'] ?? raw['subcategories'] ?? raw['results'] ?? []) as List;
      } else {
        list = [];
      }
      return list.map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
