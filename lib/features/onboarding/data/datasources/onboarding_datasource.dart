import 'package:dio/dio.dart';

import '../../../../core/services/safe_storage.dart';

abstract class OnboardingDataSource {
  Future<bool> isOnboardingComplete();
  Future<void> submitOnboarding({
    required String financialLiteracyLevel,
    required String practicalExperience,
    required String learningGoal,
    required String preferredLanguage,
    required String timeCommitment,
    required List<String> preferredTopics,
  });
}

class OnboardingDataSourceImpl implements OnboardingDataSource {
  final Dio _dio;
  final SafeStorage _storage;

  static const _kCacheKey = 'onboarding_complete';

  const OnboardingDataSourceImpl({
    required Dio dio,
    required SafeStorage storage,
  }) : _dio = dio,
       _storage = storage;

  @override
  Future<bool> isOnboardingComplete() async {
    // Once onboarding is complete it should not revert for the same session, so
    // a local true lets normal launches skip /profile/me entirely.
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
  Future<void> submitOnboarding({
    required String financialLiteracyLevel,
    required String practicalExperience,
    required String learningGoal,
    required String preferredLanguage,
    required String timeCommitment,
    required List<String> preferredTopics,
  }) async {
    try {
      await _dio.put(
        '/profile/me',
        data: {
          'financial_literacy_level': financialLiteracyLevel,
          'practical_experience': practicalExperience,
          'learning_goal': learningGoal,
          'preferred_language': preferredLanguage,
          'time_commitment': timeCommitment,
          'preferred_topics': preferredTopics,
        },
      );
      await _storage.write(key: _kCacheKey, value: 'true');
    } on DioException catch (e) {
      // 409 means the profile already exists — treat as success.
      if (e.response?.statusCode == 409) {
        await _storage.write(key: _kCacheKey, value: 'true');
        return;
      }
      rethrow;
    }
  }
}
