import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';
import 'package:veggie_mart/data/models/product_model.dart';
import 'package:veggie_mart/core/utils/json_utils.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  @override
  @JsonKey(defaultValue: [])
  // ignore: overridden_fields
  final List<ProductModel>? products;

  CategoryModel({
    @JsonKey(name: '_id', readValue: readId) required super.id,
    @JsonKey(defaultValue: '') required super.name,
    @JsonKey(name: 'category_type_id') required super.typeId,
    @JsonKey(name: 'image') required super.imageUrl,
    this.products,
  }) : super(products: products);

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
