import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/data/models/coupon_model.dart';

abstract class CouponRemoteDataSource {
  Future<List<CouponModel>> getCoupons();
}

class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final Dio dio;

  CouponRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CouponModel>> getCoupons() async {
    try {
      final response = await dio.get(ApiConfig.coupons);
      final raw = response.data;

      final List<dynamic> list =
          raw is Map<String, dynamic> &&
                  raw.containsKey('data') &&
                  raw['data'] is List
              ? raw['data'] as List<dynamic>
              : (raw is List ? raw : []);

      return list
          .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
