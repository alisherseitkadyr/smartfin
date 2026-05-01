import 'package:dio/dio.dart';
import '../models/topic_item_model.dart';
import '../models/category_model.dart';

abstract class ExploreRemoteDataSource {
  Future<List<TopicItemModel>> getTopics();
  Future<List<String>> getCompletedTopicIds(String userId);
  Future<Map<String, int>> getTopicProgress(String userId);
  Future<List<CategoryModel>> getCategories();
  Future<void> updateProgress(
    String userId,
    String topicId,
    String status, {
    int completedSteps = 0,
  });
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final Dio _dio;
  static const _languageCode = 'en';

  ExploreRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<TopicItemModel>> getTopics() async {
    final response = await _dio.get(
      '/content/topics',
      queryParameters: {'lang': _languageCode},
    );

    if (response.statusCode == 200) {
      final topics = _readList(response.data);
      return Future.wait(
        topics.whereType<Map<String, dynamic>>().map(_topicFromContentResponse),
      );
    }
    throw Exception('Failed to load topics');
  }

  @override
  Future<List<String>> getCompletedTopicIds(String userId) async {
    try {
      final response = await _dio.get('/progress/me');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data.containsKey('completed_topics')) {
          final completed = data['completed_topics'] as List;
          return List<String>.from(completed);
        }
      }
      return [];
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, int>> getTopicProgress(String userId) async {
    try {
      final response = await _dio.get('/progress/me');

      if (response.statusCode == 200) {
        return _topicProgressFromOverview(response.data);
      }
      return {};
    } on DioException {
      return {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    throw UnsupportedError('Backend does not expose content categories yet');
  }

  @override
  Future<void> updateProgress(
    String userId,
    String topicId,
    String status, {
    int completedSteps = 0,
  }) async {
    // The current backend updates learning progress through assessment submits,
    // not a direct topic progress endpoint.
  }

  List<dynamic> _readList(Object? data) {
    if (data is List) return data;
    if (data is Map<String, dynamic> && data['items'] is List) {
      return data['items'] as List;
    }
    return const [];
  }

  Future<TopicItemModel> _topicFromContentResponse(
    Map<String, dynamic> topic,
  ) async {
    final topicCode = topic['code'].toString();
    final subtopics = await _getSubtopics(topicCode);
    final firstSubtopic = subtopics.isEmpty ? null : subtopics.first;
    final estimatedMinutes = (firstSubtopic?['estimatedMinutes'] as num?)
        ?.toInt();
    final stepCount = firstSubtopic == null
        ? 0
        : await _getLessonStepCount(firstSubtopic['code'].toString());

    return TopicItemModel.fromJson({
      ...topic,
      'id': topicCode,
      'duration': estimatedMinutes == null ? '5 min' : '$estimatedMinutes min',
      'stepCount': stepCount,
      'xp': _xpForLevel(topic['level'] as String?),
      'icon': _iconForTopic(topicCode),
    });
  }

  Future<List<Map<String, dynamic>>> _getSubtopics(String topicCode) async {
    try {
      final response = await _dio.get(
        '/content/topics/$topicCode/subtopics',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode != 200) return const [];
      return _readList(
        response.data,
      ).whereType<Map<String, dynamic>>().toList();
    } on DioException {
      return const [];
    }
  }

  Future<int> _getLessonStepCount(String subtopicCode) async {
    try {
      final response = await _dio.get(
        '/content/subtopics/$subtopicCode/lesson',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode != 200 ||
          response.data is! Map<String, dynamic>) {
        return 0;
      }
      final data = response.data as Map<String, dynamic>;
      return (data['steps'] as List?)?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Map<String, int> _topicProgressFromOverview(Object? data) {
    if (data is! Map<String, dynamic>) return {};

    final progress = data['progress'];
    if (progress is Map<String, dynamic> && progress.containsKey('topics')) {
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

  int _xpForLevel(String? level) {
    switch (level) {
      case 'advanced':
        return 100;
      case 'intermediate':
        return 75;
      default:
        return 50;
    }
  }

  String _iconForTopic(String code) {
    switch (code) {
      case 'budgeting':
        return '💰';
      case 'savings':
        return '💾';
      case 'credit_and_debt':
        return '🏦';
      case 'financial_planning':
        return '🧭';
      case 'investments':
        return '📈';
      default:
        return '📚';
    }
  }
}
