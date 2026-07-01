import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    const dartDefine = String.fromEnvironment('API_BASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;

    return dotenv.env['API_BASE_URL'] ??
        'https://vegimart-backend.vercel.app/api/v1';
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
}
