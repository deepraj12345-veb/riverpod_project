import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/subcategory_entity.dart';

part 'subcategory_model.g.dart';

@JsonSerializable()
class SubcategoryModel extends SubcategoryEntity {
  SubcategoryModel({
    @JsonKey(name: '_id') required super.id,
    @JsonKey(name: 'category_name', defaultValue: '') required super.name,
    @JsonKey(name: 'cat_id') super.categoryId,
    @JsonKey(name: 'image') super.imageUrl,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubcategoryModelToJson(this);
}
