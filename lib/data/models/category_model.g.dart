// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: readId(json, '_id') as String,
      name: json['name'] as String? ?? '',
      typeId: json['category_type_id'] as String?,
      imageUrl: json['image'] as String?,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'category_type_id': instance.typeId,
      'image': instance.imageUrl,
      'products': instance.products,
    };
