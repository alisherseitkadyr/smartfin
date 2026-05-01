import '../../domain/entities/category.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _remoteDataSource;

  const ExploreRepositoryImpl({
    required ExploreRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TopicWithStatus>> getTopicsWithStatus() async {
    final models = await _remoteDataSource.getTopics();
    final completed = List<String>.from(
      await _remoteDataSource.getCompletedTopicIds('current_user'),
    );
    final progress = Map<String, int>.from(
      await _remoteDataSource.getTopicProgress('current_user'),
    );

    final topics = models.map((m) => (m as dynamic).toEntity()).toList();
    final completedSet = completed.toSet();

    final result = topics.map((topic) {
      final status = _resolveStatus(
        topic: topic,
        completedSet: completedSet,
        progressMap: progress,
      );
      return TopicWithStatus(
        topic: topic,
        status: status,
        completedSteps:
            progress[topic.id] ??
            (completedSet.contains(topic.id) ? topic.stepCount : 0),
      );
    }).toList();

    return List<TopicWithStatus>.from(result);
  }

  @override
  Future<List<TopicWithStatus>> searchTopics({
    String? query,
    TopicLevel? level,
  }) async {
    final all = await getTopicsWithStatus();
    return all.where((t) {
      final matchesLevel = level == null || t.topic.level == level;
      final matchesQuery =
          query == null ||
          query.isEmpty ||
          t.topic.title.toLowerCase().contains(query.toLowerCase()) ||
          t.topic.description.toLowerCase().contains(query.toLowerCase());
      return matchesLevel && matchesQuery;
    }).toList();
  }

  @override
  Future<List<CategoryWithTopics>> getCategoriesWithTopics() async {
    final allTopics = await getTopicsWithStatus();
    return TopicLevel.values
        .map((level) {
          final topics = allTopics
              .where((topic) => topic.topic.level == level)
              .toList();
          if (topics.isEmpty) return null;

          return CategoryWithTopics(
            category: Category(
              id: level.name,
              title: level.label,
              description: _descriptionForLevel(level),
              icon: level.emoji,
              color: _colorForLevel(level),
              topicIds: topics.map((topic) => topic.topic.id).toList(),
            ),
            topics: topics,
          );
        })
        .whereType<CategoryWithTopics>()
        .toList();
  }

  @override
  Future<void> recordTopicStarted(String topicId) async {
    try {
      await _remoteDataSource.updateProgress(
        'current_user',
        topicId,
        'in_progress',
      );
    } catch (_) {}
  }

  @override
  Future<void> recordTopicCompleted(String topicId) async {
    try {
      await _remoteDataSource.updateProgress(
        'current_user',
        topicId,
        'completed',
      );
    } catch (_) {}
  }

  TopicStatus _resolveStatus({
    required TopicItem topic,
    required Set<String> completedSet,
    required Map<String, int> progressMap,
  }) {
    if (completedSet.contains(topic.id)) return TopicStatus.completed;
    if (topic.prerequisiteId != null &&
        !completedSet.contains(topic.prerequisiteId)) {
      return TopicStatus.locked;
    }
    if (progressMap.containsKey(topic.id) && (progressMap[topic.id] ?? 0) > 0) {
      return TopicStatus.inProgress;
    }
    return TopicStatus.available;
  }

  String _descriptionForLevel(TopicLevel level) {
    switch (level) {
      case TopicLevel.beginner:
        return 'Start with the core financial habits and concepts.';
      case TopicLevel.intermediate:
        return 'Build stronger money decisions with practical scenarios.';
      case TopicLevel.advanced:
        return 'Go deeper into long-term planning and wealth building.';
    }
  }

  CategoryColor _colorForLevel(TopicLevel level) {
    switch (level) {
      case TopicLevel.beginner:
        return CategoryColor.green;
      case TopicLevel.intermediate:
        return CategoryColor.blue;
      case TopicLevel.advanced:
        return CategoryColor.navy;
    }
  }
}
