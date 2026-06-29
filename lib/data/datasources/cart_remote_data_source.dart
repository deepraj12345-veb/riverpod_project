import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemEntity>> getCart();
  Future<List<CartItemEntity>> toggleCartItem(String productId, String status);
  Future<List<CartItemEntity>> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CartItemEntity>> getCart() async {
    try {
      final response = await dio.get(ApiConfig.cart);
      return _parseCartResponse(response.data);
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  @override
  Future<List<CartItemEntity>> toggleCartItem(String productId, String status) async {
    try {
      final response = await dio.post(
        ApiConfig.cartToggle,
        data: {
          "product_id": productId,
          "status": status, // "add" or "remove"
        },
      );
      return _parseCartResponse(response.data);
    } catch (e) {
      throw Exception('Failed to toggle cart item: $e');
    }
  }

  @override
  Future<List<CartItemEntity>> clearCart() async {
    try {
      final response = await dio.delete(ApiConfig.cartClear);
      return _parseCartResponse(response.data);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  List<CartItemEntity> _parseCartResponse(dynamic data) {
    if (data == null) return [];
    
    // Check if the response wraps the data in a "data" or "cart" field
    dynamic cartData = data['data'] ?? data['cart'] ?? data;
    
    if (cartData == null) return [];
    
    // Usually a cart response contains an array of items. 
    // It might be under `cartData['items']` or just be a list directly.
    List<dynamic> items = [];
    if (cartData is List) {
      items = cartData;
    } else if (cartData['items'] is List) {
      items = cartData['items'];
    }

    return items.map((e) {
      final productJson = e['product'] ?? e; // fallback if product is flattened
      final qty = e['qty'] ?? e['quantity'] ?? 1;

      return CartItemEntity(
        product: _parseProduct(productJson),
        quantity: qty,
      );
    }).toList();
  }

  ProductEntity _parseProduct(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['original_price'] ?? json['originalPrice'] ?? (json['price'] ?? 0)).toDouble(),
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      inStock: json['in_stock'] ?? json['inStock'] ?? true,
      unit: json['unit'] ?? '1 piece',
    );
  }
}
