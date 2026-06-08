import '../entities/topic_item.dart';
import '../entities/explore_section.dart';

abstract class ExploreRepository {
  Future<List<SubtopicItem>> getSubtopics(String topicId);

  /// Merge the given subtopic IDs into local completion storage for [topicId].
  /// Called after a lesson or quiz completes to reflect progress immediately,
  /// before the next backend sync.
  Future<void> markSubtopicsCompleted(String topicId, Set<String> subtopicIds);

  /// Fetch all sections with nested topics and per-user progress from the backend.
  Future<List<ExploreSection>> getSections();
}
