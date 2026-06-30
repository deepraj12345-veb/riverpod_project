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
      await dio.post(
        ApiConfig.cartToggle,
        data: {
          "product_id": productId,
          "status": status, // "add" or "remove"
        },
      );
      return await getCart();
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
    
    List<dynamic> items = [];

    if (data is List) {
      items = data;
    } else if (data is Map) {
      if (data['items'] is List) {
        items = data['items'];
      } else if (data['products'] is List) {
        items = data['products'];
      } else if (data['cart'] is Map && data['cart']['items'] is List) {
        items = data['cart']['items'];
      } else if (data['cart'] is Map && data['cart']['products'] is List) {
        items = data['cart']['products'];
      } else if (data['cart'] is List) {
        items = data['cart'];
      } else if (data['data'] is Map) {
        final innerData = data['data'];
        if (innerData['items'] is List) {
          items = innerData['items'];
        } else if (innerData['products'] is List) {
          items = innerData['products'];
        } else if (innerData['cart'] is Map && innerData['cart']['items'] is List) {
          items = innerData['cart']['items'];
        } else if (innerData['cart'] is Map && innerData['cart']['products'] is List) {
          items = innerData['cart']['products'];
        } else if (innerData['cart'] is List) {
          items = innerData['cart'];
        } else if (innerData is List) {
          items = innerData;
        }
      }
    }
    
    if (items.isEmpty) {
      // If we got success: false or couldn't parse the cart, we shouldn't return empty list
      // which would clear the cart. We should throw so it falls back to local cart if needed.
      if (data is Map && data['success'] == false) {
        throw Exception(data['message'] ?? 'Failed to update cart');
      }
    }

    return items.map((e) {
      final productJson = e['product'] ?? e; // fallback if product is flattened
      final qty = e['cart_count'] ?? e['qty'] ?? e['quantity'] ?? 1;

      return CartItemEntity(
        product: _parseProduct(productJson),
        quantity: qty,
      );
    }).toList();
  }

  ProductEntity _parseProduct(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['product_id'] ?? json['_id'] ?? json['id'] ?? '',
      name: json['product_name'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['selling_price'] ?? json['price'] ?? 0).toDouble(),
      originalPrice: (json['mrp'] ?? json['original_price'] ?? json['originalPrice'] ?? json['price'] ?? 0).toDouble(),
      imageUrl: json['product_image'] ?? json['image'] ?? json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      inStock: json['in_stock'] ?? json['inStock'] ?? true,
      unit: json['quantity_unit'] ?? json['unit'] ?? '1 piece',
    );
  }
}
