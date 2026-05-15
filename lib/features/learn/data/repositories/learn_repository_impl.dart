import 'package:smartfin/features/learn/data/datasources/learn_local_datasource.dart';

import '../../../explore/domain/entities/topic_item.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_remote_datasource.dart';
import '../../../../core/storage/learning_session.dart';

class LearnRepositoryImpl implements LearnRepository {
  final LearnRemoteDataSource _remoteDataSource;
  final LearnLocalDataSource _localDataSource;

  const LearnRepositoryImpl({
    required LearnRemoteDataSource remoteDataSource,
    required LearnLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<void> saveSession(LearningSession session) =>
      _localDataSource.saveSession(session);

  @override
  LearningSession? getCurrentSession() => _localDataSource.getCurrentSession();

  @override
  Future<void> clearSession() => _localDataSource.clearSession();

  @override
  Future<void> completeStep({
    required String completedStepId,
    required int currentStepIndex,
  }) => _localDataSource.completeStep(
    completedStepId: completedStepId,
    currentStepIndex: currentStepIndex,
  );

  @override
  Future<LessonTopic> getCurrentLesson() async {
    final session = getCurrentSession();
    if (session != null) {
      try {
        return await getLessonForTopic(session.topicId);
      } catch (_) {
        await clearSession();
      }
    }

    final topics = await getAllTopics();
    if (topics.isEmpty) throw Exception('No topics available');
    final currentTopic = topics.firstWhere(
      (topic) => !topic.isCompleted,
      orElse: () => topics.last,
    );
    return getLessonForTopic(currentTopic.topic.id);
  }

  @override
  Future<LessonTopic> getLessonForTopic(String topicId) async {
    final normalizedId = topicId.trim().toLowerCase();
    final allTopics = await _remoteDataSource.getTopicsWithStatus();
    final topicWithStatus = allTopics
        .where((t) => t.topic.id == normalizedId)
        .firstOrNull;

    if (topicWithStatus == null) {
      throw Exception('Topic not found: $topicId');
    }

    final stepModels = await _remoteDataSource.getStepsForTopic(normalizedId);
    final outcomes = await _remoteDataSource.getOutcomesForTopic(normalizedId);
    final progress = await _remoteDataSource.getTopicProgress();

    final remoteProgress = progress[normalizedId] ?? 0;
    final localSession = getCurrentSession();
    final localProgress = localSession?.topicId == normalizedId
        ? _maxInt(
            localSession!.currentStepIndex,
            localSession.completedStepIds.length,
          )
        : 0;
    final completedSteps = topicWithStatus.isCompleted
        ? stepModels.length
        : _clampPageIndex(
            _maxInt(
              _maxInt(remoteProgress, topicWithStatus.completedSteps),
              localProgress,
            ),
            stepModels.length,
          );

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
    final all = await _remoteDataSource.getTopicsWithStatus();
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
    final lesson = await getLessonForTopic(topicId);
    final existingSession = getCurrentSession();

    if (existingSession?.topicId == lesson.topic.id &&
        existingSession!.currentStepIndex < lesson.steps.length) {
      existingSession.updatedAt = DateTime.now();
      await saveSession(existingSession);
      return;
    }

    final now = DateTime.now();
    final currentStepIndex = lesson.isCompleted
        ? 0
        : _clampPageIndex(lesson.completedSteps, lesson.steps.length);
    final pageIndex = _clampPageIndex(currentStepIndex, lesson.steps.length);
    await saveSession(
      LearningSession(
        topicId: lesson.topic.id,
        subtopicCode: lesson.steps.isEmpty ? '' : lesson.steps[pageIndex].id,
        currentStepIndex: currentStepIndex,
        completedStepIds: <String>[],
        startedAt: now,
        updatedAt: now,
        synced: false,
      ),
    );
  }

  @override
  Future<List<TopicWithStatus>> getAllTopics() =>
      _remoteDataSource.getTopicsWithStatus();

  @override
  Future<QuizStartData> startQuizByTopicCode(String topicCode) =>
      _remoteDataSource.startQuizByTopicCode(topicCode);

  @override
  Future<QuizResult> submitQuiz(
    int attemptId,
    List<QuizAnswerInput> answers,
    int durationSeconds,
  ) => _remoteDataSource.submitQuiz(attemptId, answers, durationSeconds);

  int _clampPageIndex(int value, int stepCount) {
    if (stepCount <= 0) return 0;
    if (value < 0) return 0;
    if (value >= stepCount) return stepCount - 1;
    return value;
  }

  int _maxInt(int a, int b) => a > b ? a : b;
}
