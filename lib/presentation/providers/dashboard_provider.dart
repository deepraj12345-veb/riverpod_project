import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:veg_king/core/network/dio_client.dart';
import 'package:veg_king/data/datasources/dashboard_remote_data_source.dart';
import 'package:veg_king/data/repositories/dashboard_repository_impl.dart';
import 'package:veg_king/domain/entities/dashboard_entity.dart';
import 'package:veg_king/domain/repositories/dashboard_repository.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final dio = ref.watch(dioClientProvider);
  return DashboardRemoteDataSourceImpl(dio: dio);
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final remoteDataSource = ref.watch(dashboardRemoteDataSourceProvider);
  return DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
});

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardEntity>> {
  final DashboardRepository repository;

  DashboardNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> fetchDashboard() async {
    state = const AsyncValue.loading();
    try {
      final data = await repository.getDashboardData();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardEntity>>((
      ref,
    ) {
      final repository = ref.watch(dashboardRepositoryProvider);
      return DashboardNotifier(repository);
    });
