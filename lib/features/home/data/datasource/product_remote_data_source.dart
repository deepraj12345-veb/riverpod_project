import 'package:riverpod_project/core/data/fake_data.dart';
import 'package:riverpod_project/features/home/domain/entities/product_entity.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductEntity>> fetchProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductEntity>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return FakeData.products;
  }
}
