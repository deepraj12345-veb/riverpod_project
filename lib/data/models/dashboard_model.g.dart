// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      banners:
          (json['banners'] as List<dynamic>?)
              ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categoryTypes:
          (json['category_types'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bestsellers:
          (json['bestsellers'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trendingNearYou:
          (json['trending_near_you'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'banners': instance.banners,
      'category_types': instance.categoryTypes,
      'categories': instance.categories,
      'bestsellers': instance.bestsellers,
      'trending_near_you': instance.trendingNearYou,
      'walletBalance': instance.walletBalance,
    };
