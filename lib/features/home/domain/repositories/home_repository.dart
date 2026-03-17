// smartfin/lib/features/home/domain/repositories/home_repository.dart
import '../entities/home_entities.dart';

abstract class HomeRepository {
  /// Returns the full home screen data in one shot.
  Future<HomeData> getHomeData();

  /// Refreshes just the monthly financial snapshot.
  Future<MonthlySnapshot> getMonthlySnapshot();
}