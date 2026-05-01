import 'package:dio/dio.dart';
import '../models/lesson_step_model.dart';
import '../../domain/entities/lesson_topic.dart';

abstract class LearnRemoteDataSource {
  Future<List<LessonStepModel>> getStepsForTopic(String topicId);
  Future<List<LessonOutcome>> getOutcomesForTopic(String topicId);
  Future<Map<String, int>> getTopicProgress(String userId);
}

class LearnRemoteDataSourceImpl implements LearnRemoteDataSource {
  final Dio _dio;
  final Map<String, Map<String, dynamic>> _lessonCache = {};
  static const _languageCode = 'en';

  LearnRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>?> _fetchLessonData(String topicId) async {
    final cached = _lessonCache[topicId];
    if (cached != null) return cached;

    final subtopicsResponse = await _dio.get(
      '/content/topics/$topicId/subtopics',
      queryParameters: {'lang': _languageCode},
    );
    if (subtopicsResponse.statusCode != 200) return null;

    final subtopics = _readList(subtopicsResponse.data);
    if (subtopics.isEmpty) return null;

    final firstSubtopic = subtopics.first as Map<String, dynamic>;
    final subtopicCode = firstSubtopic['code'] as String?;
    if (subtopicCode == null || subtopicCode.isEmpty) return null;

    final lessonResponse = await _dio.get(
      '/content/subtopics/$subtopicCode/lesson',
      queryParameters: {'lang': _languageCode},
    );
    if (lessonResponse.statusCode != 200) return null;

    final lesson = lessonResponse.data as Map<String, dynamic>?;
    if (lesson != null) _lessonCache[topicId] = lesson;
    return lesson;
  }

  @override
  Future<List<LessonStepModel>> getStepsForTopic(String topicId) async {
    final lessonData = await _fetchLessonData(topicId);
    if (lessonData == null) {
      throw Exception('Lesson not found for topic: $topicId');
    }

    final stepsList = lessonData['steps'] as List?;
    if (stepsList == null) return [];
    return stepsList
        .map((step) => LessonStepModel.fromJson(step as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<LessonOutcome>> getOutcomesForTopic(String topicId) async {
    final response = await _dio.get(
      '/content/topics/$topicId/subtopics',
      queryParameters: {'lang': _languageCode},
    );
    if (response.statusCode != 200) return [];

    final subtopics = _readList(response.data);

    return subtopics
        .whereType<Map<String, dynamic>>()
        .map((subtopic) => subtopic['title'] as String? ?? '')
        .where((title) => title.isNotEmpty)
        .map((title) => LessonOutcome(text: title))
        .toList();
  }

  @override
  Future<Map<String, int>> getTopicProgress(String userId) async {
    try {
      final response = await _dio.get('/progress/me');
      if (response.statusCode == 200) {
        return _topicProgressFromOverview(response.data);
      }
    } on DioException {
      return {};
    }
    return {};
  }

  List<dynamic> _readList(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['items'] is List) {
      return data['items'] as List;
    }
    return const [];
  }

  Map<String, int> _topicProgressFromOverview(Object? data) {
    if (data is! Map<String, dynamic>) return {};

    final progress = data['progress'];
    if (progress is Map<String, dynamic>) {
      final topics = progress['topics'];
      if (topics is Map<String, dynamic>) {
        return topics.map((key, value) => MapEntry(key, _toInt(value)));
      }
    }

    final completedTopics = data['completed_topics'];
    if (completedTopics is List) {
      return {for (final topicId in completedTopics) topicId.toString(): 1};
    }

    return {};
  }

  int _toInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
