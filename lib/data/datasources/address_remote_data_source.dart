import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/domain/entities/address_entity.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> addAddress(AddressEntity address);
  Future<AddressEntity> updateAddress(String id, Map<String, dynamic> data);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio dio;
  AddressRemoteDataSourceImpl({required this.dio});

  List<AddressEntity> _parseList(dynamic raw) {
    final List<dynamic> list = raw is Map && raw.containsKey('data')
        ? (raw['data'] is List ? raw['data'] : [raw['data']])
        : (raw is List ? raw : []);
    return list
        .map((e) => AddressEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  AddressEntity _parseSingle(dynamic raw) {
    final Map<String, dynamic> json = raw is Map && raw.containsKey('data')
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return AddressEntity.fromJson(json);
  }

  @override
  Future<List<AddressEntity>> getAddresses() async {
    try {
      final response = await dio.get(ApiConfig.addresses);
      return _parseList(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    try {
      final response = await dio.post(
        ApiConfig.addresses,
        data: address.toJson(),
      );
      return _parseSingle(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AddressEntity> updateAddress(
      String id, Map<String, dynamic> data) async {
    try {
      final response =
          await dio.patch(ApiConfig.addressById(id), data: data);
      return _parseSingle(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await dio.delete(ApiConfig.addressById(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    try {
      await dio.patch(ApiConfig.addressDefault(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
