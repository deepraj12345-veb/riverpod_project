import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/data/models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await dio.get(ApiConfig.dashboard);
      final raw = response.data;

      // Handle wrapper: { data: {...} } or { success: true, data: {...} }
      final Map<String, dynamic> json =
          raw is Map<String, dynamic> && raw.containsKey('data') && raw['data'] is Map
              ? raw['data'] as Map<String, dynamic>
              : raw as Map<String, dynamic>;

      return DashboardModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
