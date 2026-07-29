import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/domain/entities/order_entity.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderEntity>> getOrders(int page, int limit);
  Future<OrderEntity> getOrderDetail(String id);
  Future<OrderEntity> placeOrder(Map<String, dynamic> orderData);
  Future<OrderEntity> cancelOrder(String id, String reason);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderEntity>> getOrders(int page, int limit) async {
    try {
      final response = await dio.get(
        ApiConfig.orders,
        queryParameters: {'page': page, 'limit': limit},
      );
      
      final data = response.data['data'] ?? response.data['orders'] ?? response.data;
      if (data is List) {
        return data.map((e) => _parseOrder(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  @override
  Future<OrderEntity> getOrderDetail(String id) async {
    try {
      final response = await dio.get('${ApiConfig.orders}/$id');
      final data = response.data['data'] ?? response.data['order'] ?? response.data;
      return _parseOrder(data);
    } catch (e) {
      throw Exception('Failed to load order detail: $e');
    }
  }

  @override
  Future<OrderEntity> placeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await dio.post(ApiConfig.orders, data: orderData);
      final data = response.data['data'] ?? response.data['order'] ?? response.data;
      return _parseOrder(data);
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  @override
  Future<OrderEntity> cancelOrder(String id, String reason) async {
    try {
      final response = await dio.patch(
        '${ApiConfig.orders}/$id/cancel',
        data: {'reason': reason},
      );
      final data = response.data['data'] ?? response.data['order'] ?? response.data;
      return _parseOrder(data);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  OrderEntity _parseOrder(Map<String, dynamic> json) {
    List<dynamic> itemsJson = json['items'] ?? [];
    List<OrderItemEntity> items = itemsJson.map((e) {
      if (e is String) {
        return OrderItemEntity(
          product: ProductEntity(
            id: e,
            name: 'Product',
            description: '',
            price: 0,
            originalPrice: 0,
            imageUrl: 'https://via.placeholder.com/150',
            category: '',
            rating: 0,
            reviewCount: 0,
            inStock: true,
            unit: '1 item',
          ),
          quantity: 1,
        );
      }
      final productJson = e['product'] ?? e;
      return OrderItemEntity(
        product: _parseProduct(productJson),
        quantity: e['qty'] ?? e['quantity'] ?? 1,
      );
    }).toList();

    String parsedStatus = 'Processing';
    if (json['status'] is int) {
      switch (json['status']) {
        case 0: parsedStatus = 'Pending'; break;
        case 1: parsedStatus = 'Processing'; break;
        case 2: parsedStatus = 'Delivered'; break;
        case 4: parsedStatus = 'Cancelled'; break;
        case 5: parsedStatus = 'Failed'; break;
        default: parsedStatus = 'Processing';
      }
    } else {
      parsedStatus = json['status']?.toString() ?? 'Processing';
    }

    return OrderEntity(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['order_number'],
      customerMobile: json['customer_mobile'],
      paymentStatus: json['payment_status'],
      city: json['city'],
      date: json['created_at'] != null ? DateTime.parse(json['created_at']) : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      totalAmount: (json['total_amount'] ?? json['totalAmount'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? json['delivery_charge'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      status: parsedStatus,
      deliveryAddress: json['delivery_address'] ?? json['address'] ?? '',
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? 'COD',
      items: items,
    );
  }

  ProductEntity _parseProduct(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['product_id'] ?? json['_id'] ?? json['id'] ?? '',
      name: json['product_name'] ?? json['name'] ?? 'Unknown Product',
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
