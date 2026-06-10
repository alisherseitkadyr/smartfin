import 'package:dio/dio.dart';
import '../models/home_models.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> getHomeData(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;
  final String _languageCode;

  HomeRemoteDataSourceImpl({
    required Dio dio,
    required String languageCode,
  })  : _dio = dio,
        _languageCode = languageCode;

  @override
  Future<HomeDataModel> getHomeData(String userId) async {
    // All three requests fire concurrently.
    final topicsRequest = _dio.get(
      '/content/topics',
      queryParameters: {'lang': _languageCode},
    );
    final progressRequest = _loadProgress();
    final adaptationRequest = _loadAdaptationRecommendations();

    final topicsResponse = await topicsRequest;
    final progressData = await progressRequest;
    final adaptationData = await adaptationRequest;

    if (topicsResponse.statusCode != 200) {
      throw Exception('Failed to load home data');
    }

    final rawItems = topicsResponse.data is List
        ? topicsResponse.data as List
        : ((topicsResponse.data as Map<String, dynamic>?)?['items'] as List? ?? []);
    final topicItems = rawItems
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['topic'] as Map<String, dynamic>?) ?? item)
        .whereType<Map<String, dynamic>>()
        .toList();

    // Build a fast lookup keyed by both numeric id and string code so that
    // lookups work regardless of which identifier the caller uses.
    final topicLookup = <String, Map<String, dynamic>>{};
    for (final t in topicItems) {
      final id = (t['id'] ?? '').toString();
      final code = (t['code'] ?? '').toString();
      if (id.isNotEmpty) topicLookup[id] = t;
      if (code.isNotEmpty) topicLookup[code] = t;
    }

    final completedTopics = _readCompletedTopics(progressData);
    final progressMap = _readTopicProgress(progressData);
    final progress = progressData['progress'] as Map<String, dynamic>?;
    final totalPoints =
        (progress?['total_xp'] as num?)?.toInt() ??
        (progressData['total_points'] as num?)?.toInt() ??
        0;

    // ── Try ML-ranked recommendations first ──────────────────────
    final adaptationState = adaptationData['state'] as String? ?? '';
    FeaturedTopicModel? currentTopic;
    List<FeaturedTopicModel> recommended;

    if (adaptationState == 'HAS_RECOMMENDATIONS') {
      currentTopic = _buildCurrentTopicFromAdaptation(
        adaptationData['continueLearning'] as Map<String, dynamic>?,
        topicLookup,
        progressMap,
      );

      final rawRecommended =
          (adaptationData['recommended'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [];

      recommended = rawRecommended.map((item) {
        final topicCode = item['topicCode'] as String? ?? '';
        final subtopicCode = item['subtopicCode'] as String?;
        final subtopicTitle = item['title'] as String?;
        final raw = topicLookup[topicCode];

        return FeaturedTopicModel(
          topicId: topicCode,
          title: raw?['title'] as String? ?? topicCode,
          emoji: raw?['icon'] as String? ?? '📚',
          iconPath: raw?['icon_path'] as String?,
          level: _capitalize(raw?['level'] as String? ?? 'beginner'),
          xp: (raw?['xp'] as num?)?.toInt() ?? 0,
          duration: raw?['duration'] as String? ?? '5 min',
          isInProgress: false,
          progressPercent: 0,
          subtopicId: subtopicCode,
          subtopicTitle: subtopicTitle,
        );
      }).toList();
    } else {
      // ── Fallback: static filtering by completion status ──────────
      final inProgressId = progressMap.keys
          .where((id) => !completedTopics.contains(id))
          .firstOrNull;

      Map<String, dynamic>? inProgressRaw;
      if (inProgressId != null) {
        try {
          inProgressRaw = topicItems.firstWhere(
            (t) => _topicId(t) == inProgressId,
          );
        } catch (_) {}
      }

      currentTopic = inProgressRaw != null
          ? FeaturedTopicModel(
              topicId: _topicId(inProgressRaw),
              title: inProgressRaw['title'] as String? ?? '',
              emoji: inProgressRaw['icon'] as String? ?? '📚',
              iconPath: inProgressRaw['icon_path'] as String?,
              level: _capitalize(
                inProgressRaw['difficulty'] as String? ??
                    inProgressRaw['level'] as String? ??
                    'Beginner',
              ),
              xp: (inProgressRaw['xp'] as num?)?.toInt() ?? 0,
              duration: inProgressRaw['duration'] as String? ?? '',
              isInProgress: true,
              progressPercent: _topicProgressPercent(progressMap[inProgressId]),
            )
          : null;

      recommended = topicItems
          .where(
            (t) =>
                !completedTopics.contains(_topicId(t)) &&
                _topicId(t) != inProgressId,
          )
          .take(3)
          .map(
            (t) => FeaturedTopicModel(
              topicId: _topicId(t),
              title: t['title'] as String? ?? '',
              emoji: t['icon'] as String? ?? '📚',
              iconPath: t['icon_path'] as String?,
              level: _capitalize(
                t['difficulty'] as String? ?? t['level'] as String? ?? 'Beginner',
              ),
              xp: (t['xp'] as num?)?.toInt() ?? 0,
              duration: t['duration'] as String? ?? '5 min',
              isInProgress: false,
              progressPercent: 0,
            ),
          )
          .toList();
    }

    final level = totalPoints < 100
        ? 1
        : totalPoints < 300
        ? 2
        : totalPoints < 600
        ? 3
        : totalPoints < 1000
        ? 4
        : 5;

    // ── Repeat topics: completed topics for review (up to 5) ────
    final currentTopicId = currentTopic?.topicId ?? '';
    final repeatTopics = completedTopics
        .where((id) => id != currentTopicId)
        .map((id) {
          final raw = topicLookup[id];
          if (raw == null) return null;
          return FeaturedTopicModel(
            topicId: id,
            title: raw['title'] as String? ?? id,
            emoji: raw['icon'] as String? ?? '📚',
            iconPath: raw['icon_path'] as String?,
            level: _capitalize(raw['level'] as String? ?? 'beginner'),
            xp: (raw['xp'] as num?)?.toInt() ?? 0,
            duration: raw['duration'] as String? ?? '5 min',
            isInProgress: false,
            progressPercent: 1.0,
          );
        })
        .whereType<FeaturedTopicModel>()
        .take(5)
        .toList();

    return HomeDataModel(
      user: UserSummaryModel(
        name: 'User',
        totalXp: totalPoints,
        level: level,
        streakDays: 0,
        completedTopics: completedTopics.length,
        totalTopics: topicItems.length,
      ),
      currentTopic: currentTopic,
      recommendedTopics: recommended,
      repeatTopics: repeatTopics,
      snapshot: const MonthlySnapshotModel(
        totalSpent: 0,
        totalSaved: 0,
        currency: '₸',
        monthLabel: '',
        spentChangePercent: 0,
        savedChangePercent: 0,
      ),
      quickActions: const [
        QuickActionModel(
          id: 'learn',
          label: 'Continue\nLearning',
          emoji: '📚',
          route: '/learn',
        ),
        QuickActionModel(
          id: 'expenses',
          label: 'Track\nExpenses',
          emoji: '💳',
          route: '/expenses',
        ),
        QuickActionModel(
          id: 'explore',
          label: 'Explore\nTopics',
          emoji: '🔭',
          route: '/explore',
        ),
        QuickActionModel(
          id: 'quiz',
          label: 'Daily\nQuiz',
          emoji: '🎯',
          route: '/quiz',
        ),
      ],
    );
  }

  FeaturedTopicModel? _buildCurrentTopicFromAdaptation(
    Map<String, dynamic>? action,
    Map<String, Map<String, dynamic>> topicLookup,
    Map<String, dynamic> progressMap,
  ) {
    if (action == null) return null;

    final topicCode = action['topicCode'] as String? ?? '';
    if (topicCode.isEmpty) return null;

    final subtopicCode = action['subtopicCode'] as String?;
    final subtopicTitle = action['title'] as String?;
    final raw = topicLookup[topicCode];
    final rawProgress = progressMap[topicCode];

    return FeaturedTopicModel(
      topicId: topicCode,
      title: raw?['title'] as String? ?? topicCode,
      emoji: raw?['icon'] as String? ?? '📚',
      iconPath: raw?['icon_path'] as String?,
      level: _capitalize(raw?['level'] as String? ?? 'beginner'),
      xp: (raw?['xp'] as num?)?.toInt() ?? 0,
      duration: raw?['duration'] as String? ?? '',
      isInProgress: true,
      progressPercent: _topicProgressPercent(rawProgress),
      subtopicId: subtopicCode,
      subtopicTitle: subtopicTitle,
    );
  }

  Future<Map<String, dynamic>> _loadAdaptationRecommendations() async {
    try {
      final response = await _dio.get(
        '/adaptation/recommendations/home',
        queryParameters: {'lang': _languageCode},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException {
      return {};
    }
    return {};
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _topicId(Map<String, dynamic> topic) =>
      (topic['code'] ?? topic['id'] ?? '').toString();

  double _topicProgressPercent(dynamic topicProgress) {
    if (topicProgress is Map<String, dynamic>) {
      final read = (topicProgress['subtopics_read'] as num?)?.toInt() ?? 0;
      final total = (topicProgress['total_subtopics'] as num?)?.toInt() ?? 1;
      return total > 0 ? read / total : 0.0;
    }
    if (topicProgress is num) return topicProgress.toDouble() / 100;
    return 0.0;
  }

  Future<Map<String, dynamic>> _loadProgress() async {
    try {
      final response = await _dio.get('/progress/me');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    } on DioException {
      return {};
    }
    return {};
  }

  List<String> _readCompletedTopics(Map<String, dynamic> data) {
    final completed = data['completed_topics'];
    if (completed is List) return completed.map((id) => id.toString()).toList();
    return const [];
  }

  Map<String, dynamic> _readTopicProgress(Map<String, dynamic> data) {
    final progress = data['progress'];
    if (progress is Map<String, dynamic>) {
      final topics = progress['topics'];
      if (topics is Map<String, dynamic>) return topics;
    }
    return const {};
  }
}
