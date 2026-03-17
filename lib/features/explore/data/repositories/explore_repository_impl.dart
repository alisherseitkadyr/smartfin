import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_local_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreLocalDataSource _dataSource;

  const ExploreRepositoryImpl(this._dataSource);

  @override
  Future<List<TopicWithStatus>> getTopicsWithStatus() async {
    final models = await _dataSource.getTopics();
    final completed = await _dataSource.getCompletedTopicIds();
    final progress = await _dataSource.getTopicProgress();

    final topics = models.map((m) => m.toEntity()).toList();
    final completedSet = completed.toSet();

    return topics.map((topic) {
      final status = _resolveStatus(
        topic: topic,
        completedSet: completedSet,
        progressMap: progress,
      );
      return TopicWithStatus(
        topic: topic,
        status: status,
        completedSteps: progress[topic.id] ?? (completedSet.contains(topic.id) ? topic.stepCount : 0),
      );
    }).toList();
  }

  @override
  Future<List<TopicWithStatus>> searchTopics({
    String? query,
    TopicLevel? level,
  }) async {
    final all = await getTopicsWithStatus();

    return all.where((t) {
      final matchesLevel = level == null || t.topic.level == level;
      final matchesQuery = query == null ||
          query.isEmpty ||
          t.topic.title.toLowerCase().contains(query.toLowerCase()) ||
          t.topic.description.toLowerCase().contains(query.toLowerCase());
      return matchesLevel && matchesQuery;
    }).toList();
  }

  TopicStatus _resolveStatus({
    required TopicItem topic,
    required Set<String> completedSet,
    required Map<String, int> progressMap,
  }) {
    if (completedSet.contains(topic.id)) return TopicStatus.completed;

    // Check prerequisite
    if (topic.prerequisiteId != null &&
        !completedSet.contains(topic.prerequisiteId)) {
      return TopicStatus.locked;
    }

    if (progressMap.containsKey(topic.id) && (progressMap[topic.id] ?? 0) > 0) {
      return TopicStatus.inProgress;
    }

    return TopicStatus.available;
  }
}