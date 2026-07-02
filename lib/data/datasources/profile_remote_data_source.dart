import 'package:dio/dio.dart';
import 'package:veggie_mart/core/network/api_config.dart';
import 'package:veggie_mart/core/network/api_exceptions.dart';
import 'package:veggie_mart/domain/entities/user_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({String? name, String? email});
  Future<double> getWalletBalance();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserEntity> getProfile() async {
    try {
      final response = await dio.get(ApiConfig.profile);
      final raw = response.data;
      final Map<String, dynamic> json =
          raw is Map<String, dynamic> && raw.containsKey('data')
              ? raw['data'] as Map<String, dynamic>
              : raw as Map<String, dynamic>;
      return UserEntity.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserEntity> updateProfile({String? name, String? email}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (email != null && email.isNotEmpty) data['email'] = email;

      final response = await dio.patch(ApiConfig.profile, data: data);
      final raw = response.data;
      final Map<String, dynamic> json =
          raw is Map<String, dynamic> && raw.containsKey('data')
              ? raw['data'] as Map<String, dynamic>
              : raw as Map<String, dynamic>;
      return UserEntity.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<double> getWalletBalance() async {
    try {
      final response = await dio.get(ApiConfig.wallet);
      final raw = response.data;
      final Map<String, dynamic> json =
          raw is Map<String, dynamic> && raw.containsKey('data')
              ? raw['data'] as Map<String, dynamic>
              : raw as Map<String, dynamic>;
      
      // Parse wallet balance from response, typically returned as wallet_balance or balance
      final balance = json['wallet_balance'] ?? json['balance'] ?? json['walletBalance'] ?? 0.0;
      return (balance as num).toDouble();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
