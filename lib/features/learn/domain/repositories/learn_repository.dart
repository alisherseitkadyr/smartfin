import '../../../explore/domain/entities/topic_item.dart';
import '../entities/lesson_topic.dart';

abstract class LearnRepository {
  /// Returns the current topic enriched with steps, outcomes, and progress.
  Future<LessonTopic> getCurrentLesson();

  /// Returns a specific topic by id.
  Future<LessonTopic> getLessonForTopic(String topicId);

  /// Returns nearby/related topics for the "Up next" section.
  Future<List<NearbyTopic>> getNearbyTopics(String currentTopicId);

  /// Switches the current active topic.
  Future<void> setCurrentTopic(String topicId);

  /// Returns all topics with status (delegated from explore).
  Future<List<TopicWithStatus>> getAllTopics();
} 