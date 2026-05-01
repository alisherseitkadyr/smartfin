import 'package:dio/dio.dart';
import '../models/home_models.dart';

abstract class HomeRemoteDataSource {
  Future<HomeDataModel> getHomeData(String userId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio _dio;

  HomeRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<HomeDataModel> getHomeData(String userId) async {
    final topicsResponse = await _dio.get(
      '/content/topics',
      queryParameters: {'lang': 'en'},
    );

    if (topicsResponse.statusCode != 200) {
      throw Exception('Failed to load home data');
    }

    final progressData = await _loadProgress();

    final completedTopics = _readCompletedTopics(progressData);
    final progressMap = _readTopicProgress(progressData);
    final progress = progressData['progress'] as Map<String, dynamic>?;
    final totalPoints =
        (progress?['total_xp'] as num?)?.toInt() ??
        (progressData['total_points'] as num?)?.toInt() ??
        0;

    final rawItems = topicsResponse.data is List
        ? topicsResponse.data as List
        : ((topicsResponse.data as Map<String, dynamic>?)?['items'] as List? ??
              []);
    final topicItems = rawItems
        .whereType<Map<String, dynamic>>()
        .map((item) => (item['topic'] as Map<String, dynamic>?) ?? item)
        .whereType<Map<String, dynamic>>()
        .toList();

    // Find the first in-progress topic (has progress but not completed)
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

    final currentTopic = inProgressRaw != null
        ? FeaturedTopicModel(
            topicId: _topicId(inProgressRaw),
            title: inProgressRaw['title'] as String? ?? '',
            emoji: inProgressRaw['icon'] as String? ?? '📚',
            level: _capitalize(
              inProgressRaw['difficulty'] as String? ??
                  inProgressRaw['level'] as String? ??
                  'Beginner',
            ),
            xp: (inProgressRaw['xp'] as num?)?.toInt() ?? 0,
            duration: inProgressRaw['duration'] as String? ?? '',
            isInProgress: true,
            progressPercent:
                ((progressMap[inProgressId] as num?)?.toDouble() ?? 0) / 100,
          )
        : null;

    final recommended = topicItems
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
            emoji: _iconForTopic(_topicId(t)),
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

    final level = totalPoints < 100
        ? 1
        : totalPoints < 300
        ? 2
        : totalPoints < 600
        ? 3
        : totalPoints < 1000
        ? 4
        : 5;

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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _topicId(Map<String, dynamic> topic) =>
      (topic['id'] ?? topic['code'] ?? '').toString();

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
