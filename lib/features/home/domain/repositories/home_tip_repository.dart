import '../entities/home_tip.dart';

abstract class HomeTipRepository {
  Future<HomeTip> getTip(String languageCode);
}
