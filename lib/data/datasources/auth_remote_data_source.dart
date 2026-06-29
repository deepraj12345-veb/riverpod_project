import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/core/network/api_config.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String mobileNo);
  Future<Map<String, dynamic>> verifyOtp(
    String mobileNo,
    String otp,
    String name,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> sendOtp(String mobileNo) async {
    try {
      await dio.post(ApiConfig.sendOtp, data: {'mobile_no': mobileNo});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
    String mobileNo,
    String otp,
    String name,
  ) async {
    try {
      final response = await dio.post(
        ApiConfig.verifyOtp,
        data: {'mobile_no': mobileNo, 'otp': otp, 'name': name},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
