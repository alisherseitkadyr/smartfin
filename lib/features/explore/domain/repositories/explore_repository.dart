import '../entities/topic_item.dart';
import '../entities/category.dart';

abstract class ExploreRepository {
  Future<List<TopicWithStatus>> getTopicsWithStatus();
  Future<List<TopicWithStatus>> searchTopics({String? query, TopicLevel? level});
  Future<List<SubtopicItem>> getSubtopics(String topicId);
  Future<List<CategoryWithTopics>> getCategoriesWithTopics();
  Future<void> recordTopicStarted(String topicId);
  Future<void> recordTopicCompleted(String topicId);

  /// Merge the given subtopic IDs into local completion storage for [topicId].
  /// Called after a lesson or quiz completes to reflect progress immediately,
  /// before the next backend sync.
  Future<void> markSubtopicsCompleted(String topicId, Set<String> subtopicIds);
}
