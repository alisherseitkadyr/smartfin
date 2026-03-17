import '../entities/topic_item.dart';

abstract class ExploreRepository {
  /// Returns all topics enriched with the user's current status.
  Future<List<TopicWithStatus>> getTopicsWithStatus();

  /// Returns topics filtered by level and/or a search query.
  Future<List<TopicWithStatus>> searchTopics({
    String? query,
    TopicLevel? level,
  });
}