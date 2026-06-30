import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/product_entity.dart';
import 'package:veggie_mart/core/utils/json_utils.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends ProductEntity {
  final double sellingPrice;
  @JsonKey(name: 'mrp', defaultValue: 0.0)
  final double mrp;
  @JsonKey(name: 'stock_status', defaultValue: 0)
  final int stockStatus;

  ProductModel({
    @JsonKey(name: '_id', readValue: readId) required super.id,
    @JsonKey(name: 'product_name', defaultValue: '') required super.name,
    @JsonKey(defaultValue: '') required super.description,
    @JsonKey(name: 'selling_price', defaultValue: 0.0)
    required this.sellingPrice,
    required this.mrp,
    @JsonKey(name: 'product_image', defaultValue: '') required super.imageUrl,
    @JsonKey(defaultValue: '') required super.category,
    @JsonKey(defaultValue: 0.0) required super.rating,
    @JsonKey(defaultValue: 0) required super.reviewCount,
    @JsonKey(name: 'is_wishlist', defaultValue: false)
    required super.isFavorite,
    @JsonKey(defaultValue: []) required super.tags,
    required this.stockStatus,
    @JsonKey(name: 'quantity', defaultValue: '1 piece') required super.unit,
  }) : super(price: sellingPrice, originalPrice: mrp, inStock: stockStatus > 0);

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
