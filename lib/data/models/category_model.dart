import 'package:json_annotation/json_annotation.dart';
import 'package:veggie_mart/domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel extends CategoryEntity {
  CategoryModel({
    @JsonKey(name: '_id') required super.id,
    @JsonKey(defaultValue: '') required super.name,
    @JsonKey(name: 'category_type_id') super.typeId,
    @JsonKey(name: 'image') super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
