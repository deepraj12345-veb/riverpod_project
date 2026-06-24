import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_project/features/orders/domain/entities/order_entity.dart';
import 'package:riverpod_project/features/cart/domain/entities/cart_item_entity.dart';
import 'package:riverpod_project/core/data/fake_data.dart';

class OrdersNotifier extends StateNotifier<List<OrderEntity>> {
  OrdersNotifier() : super(_initialOrders());

  static List<OrderEntity> _initialOrders() {
    // Generate some initial mock orders based on FakeData.products
    final apple = FakeData.products.firstWhere((p) => p.id == 'p1');
    final banana = FakeData.products.firstWhere((p) => p.id == 'p2');
    final milk = FakeData.products.firstWhere((p) => p.id == 'p5');
    final bread = FakeData.products.firstWhere((p) => p.id == 'p6');

    return [
      OrderEntity(
        id: 'ORD-9831',
        date: DateTime.now().subtract(const Duration(days: 1)),
        subtotal: 138.0,
        discount: 10.0,
        tax: 6.9,
        totalAmount: 134.9,
        status: 'Delivered',
        deliveryAddress: FakeData.currentUser.address,
        paymentMethod: 'Google Pay (UPI)',
        items: [
          OrderItemEntity(product: apple, quantity: 1), // 89
          OrderItemEntity(product: banana, quantity: 1), // 49
        ],
      ),
      OrderEntity(
        id: 'ORD-7629',
        date: DateTime.now().subtract(const Duration(days: 4)),
        subtotal: 223.0,
        discount: 22.3,
        tax: 11.15,
        totalAmount: 211.85,
        status: 'Delivered',
        deliveryAddress: FakeData.currentUser.address,
        paymentMethod: 'Credit Card',
        items: [
          OrderItemEntity(product: milk, quantity: 2), // 178
          OrderItemEntity(product: bread, quantity: 1), // 45
        ],
      ),
    ];
  }

  void addOrder(List<CartItemEntity> cartItems, double subtotal, double tax, double discount, double total, String paymentMethod) {
    final newOrder = OrderEntity(
      id: 'ORD-${1000 + state.length * 11 + (DateTime.now().millisecond % 8999)}',
      date: DateTime.now(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      totalAmount: total,
      status: 'Processing',
      deliveryAddress: FakeData.currentUser.address,
      paymentMethod: paymentMethod,
      items: cartItems
          .map((item) => OrderItemEntity(product: item.product, quantity: item.quantity))
          .toList(),
    );
    state = [newOrder, ...state];
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderEntity>>((ref) {
  return OrdersNotifier();
});
