// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardModel _$DashboardModelFromJson(Map<String, dynamic> json) =>
    DashboardModel(
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      savedAddresses: (json['saved_addresses'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DashboardModelToJson(DashboardModel instance) =>
    <String, dynamic>{
      'total_orders': instance.totalOrders,
      'wallet_balance': instance.walletBalance,
      'saved_addresses': instance.savedAddresses,
    };
