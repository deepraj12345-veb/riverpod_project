// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategory_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubcategoryModel _$SubcategoryModelFromJson(Map<String, dynamic> json) =>
    SubcategoryModel(
      id: json['_id'] as String,
      name: json['category_name'] as String? ?? '',
      categoryId: json['cat_id'] as String?,
      imageUrl: json['image'] as String?,
    );

Map<String, dynamic> _$SubcategoryModelToJson(SubcategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'category_name': instance.name,
      'cat_id': instance.categoryId,
      'image': instance.imageUrl,
    };
