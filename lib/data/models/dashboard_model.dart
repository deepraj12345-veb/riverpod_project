import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/dashboard_entity.dart';
import 'package:veggie_mart/data/models/user_model.dart';
import 'package:veggie_mart/data/models/banner_model.dart';
import 'package:veggie_mart/data/models/category_model.dart';
import 'package:veggie_mart/data/models/product_model.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardModel extends DashboardEntity {
  @override
  // ignore: overridden_fields
  final UserModel? user;
  @override
  @JsonKey(defaultValue: [])
  // ignore: overridden_fields
  final List<BannerModel> banners;
  @override
  @JsonKey(name: 'category_types', defaultValue: [])
  // ignore: overridden_fields
  final List<CategoryModel> categoryTypes;
  @override
  @JsonKey(defaultValue: [])
  // ignore: overridden_fields
  final List<CategoryModel> categories;
  @override
  @JsonKey(defaultValue: [])
  // ignore: overridden_fields
  final List<ProductModel> bestsellers;
  @override
  @JsonKey(name: 'trending_near_you', defaultValue: [])
  // ignore: overridden_fields
  final List<ProductModel> trendingNearYou;

  DashboardModel({
    this.user,
    this.banners = const [],
    this.categoryTypes = const [],
    this.categories = const [],
    this.bestsellers = const [],
    this.trendingNearYou = const [],
    super.walletBalance = 0.0,
  }) : super(
          user: user,
          banners: banners,
          categoryTypes: categoryTypes,
          categories: categories,
          bestsellers: bestsellers,
          trendingNearYou: trendingNearYou,
          totalOrders: 0, // This could be parsed from active_orders.count if needed
          savedAddresses: 0,
        );

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // For backwards compatibility, if it's the old simplified format
    if (!json.containsKey('banners') && json.containsKey('wallet_balance')) {
      return DashboardModel()
        .._totalOrders = json['total_orders'] as int? ?? 0
        .._walletBalance = (json['wallet_balance'] as num?)?.toDouble() ?? 0.0
        .._savedAddresses = json['saved_addresses'] as int? ?? 0;
    }
    
    final model = _$DashboardModelFromJson(json);
    
    // Parse totalOrders from active_orders if available
    if (json['active_orders'] != null && json['active_orders'] is Map) {
       model._totalOrders = json['active_orders']['count'] as int? ?? 0;
    }
    
    // Parse wallet_balance from user if available
    if (json['user'] != null && json['user'] is Map) {
       model._walletBalance = (json['user']['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    }
    
    return model;
  }

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);

  int _totalOrders = 0;
  double _walletBalance = 0.0;
  int _savedAddresses = 0;

  @override
  int get totalOrders => _totalOrders > 0 ? _totalOrders : super.totalOrders;
  
  @override
  double get walletBalance => _walletBalance > 0 ? _walletBalance : super.walletBalance;
  
  @override
  int get savedAddresses => _savedAddresses > 0 ? _savedAddresses : super.savedAddresses;
}
