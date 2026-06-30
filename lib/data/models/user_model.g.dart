// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: readId(json, '_id') as String,
  name: _readString(json, 'name') as String,
  email: _readString(json, 'email') as String,
  phone: _readString(json, 'mobile_no') as String,
  avatarUrl: _readString(json, 'profile_image') as String,
  address: _readString(json, 'address') as String,
  token: json['token'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'mobile_no': instance.phone,
      'profile_image': instance.avatarUrl,
      'address': instance.address,
      'token': instance.token,
    };
