import 'package:dio/dio.dart';

import '../../../../core/storage/tip_cache.dart';
import '../models/home_tip_model.dart';

abstract class HomeTipDataSource {
  Future<HomeTipModel> getTip(String languageCode);
}

class HomeTipDataSourceImpl implements HomeTipDataSource {
  final Dio _dio;
  final TipCache _cache;

  HomeTipDataSourceImpl({required Dio dio, required TipCache cache})
      : _dio = dio,
        _cache = cache;

  @override
  Future<HomeTipModel> getTip(String languageCode) async {
    try {
      final response = await _dio.get(
        '/content/tip',
        queryParameters: {'lang': languageCode},
      );
      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        await _cache.save(json);
        return HomeTipModel.fromJson(json);
      }
      throw Exception('tip fetch failed: ${response.statusCode}');
    } on DioException {
      final cached = _cache.getLast();
      if (cached != null) return HomeTipModel.fromJson(cached);
      rethrow;
    }
  }
}
