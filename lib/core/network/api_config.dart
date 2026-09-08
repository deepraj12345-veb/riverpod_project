import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String _normalizeUrl(String rawUrl) {
    String url = rawUrl.trim();
    if (!kIsWeb && Platform.isAndroid && url.contains('localhost')) {
      url = url.replaceAll('localhost', '10.0.2.2');
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    if (!url.endsWith('/api/v1')) {
      url = '$url/api/v1';
    }
    return url;
  }

  static String get rootUrl {
    final base = baseUrl;
    if (base.endsWith('/api/v1')) {
      return base.substring(0, base.length - '/api/v1'.length);
    }
    return base;
  }

  static String get baseUrl {
    const dartDefine = String.fromEnvironment('API_BASE_URL');
    if (dartDefine.isNotEmpty) {
      return _normalizeUrl(dartDefine);
    }

    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return _normalizeUrl(envUrl);
    }

    return 'https://vegimart-backend.vercel.app/api/v1';
  }

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  // Products
  static const String products = '/products';
  // Dashboard
  static const String dashboard = '/dashboard';
  // Categories

  static const String categoryTypes = '/category-types';
  static const String hierarchyCategoryTypes = '/hierarchy/category-types';
  static const String categories = '/categories';
  static const String subcategories = '/subcategories';

  // Cart
  static const String cart = '/cart';
  static const String cartToggle = '/cart/toggle';
  static const String cartClear = '/cart/clear';
  static const String orders = '/orders';

  // Wishlist
  static const String wishlist = '/wishlist';
  static const String wishlistAdd = '/wishlist/add';

  // Profile
  static const String profile = '/user/profile';
  static const String wallet = '/user/wallet';

  // Addresses
  static const String addresses = '/addresses';
  static String addressById(String id) => '/addresses/$id';
  static String addressDefault(String id) => '/addresses/$id/default';
}
