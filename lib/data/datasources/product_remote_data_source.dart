import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/data/models/product_model.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductEntity>> fetchProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio _dio;

  ProductRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  @override
  Future<List<ProductEntity>> fetchProducts() async {
    try {
      final response = await _dio.get('/products', queryParameters: {'limit': 100});
      final raw = response.data;
      final List<dynamic> data = raw is Map<String, dynamic> && raw.containsKey('data') 
          ? raw['data'] as List<dynamic> 
          : raw as List<dynamic>;
      
      return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
