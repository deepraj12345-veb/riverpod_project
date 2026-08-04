import 'package:veg_king/domain/entities/product_entity.dart';

class OrderItemEntity {
  final ProductEntity product;
  final int quantity;

  const OrderItemEntity({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;
}

class OrderEntity {
  final String id;
  final DateTime date;
  final double totalAmount;
  final double subtotal;
  final double tax;
  final double discount;
  final String status; // 'Pending', 'Processing', 'On the way', 'Delivered', 'Cancelled', 'Failed'
  final String deliveryAddress;
  final String paymentMethod;
  final List<OrderItemEntity> items;
  final String? orderNumber;
  final String? paymentStatus;
  final String? customerMobile;
  final String? city;

  const OrderEntity({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.items,
    this.orderNumber,
    this.paymentStatus,
    this.customerMobile,
    this.city,
  });

  OrderEntity copyWith({
    String? id,
    DateTime? date,
    double? totalAmount,
    double? subtotal,
    double? tax,
    double? discount,
    String? status,
    String? deliveryAddress,
    String? paymentMethod,
    List<OrderItemEntity>? items,
    String? orderNumber,
    String? paymentStatus,
    String? customerMobile,
    String? city,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      orderNumber: orderNumber ?? this.orderNumber,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerMobile: customerMobile ?? this.customerMobile,
      city: city ?? this.city,
    );
  }
}
