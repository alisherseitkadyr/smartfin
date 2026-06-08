import '../../domain/entities/home_tip.dart';
import '../../domain/repositories/home_tip_repository.dart';
import '../datasources/home_tip_datasource.dart';

class HomeTipRepositoryImpl implements HomeTipRepository {
  final HomeTipDataSource _dataSource;

  HomeTipRepositoryImpl(this._dataSource);

  @override
  Future<HomeTip> getTip(String languageCode) async =>
      (await _dataSource.getTip(languageCode)).toDomain();
}
