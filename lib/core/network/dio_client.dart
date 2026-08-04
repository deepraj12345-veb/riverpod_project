import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veg_king/core/network/api_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Connected to VegiMart backend
  dio.options.baseUrl = ApiConfig.baseUrl;
  dio.options.connectTimeout = const Duration(
    milliseconds: ApiConfig.connectTimeout,
  );
  dio.options.receiveTimeout = const Duration(
    milliseconds: ApiConfig.receiveTimeout,
  );

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

  bool isError = false;
  bool isRequest = false;

  // Log interceptor for debugging (pretty formatting with multiple colors)
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: false,
      maxWidth: 90,
      logPrint: (object) {
        final str = object.toString();
        if (str.contains('DioException') || str.contains('ERROR') || str.contains('DioError')) {
          isError = true;
          isRequest = false;
        } else if (str.contains('=> ') || str.contains('Request ║') || str.contains('REQUEST ')) {
          isRequest = true;
          isError = false;
        } else if (str.contains('<= ') || str.contains('Response ║') || str.contains('RESPONSE ')) {
          isRequest = false;
          isError = false;
        }
        
        if (isError) {
          // Red for errors
          print('\x1B[31m$str\x1B[0m');
        } else if (isRequest) {
          // Yellow for requests
          print('\x1B[33m$str\x1B[0m');
        } else {
          // Green for responses
          print('\x1B[32m$str\x1B[0m');
        }
      },
    ),
  );

  return dio;
});
