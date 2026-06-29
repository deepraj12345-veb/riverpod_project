import 'package:veggie_mart/data/datasources/product_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  List<ProductEntity>? _cachedProducts;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductEntity>> getProducts() async {
    _cachedProducts ??= await remoteDataSource.fetchProducts();
    return _cachedProducts!;
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    if (_cachedProducts == null) {
      await getProducts();
    }
    _cachedProducts = _cachedProducts!.map((p) {
      if (p.id == productId) {
        return p.copyWith(isFavorite: !p.isFavorite);
      }
      return p;
    }).toList();
  }
}
