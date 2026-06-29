import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veggie_mart/core/network/dio_client.dart';
import 'package:veggie_mart/data/datasources/dashboard_remote_data_source.dart';
import 'package:veggie_mart/data/repositories/dashboard_repository_impl.dart';
import 'package:veggie_mart/domain/entities/dashboard_entity.dart';
import 'package:veggie_mart/domain/repositories/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return DashboardRemoteDataSourceImpl(dio: dio);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
});

final dashboardProvider = FutureProvider<DashboardEntity>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardData();
});
