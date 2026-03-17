// smartfin/lib/features/home/data/repositories/home_repository_impl.dart
import '../../domain/entities/home_entities.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource _dataSource;

  const HomeRepositoryImpl(this._dataSource);

  @override
  Future<HomeData> getHomeData() async {
    final model = await _dataSource.getHomeData();
    return model.toEntity();
  }

  @override
  Future<MonthlySnapshot> getMonthlySnapshot() async {
    final model = await _dataSource.getHomeData();
    return model.snapshot.toEntity();
  }
}