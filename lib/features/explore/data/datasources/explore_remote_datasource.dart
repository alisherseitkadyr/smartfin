import 'dart:async';

import 'package:dio/dio.dart';
import '../../../../core/storage/curriculum_cache.dart';
import '../../domain/entities/topic_item.dart';
import '../models/topic_item_model.dart';
import '../models/section_model.dart';

abstract class ExploreRemoteDataSource {
  Future<List<TopicItemModel>> getTopics();
  Future<List<SubtopicItem>> getSubtopics(String topicId);
  Future<List<ExploreSectionModel>> getExploreView();
}

class ExploreRemoteDataSourceImpl implements ExploreRemoteDataSource {
  final Dio _dio;
  final String _languageCode;

  ExploreRemoteDataSourceImpl({
    required Dio dio,
    required String languageCode,
  })  : _dio = dio,
        _languageCode = languageCode;

  final Map<String, List<Map<String, dynamic>>> _subtopicCache = {};

  final _curriculumCache = CurriculumCache();

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
    final raw = await _getSubtopics(topicCode);
    return raw
        .where((s) => (s['title'] as String?)?.isNotEmpty == true)
        .map((s) => SubtopicItem(
              id: s['code'].toString(),
              title: (s['title'] as String?) ?? '',
              description: (s['description'] as String?) ?? '',
              estimatedMinutes: (s['estimatedMinutes'] as num?)?.toInt() ?? 0,
              orderIndex: (s['orderIndex'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getSubtopics(String topicCode) async {
    final cached = _subtopicCache[topicCode];
    if (cached != null) return cached;
    try {
      final response = await _dio.get(
        '/content/topics/$topicCode/subtopics',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode != 200) return const [];
      final result = _readList(response.data)
          .whereType<Map<String, dynamic>>()
          .toList();
      _subtopicCache[topicCode] = result;
      return result;
    } on DioException {
      return const [];
    }
  }

  @override
  Future<List<ExploreSectionModel>> getExploreView() async {
    try {
      final response = await _dio.get(
        '/content/explore',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode == 200) {
        final rawList = ((response.data['sections'] as List?) ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();
        final sections = rawList.map(ExploreSectionModel.fromJson).toList();
        unawaited(_curriculumCache.save(_languageCode, rawList));
        return sections;
      }
    } on DioException {
      // fall through to offline cache
    }
    final hiveRaw = _curriculumCache.getIfFresh(_languageCode);
    if (hiveRaw != null) {
      return hiveRaw.map(ExploreSectionModel.fromJson).toList();
    }
    throw Exception('Failed to load explore view');
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
