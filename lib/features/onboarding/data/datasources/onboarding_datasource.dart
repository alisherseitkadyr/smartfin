import 'package:dio/dio.dart';

import '../../../../core/services/safe_storage.dart';
import '../../domain/entities/onboarding_draft.dart';

abstract class OnboardingDataSource {
  Future<bool> isOnboardingComplete();
  Future<StartHereRecommendation?> submitOnboarding({
    required List<String> interests,
    required String compoundInterest,
    required String inflation,
    required String diversification,
  });
}

class OnboardingDataSourceImpl implements OnboardingDataSource {
  final Dio _dio;
  final SafeStorage _storage;

  static const _kCacheKey = 'onboarding_complete';

  const OnboardingDataSourceImpl({
    required Dio dio,
    required SafeStorage storage,
  })  : _dio = dio,
        _storage = storage;

  @override
  Future<bool> isOnboardingComplete() async {
    final cached = await _storage.read(key: _kCacheKey);
    if (cached == 'true') return true;

    try {
      final res = await _dio.get('/profile/me');
      final data = res.data as Map<String, dynamic>;
      final complete = data['onboardingCompleted'] as bool? ?? false;
      if (complete) {
        await _storage.write(key: _kCacheKey, value: 'true');
      }
      return complete;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  @override
  Future<StartHereRecommendation?> submitOnboarding({
    required List<String> interests,
    required String compoundInterest,
    required String inflation,
    required String diversification,
  }) async {
    try {
      final res = await _dio.post(
        '/users/onboarding',
        data: {
          'interests': interests,
          'knowledge': {
            'compound_interest': compoundInterest,
            'inflation': inflation,
            'diversification': diversification,
          },
        },
      );
      await _storage.write(key: _kCacheKey, value: 'true');

      final body = res.data;
      if (body is Map<String, dynamic>) {
        // Accept recommendation under a 'recommendation' / 'startHere' key, or root.
        final recData = body['recommendation'] as Map<String, dynamic>? ??
            body['startHere'] as Map<String, dynamic>? ??
            body['start_here'] as Map<String, dynamic>?;
        if (recData != null) return StartHereRecommendation.fromJson(recData);
        // Try root-level fields as a fallback.
        if (body.containsKey('topicId') || body.containsKey('topic_id')) {
          return StartHereRecommendation.fromJson(body);
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        await _storage.write(key: _kCacheKey, value: 'true');
        return null;
      }
      rethrow;
    }
  }
}
