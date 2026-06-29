import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/dashboard_entity.dart';

part 'dashboard_model.g.dart';

@JsonSerializable()
class DashboardModel extends DashboardEntity {
  DashboardModel({
    @JsonKey(name: 'total_orders', defaultValue: 0) required super.totalOrders,
    @JsonKey(name: 'wallet_balance', defaultValue: 0.0) required super.walletBalance,
    @JsonKey(name: 'saved_addresses', defaultValue: 0) required super.savedAddresses,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardModelToJson(this);
}
