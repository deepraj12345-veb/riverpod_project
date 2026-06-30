// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: readId(json, '_id') as String,
  name: json['product_name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
  mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
  imageUrl: json['product_image'] as String? ?? '',
  category: json['category'] as String? ?? '',
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
  isFavorite: json['is_wishlist'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  stockStatus: (json['stock_status'] as num?)?.toInt() ?? 0,
  unit: json['quantity'] as String? ?? '1 piece',
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'product_name': instance.name,
      'description': instance.description,
      'product_image': instance.imageUrl,
      'category': instance.category,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'is_wishlist': instance.isFavorite,
      'tags': instance.tags,
      'quantity': instance.unit,
      'selling_price': instance.sellingPrice,
      'mrp': instance.mrp,
      'stock_status': instance.stockStatus,
    };
