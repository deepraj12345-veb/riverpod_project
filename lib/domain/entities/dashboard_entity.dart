import 'package:veggie_mart/domain/entities/banner_entity.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/domain/entities/user_entity.dart';

class DashboardEntity {
  final UserEntity? user;
  final List<BannerEntity> banners;
  final List<CategoryEntity> categoryTypes;
  final List<CategoryEntity> categories;
  final List<ProductEntity> bestsellers;
  final List<ProductEntity> trendingNearYou;

  // Keep these for backward compatibility with profile page
  final int totalOrders;
  final double walletBalance;
  final int savedAddresses;

  DashboardEntity({
    this.user,
    this.banners = const [],
    this.categoryTypes = const [],
    this.categories = const [],
    this.bestsellers = const [],
    this.trendingNearYou = const [],
    this.totalOrders = 0,
    this.walletBalance = 0.0,
    this.savedAddresses = 0,
  });
}
