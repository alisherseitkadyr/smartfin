// smartfin/lib/features/home/data/repositories/home_repository_impl.dart
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  const HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<HomeData> getHomeData() async {
    final model = await _remoteDataSource.getHomeData('current_user');
    return model.toEntity();
  }

  @override
  Future<MonthlySnapshot> getMonthlySnapshot() async {
    final model = await _remoteDataSource.getHomeData('current_user');
    return model.snapshot.toEntity();
  }
}
