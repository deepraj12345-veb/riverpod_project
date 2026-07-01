// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: readId(json, '_id') as String,
  title: json['title'] as String? ?? '',
  subtitle: json['subtitle'] as String? ?? '',
  imageUrl: json['image'] as String? ?? '',
  link: json['link'] as String? ?? '',
  isActive: readIsActive(json, 'is_active') as String,
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'image': instance.imageUrl,
      'link': instance.link,
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
    };
