import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:veggie_mart/domain/entities/user_entity.dart';
import 'package:veggie_mart/core/utils/json_utils.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

Object? _readString(Map json, String key) => json[key] as String? ?? '';
Object? _readDouble(Map json, String key) =>
    ((json[key] as num?) ?? 0).toDouble();

@freezed
abstract class UserModel with _$UserModel implements UserEntity {
  const factory UserModel({
    @JsonKey(name: '_id', readValue: readId) required String id,
    @JsonKey(readValue: _readString) required String name,
    @JsonKey(readValue: _readString) required String email,
    @JsonKey(name: 'mobile_no', readValue: _readString) required String mobileNo,
    @JsonKey(name: 'profile_image', readValue: _readString) @Default('') String avatarUrl,
    @JsonKey(readValue: _readString) @Default('') String address,
    @JsonKey(name: 'wallet_balance', readValue: _readDouble) @Default(0.0) double walletBalance,
    String? token,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
