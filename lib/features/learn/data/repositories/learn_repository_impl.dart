import '../../../explore/data/datasources/explore_local_datasource.dart';
import '../../../explore/data/repositories/explore_repository_impl.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_local_datasource.dart';

class LearnRepositoryImpl implements LearnRepository {
  final LearnLocalDataSource _learnDataSource;
  final ExploreLocalDataSource _exploreDataSource;

  const LearnRepositoryImpl({
    required LearnLocalDataSource learnDataSource,
    required ExploreLocalDataSource exploreDataSource,
  })  : _learnDataSource = learnDataSource,
        _exploreDataSource = exploreDataSource;

  @override
  Future<LessonTopic> getCurrentLesson() async {
    final topicId = await _learnDataSource.getCurrentTopicId();
    return getLessonForTopic(topicId);
  }

  @override
  Future<LessonTopic> getLessonForTopic(String topicId) async {
    final exploreRepo = ExploreRepositoryImpl(_exploreDataSource);
    final allTopics = await exploreRepo.getTopicsWithStatus();
    final topicWithStatus = allTopics.firstWhere(
      (t) => t.topic.id == topicId,
      orElse: () => allTopics.first,
    );

    final stepModels = await _learnDataSource.getStepsForTopic(topicId);
    final outcomes = await _learnDataSource.getOutcomesForTopic(topicId);
    final progress = await _learnDataSource.getTopicProgress();

    final completedSteps = topicWithStatus.isCompleted
        ? stepModels.length
        : (progress[topicId] ?? 0);

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
    final exploreRepo = ExploreRepositoryImpl(_exploreDataSource);
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
  Future<void> setCurrentTopic(String topicId) async {
    await _learnDataSource.setCurrentTopicId(topicId);
  }

  @override
  Future<List<TopicWithStatus>> getAllTopics() async {
    final exploreRepo = ExploreRepositoryImpl(_exploreDataSource);
    return exploreRepo.getTopicsWithStatus();
  }
}