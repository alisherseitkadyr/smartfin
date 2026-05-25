import 'package:dio/dio.dart';

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
  const OnboardingDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      final res = await _dio.get('/profile/me');
      final data = res.data as Map<String, dynamic>;
      return data['onboardingCompleted'] as bool? ?? false;
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
      await _dio.put('/profile/me', data: {
        'financial_literacy_level': financialLiteracyLevel,
        'practical_experience': practicalExperience,
        'learning_goal': learningGoal,
        'preferred_language': preferredLanguage,
        'time_commitment': timeCommitment,
        'preferred_topics': preferredTopics,
      });
    } on DioException catch (e) {
      // 409 means the profile already exists — treat as success.
      if (e.response?.statusCode == 409) return;
      rethrow;
    }
  }
}
