import '../../../../core/storage/learning_session_storage.dart';
import '../../../../core/storage/subtopic_progress_storage.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/topic_item.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_remote_datasource.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreRemoteDataSource _remoteDataSource;
  final LearningSessionStorage? _sessionStorage;
  final SubtopicProgressStorage _subtopicStorage;

  ExploreRepositoryImpl({
    required ExploreRemoteDataSource remoteDataSource,
    LearningSessionStorage? sessionStorage,
    required SubtopicProgressStorage subtopicStorage,
  })  : _remoteDataSource = remoteDataSource,
        _sessionStorage = sessionStorage,
        _subtopicStorage = subtopicStorage;

  @override
  Future<List<TopicWithStatus>> getTopicsWithStatus() async {
    final models = await _remoteDataSource.getTopics();

    final completedIds = Set<String>.from(
      await _remoteDataSource.getCompletedTopicIds('current_user'),
    );
    final progressMap = Map<String, int>.from(
      await _remoteDataSource.getTopicProgress('current_user'),
    );

    final session = _sessionStorage?.getCurrentSession();

    final result = <TopicWithStatus>[];
    for (final model in models) {
      final topic = model.toEntity();
      final isCompleted = completedIds.contains(topic.id);
      final backendCount = progressMap[topic.id] ?? (isCompleted ? topic.stepCount : 0);

      final completedSubtopicIds = _resolveCompletedSubtopicIds(
        topicId: topic.id,
        isCompleted: isCompleted,
        backendCount: backendCount,
        orderedSubtopicIds: model.subtopicIds,
      );

      // Persist to local Hive so the UI can read it without a network call.
      if (completedSubtopicIds.isNotEmpty) {
        await _subtopicStorage.saveCompletedSubtopicIds(
          topic.id,
          completedSubtopicIds,
        );
      }

      var status = _resolveStatus(
        topic: topic,
        completedSet: completedIds,
        progressMap: progressMap,
      );

      // Mark as inProgress if there is an active session for this topic.
      if (session != null &&
          session.topicId == topic.id &&
          status == TopicStatus.available) {
        status = TopicStatus.inProgress;
      }

      result.add(
        TopicWithStatus(
          topic: topic,
          status: status,
          completedSubtopicIds: completedSubtopicIds,
        ),
      );
    }

    return result;
  }

  /// Derive which subtopic IDs are completed.
  /// Backend gives only a count; we map it to the first N ordered IDs.
  /// Falls back to local Hive storage when it has more entries than the backend.
  Set<String> _resolveCompletedSubtopicIds({
    required String topicId,
    required bool isCompleted,
    required int backendCount,
    required List<String> orderedSubtopicIds,
  }) {
    final Set<String> fromBackend = isCompleted
        ? orderedSubtopicIds.toSet()
        : orderedSubtopicIds.take(backendCount).toSet();

    final fromLocal = _subtopicStorage.getCompletedSubtopicIds(topicId);

    // Use whichever source knows about more completed subtopics.
    return fromLocal.length > fromBackend.length ? fromLocal : fromBackend;
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
  Future<List<SubtopicItem>> getSubtopics(String topicId) =>
      _remoteDataSource.getSubtopics(topicId);

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
    // Backend updates via assessment submits; no direct progress endpoint.
  }

  @override
  Future<void> recordTopicCompleted(String topicId) async {
    // Backend updates via quiz submission. Clear local cache so the next
    // getTopicsWithStatus fetch from backend is the authority.
  }

  @override
  Future<void> markSubtopicsCompleted(
    String topicId,
    Set<String> subtopicIds,
  ) async {
    final existing = _subtopicStorage.getCompletedSubtopicIds(topicId);
    final merged = {...existing, ...subtopicIds};
    await _subtopicStorage.saveCompletedSubtopicIds(topicId, merged);
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
