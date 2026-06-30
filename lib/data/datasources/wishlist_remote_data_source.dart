import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ProductEntity>> getWishlist();
  Future<List<ProductEntity>> addToWishlist(String productId);
  Future<List<ProductEntity>> removeFromWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio dio;

  WishlistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductEntity>> getWishlist() async {
    try {
      final response = await dio.get(ApiConfig.wishlist);
      return _parseWishlist(response.data);
    } catch (e) {
      throw Exception('Failed to load wishlist: $e');
    }
  }

  @override
  Future<List<ProductEntity>> addToWishlist(String productId) async {
    try {
      await dio.post(ApiConfig.wishlistAdd, data: {'product_id': productId});
      return await getWishlist();
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  @override
  Future<List<ProductEntity>> removeFromWishlist(String productId) async {
    try {
      await dio.delete('${ApiConfig.wishlist}/$productId');
      return await getWishlist();
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  List<ProductEntity> _parseWishlist(dynamic data) {
    if (data == null) return [];
    dynamic wishlistData = data['data'] ?? data['wishlist'] ?? data;
    if (wishlistData == null) return [];

    List<dynamic> items = [];
    if (wishlistData is List) {
      items = wishlistData;
    } else if (wishlistData['items'] is List) {
      items = wishlistData['items'];
    }

    return items.map((e) {
      final productJson = e['product'] ?? e['product_id'] ?? e;
      return _parseProduct(productJson);
    }).toList();
  }

  ProductEntity _parseProduct(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['product_name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? json['selling_price'] ?? 0).toDouble(),
      originalPrice:
          (json['original_price'] ??
                  json['originalPrice'] ??
                  json['mrp'] ??
                  json['price'] ??
                  json['selling_price'] ??
                  0)
              .toDouble(),
      imageUrl:
          json['image'] ?? json['imageUrl'] ?? json['product_image'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      inStock:
          json['in_stock'] ??
          json['inStock'] ??
          (json['stock_status'] != null
              ? (json['stock_status'] as num) > 0
              : true),
      unit: json['unit'] ?? json['quantity'] ?? '1 piece',
      isFavorite: true,
    );
  }
}
