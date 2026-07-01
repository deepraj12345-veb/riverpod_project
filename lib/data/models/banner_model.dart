import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/banner_entity.dart';
import 'package:veggie_mart/core/utils/json_utils.dart';

part 'banner_model.g.dart';

dynamic readIsActive(Map json, String key) {
  return json[key]?.toString() ?? '1';
}

@JsonSerializable()
class BannerModel extends BannerEntity {
  BannerModel({
    @JsonKey(name: '_id', readValue: readId) required super.id,
    @JsonKey(defaultValue: '') required super.title,
    @JsonKey(defaultValue: '') required super.subtitle,
    @JsonKey(name: 'image', defaultValue: '') required super.imageUrl,
    @JsonKey(defaultValue: '') required super.link,
    @JsonKey(name: 'is_active', readValue: readIsActive) required super.isActive,
    @JsonKey(name: 'sort_order', defaultValue: 0) required super.sortOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}
