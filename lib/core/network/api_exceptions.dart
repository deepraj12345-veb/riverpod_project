import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return ApiException("Request to API server was cancelled");
      case DioExceptionType.connectionTimeout:
        return ApiException("Connection timeout with API server");
      case DioExceptionType.receiveTimeout:
        return ApiException("Receive timeout in connection with API server");
      case DioExceptionType.sendTimeout:
        return ApiException("Send timeout in connection with API server");
      case DioExceptionType.connectionError:
        return ApiException("No Internet connection");
      case DioExceptionType.badCertificate:
        return ApiException("Bad Certificate");
      case DioExceptionType.badResponse:
        return ApiException._handleError(
          dioException.response?.statusCode,
          dioException.response?.data,
        );
      case DioExceptionType.transformTimeout:
        return ApiException("Transform timeout in connection with API server");
      case DioExceptionType.unknown:
        if (dioException.message?.contains("SocketException") ?? false) {
          return ApiException('No Internet connection');
        }
        return ApiException("Unexpected error occurred");
    }
  }

  factory ApiException._handleError(int? statusCode, dynamic data) {
    String message = "Unexpected error occurred";
    if (data != null && data is Map<String, dynamic>) {
      // Try to extract message from common error response structures
      message = data['message'] ?? data['error'] ?? message;
    }
    return ApiException(message, statusCode);
  }

  @override
  String toString() => message;
}
