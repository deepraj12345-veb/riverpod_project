import 'package:veggie_mart/data/datasources/dashboard_remote_data_source.dart';
import 'package:veggie_mart/domain/entities/dashboard_entity.dart';
import 'package:veggie_mart/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardEntity> getDashboardData() async {
    return await remoteDataSource.getDashboardData();
  }
}
