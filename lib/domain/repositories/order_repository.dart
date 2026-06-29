import 'package:veggie_mart/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({int page = 1, int limit = 20});
  Future<OrderEntity> getOrderDetail(String id);
  Future<OrderEntity> placeOrder(Map<String, dynamic> orderData);
  Future<OrderEntity> cancelOrder(String id, String reason);
}
