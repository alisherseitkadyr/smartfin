import '../../../explore/data/datasources/explore_remote_datasource.dart';
import '../../../explore/data/repositories/explore_repository_impl.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_remote_datasource.dart';

class LearnRepositoryImpl implements LearnRepository {
  final LearnRemoteDataSource _remoteDataSource;
  final ExploreRemoteDataSource _exploreRemoteDataSource;

  const LearnRepositoryImpl({
    required LearnRemoteDataSource remoteDataSource,
    required ExploreRemoteDataSource exploreRemoteDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _exploreRemoteDataSource = exploreRemoteDataSource;

  @override
  Future<LessonTopic> getCurrentLesson() async {
    final topics = await getAllTopics();
    if (topics.isEmpty) {
      throw Exception('No topics available');
    }
    return getLessonForTopic(topics.first.topic.id);
  }

  @override
  Future<LessonTopic> getLessonForTopic(String topicId) async {
    final normalizedTopicId = _normalizeTopicId(topicId);
    final exploreRepo = ExploreRepositoryImpl(
      remoteDataSource: _exploreRemoteDataSource,
    );
    final allTopics = await exploreRepo.getTopicsWithStatus();
    final topicWithStatus = allTopics
        .where((t) => t.topic.id == normalizedTopicId)
        .firstOrNull;

    if (topicWithStatus == null) {
      throw Exception('Topic not found: $topicId');
    }

    final stepModels = await _remoteDataSource.getStepsForTopic(
      normalizedTopicId,
    );
    final outcomes = await _remoteDataSource.getOutcomesForTopic(
      normalizedTopicId,
    );
    final progress = await _remoteDataSource.getTopicProgress('current_user');

    final completedSteps = topicWithStatus.isCompleted
        ? stepModels.length
        : (progress[normalizedTopicId] ?? 0);

    return LessonTopic(
      topic: topicWithStatus.topic,
      steps: stepModels.map((m) => m.toEntity()).toList(),
      outcomes: outcomes,
      completedSteps: completedSteps,
      status: topicWithStatus.status,
    );
  }

  @override
  Future<List<NearbyTopic>> getNearbyTopics(String currentTopicId) async {
    final exploreRepo = ExploreRepositoryImpl(
      remoteDataSource: _exploreRemoteDataSource,
    );
    final all = await exploreRepo.getTopicsWithStatus();

    final seen = <String>{};
    return all
        .where((t) {
          if (t.topic.id == currentTopicId || seen.contains(t.topic.id)) {
            return false;
          }
          seen.add(t.topic.id);
          return true;
        })
        .take(5)
        .map((t) => NearbyTopic(topic: t.topic, status: t.status))
        .toList();
  }

  @override
  Future<void> setCurrentTopic(String topicId) async {}

  @override
  Future<List<TopicWithStatus>> getAllTopics() async {
    final exploreRepo = ExploreRepositoryImpl(
      remoteDataSource: _exploreRemoteDataSource,
    );
    return exploreRepo.getTopicsWithStatus();
  }

  String _normalizeTopicId(String topicId) {
    switch (topicId) {
      case 'saving':
        return 'savings';
      case 'investing':
        return 'investments';
      case 'credit':
      case 'debt':
        return 'credit_and_debt';
      default:
        return topicId;
    }
  }
}
