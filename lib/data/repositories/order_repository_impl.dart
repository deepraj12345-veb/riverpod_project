import 'package:veg_king/data/datasources/order_remote_data_source.dart';
import 'package:veg_king/domain/entities/order_entity.dart';
import 'package:veg_king/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderEntity>> getOrders({int page = 1, int limit = 20}) {
    return remoteDataSource.getOrders(page, limit);
  }

  @override
  Future<OrderEntity> getOrderDetail(String id) {
    return remoteDataSource.getOrderDetail(id);
  }

  @override
  Future<OrderEntity> placeOrder(Map<String, dynamic> orderData) {
    return remoteDataSource.placeOrder(orderData);
  }

  @override
  Future<OrderEntity> cancelOrder(String id, String reason) {
    return remoteDataSource.cancelOrder(id, reason);
  }
}
