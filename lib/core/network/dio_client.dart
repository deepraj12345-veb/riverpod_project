import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Connected to VegiMart backend
  dio.options.baseUrl = ApiConfig.baseUrl;
  dio.options.connectTimeout = const Duration(milliseconds: ApiConfig.connectTimeout);
  dio.options.receiveTimeout = const Duration(milliseconds: ApiConfig.receiveTimeout);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Auth Token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors here (e.g. 401 Unauthorized for logging out user)
        return handler.next(e);
      },
    ),
  );

  // Log interceptor for debugging (pretty formatting)
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ),
  );

  return dio;
});
