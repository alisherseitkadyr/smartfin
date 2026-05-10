import '../entities/topic_item.dart';
import '../entities/category.dart';
abstract class ExploreRepository {
  Future<List<TopicWithStatus>> getTopicsWithStatus();
  Future<List<TopicWithStatus>> searchTopics({String? query, TopicLevel? level});
  Future<List<SubtopicItem>> getSubtopics(String topicId);
  Future<List<CategoryWithTopics>> getCategoriesWithTopics();
  Future<void> recordTopicStarted(String topicId);
  Future<void> recordTopicCompleted(String topicId);
}

