import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/domain/entities/order_entity.dart';
import 'package:veggie_mart/domain/entities/cart_item_entity.dart';
import 'package:veggie_mart/domain/repositories/order_repository.dart';
import 'package:veggie_mart/data/repositories/order_repository_impl.dart';
import 'package:veggie_mart/data/datasources/order_remote_data_source.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    remoteDataSource: OrderRemoteDataSourceImpl(dio: ref.watch(dioClientProvider)),
  );
});

class OrdersNotifier extends StateNotifier<List<OrderEntity>> {
  final OrderRepository _repository;

  OrdersNotifier(this._repository) : super([]) {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _repository.getOrders();
      state = orders;
    } catch (e) {
      print('Error loading orders: $e');
    }
  }

  Future<void> addOrder(
    List<CartItemEntity> cartItems,
    double subtotal,
    double tax,
    double discount,
    double total,
    String paymentMethod,
    String addressId,
  ) async {
    try {
      final orderData = {
        "address_id": addressId,
        "payment_method": paymentMethod,
        "coupon_code": "",
        "items": cartItems.map((e) => {
          "product_id": e.product.id,
          "qty": e.quantity,
          "price": e.product.price,
        }).toList(),
        "delivery_charge": tax,
        "total_amount": total,
      };
      
      final newOrder = await _repository.placeOrder(orderData);
      state = [newOrder, ...state];
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final updatedOrder = await _repository.cancelOrder(orderId, reason);
      state = state.map((e) => e.id == orderId ? updatedOrder : e).toList();
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderEntity>>(
  (ref) {
    return OrdersNotifier(ref.watch(orderRepositoryProvider));
  },
);

