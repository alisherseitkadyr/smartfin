import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    // Primary: /progress/me returns completed_topics from topic_final_quiz >= 75%,
    // which matches what the app actually records (one final quiz per topic).
    try {
      final response = await _dio.get('/progress/me');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final completed = (response.data as Map<String, dynamic>)['completed_topics'];
        if (completed is List) {
          return completed.map((e) => e.toString()).toList();
        }
      }
    } on DioException {
      // fall through to adaptation fallback
    }
    // Fallback: adaptation learning map (works when subtopic quizzes are used)
    try {
      final map = await _fetchLearningMap();
      return map.entries
          .where((e) => e.value['status'] == 'COMPLETED')
          .map((e) => e.key)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, int>> getTopicProgress(String userId) async {
    // Primary: /progress/me progress.topics has subtopic-level completion counts.
    try {
      final response = await _dio.get('/progress/me');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final topics = (data['progress'] as Map<String, dynamic>?)?['topics'];
        if (topics is Map<String, dynamic> && topics.isNotEmpty) {
          return topics.map((k, v) {
            if (v is Map<String, dynamic>) {
              return MapEntry(k, (v['subtopics_read'] as num?)?.toInt() ?? 0);
            }
            return MapEntry(k, (v as num?)?.toInt() ?? 0);
          });
        }
      }
    } on DioException {
      // fall through
    }
    // Fallback: adaptation learning map completedSubtopics
    try {
      final map = await _fetchLearningMap();
      final result = <String, int>{};
      for (final entry in map.entries) {
        final completed = (entry.value['completedSubtopics'] as num?)?.toInt() ?? 0;
        if (completed > 0) result[entry.key] = completed;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, Map<String, dynamic>>> _fetchLearningMap() async {
    final response = await _dio.get(
      '/adaptation/learning-map',
      queryParameters: {'lang': _languageCode},
    );
    if (response.statusCode != 200) return {};
    final topics = (response.data?['topics'] as List?)
            ?.whereType<Map<String, dynamic>>() ??
        [];
    debugPrint('[Explore] learning-map raw topics: ${topics.map((t) => {
          'code': t['code'],
          'status': t['status'],
          'completedSubtopics': t['completedSubtopics'],
        }).toList()}');
    return {
      for (final t in topics)
        if (t['code'] != null) t['code'].toString(): t
    };
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

    // Capture ordered subtopic codes so the repository can map
    // the backend's completion count to actual subtopic IDs.
    final subtopicIds = subtopics
        .map((s) => (s['code'] ?? '').toString())
        .where((c) => c.isNotEmpty)
        .toList();

    return TopicItemModel.fromJson({
      ...topic,
      'id': topicCode,
      'duration': totalMinutes == 0 ? '5 min' : '$totalMinutes min',
      'stepCount': stepCount,
      'xp': _xpForLevel(topic['level'] as String?),
      'icon': _iconForTopic(topicCode),
      'subtopicIds': subtopicIds,
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
