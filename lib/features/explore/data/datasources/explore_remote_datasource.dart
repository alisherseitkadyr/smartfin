import 'package:dio/dio.dart';
import '../../domain/entities/topic_item.dart';
import '../models/topic_item_model.dart';
import '../models/category_model.dart';

abstract class ExploreRemoteDataSource {
  Future<List<TopicItemModel>> getTopics();
  Future<List<SubtopicItem>> getSubtopics(String topicId);
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
  final String _languageCode;

  ExploreRemoteDataSourceImpl({
    required Dio dio,
    required String languageCode,
  })  : _dio = dio,
        _languageCode = languageCode;

  @override
  Future<List<TopicItemModel>> getTopics() async {
    final response = await _dio.get(
      '/content/topics',
      queryParameters: {'lang': _languageCode},
    );

    if (response.statusCode == 200) {
      final topics = _readList(response.data).whereType<Map<String, dynamic>>().toList();
      final results = await Future.wait(
        topics.map((t) => _topicFromContentResponse(t).then<TopicItemModel?>(
          (v) => v,
          onError: (_) => null,
        )),
      );
      return results.whereType<TopicItemModel>().toList();
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
    if (data is Map<String, dynamic>) {
      if (data['subtopics'] is List) return data['subtopics'] as List;
      if (data['items'] is List) return data['items'] as List;
    }
    return const [];
  }

  Future<TopicItemModel> _topicFromContentResponse(
    Map<String, dynamic> topic,
  ) async {
    final topicCode = topic['code'].toString();
    final subtopics = await _getSubtopics(topicCode);

    final totalMinutes = subtopics.fold<int>(
      0,
      (sum, s) => sum + ((s['estimatedMinutes'] as num?)?.toInt() ?? 0),
    );
    final stepCount = subtopics.length;

    return TopicItemModel.fromJson({
      ...topic,
      'id': topicCode,
      'duration': totalMinutes == 0 ? '5 min' : '$totalMinutes min',
      'stepCount': stepCount,
      'xp': _xpForLevel(topic['level'] as String?),
      'icon': _iconForTopic(topicCode),
    });
  }

  @override
  Future<List<SubtopicItem>> getSubtopics(String topicCode) async {
    try {
      final response = await _dio.get(
        '/content/topics/$topicCode/subtopics',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode != 200) return const [];
      return _readList(response.data)
          .whereType<Map<String, dynamic>>()
          .where((s) => (s['title'] as String?)?.isNotEmpty == true)
          .map((s) => SubtopicItem(
                id: s['code'].toString(),
                title: (s['title'] as String?) ?? '',
                description: (s['description'] as String?) ?? '',
                estimatedMinutes:
                    (s['estimatedMinutes'] as num?)?.toInt() ?? 0,
                orderIndex: (s['orderIndex'] as num?)?.toInt() ?? 0,
              ))
          .toList();
    } on DioException {
      return const [];
    }
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
