// smartfin/lib/features/home/domain/usecases/home_usecases.dart
import '../entities/home_entities.dart';
import '../repositories/home_repository.dart';

class GetHomeData {
  final HomeRepository _repository;
  const GetHomeData(this._repository);

  Future<HomeData> call() => _repository.getHomeData();
}

class GetMonthlySnapshot {
  final HomeRepository _repository;
  const GetMonthlySnapshot(this._repository);

  Future<MonthlySnapshot> call() => _repository.getMonthlySnapshot();
}