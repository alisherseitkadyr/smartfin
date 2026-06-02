import 'package:afine/features/learn/data/datasources/learn_local_datasource.dart';

import '../../../explore/domain/entities/topic_item.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/learn_repository.dart';
import '../datasources/learn_remote_datasource.dart';
import '../models/lesson_step_model.dart';
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
      // Try the most specific path first, degrade gracefully before giving up.
      if (session.subtopicCode.isNotEmpty) {
        try {
          return await getLessonForSubtopic(
            session.topicId,
            session.subtopicCode,
          );
        } catch (_) {
          // Subtopic unavailable — fall through to topic-level attempt.
        }
      }
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
    final results = await Future.wait([
      _remoteDataSource.getTopicsWithStatus(),
      _remoteDataSource.getStepsForTopic(normalizedId),
      _remoteDataSource.getTopicProgress(),
    ]);
    final allTopics = results[0] as List<TopicWithStatus>;
    final stepModels = results[1] as List<LessonStepModel>;
    final progress = results[2] as Map<String, int>;

    final topicWithStatus = allTopics
        .where((t) => t.topic.id == normalizedId)
        .firstOrNull;

    if (topicWithStatus == null) {
      throw Exception('Topic not found: $topicId');
    }

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
      completedSteps: completedSteps,
      status: topicWithStatus.status,
      subtopicCode: _remoteDataSource.firstSubtopicCode(normalizedId),
    );
  }

  @override
  Future<LessonTopic> getLessonForSubtopic(
    String topicId,
    String subtopicId,
  ) async {
    final normalizedTopicId = topicId.trim().toLowerCase();
    final normalizedSubtopicId = subtopicId.trim().toLowerCase();

    final results = await Future.wait([
      _remoteDataSource.getTopicsWithStatus(),
      _remoteDataSource.getStepsForSubtopic(normalizedSubtopicId),
    ]);
    final allTopics = results[0] as List<TopicWithStatus>;
    final stepModels = results[1] as List<LessonStepModel>;

    final topicWithStatus = allTopics
        .where((t) => t.topic.id == normalizedTopicId)
        .firstOrNull;

    if (topicWithStatus == null) {
      throw Exception('Topic not found: $topicId');
    }

    // Resume from local session if it's for this exact subtopic.
    final localSession = getCurrentSession();
    final localProgress =
        localSession?.topicId == normalizedTopicId &&
                localSession?.subtopicCode == normalizedSubtopicId
            ? _maxInt(
                localSession!.currentStepIndex,
                localSession.completedStepIds.length,
              )
            : 0;

    final completedSteps = _clampPageIndex(localProgress, stepModels.length);

    return LessonTopic(
      topic: topicWithStatus.topic,
      steps: stepModels.map((m) => m.toEntity()).toList(),
      completedSteps: completedSteps,
      status: topicWithStatus.status,
      subtopicCode: normalizedSubtopicId,
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
  Future<void> setCurrentTopic(String topicId, {String? subtopicCode}) async {
    final lesson = await getLessonForTopic(topicId);
    final existingSession = getCurrentSession();
    final resolvedSubtopicCode = subtopicCode ?? lesson.subtopicCode ?? '';

    // Reuse the existing session only when both topic AND subtopic match —
    // this preserves step progress when the user resumes mid-lesson.
    if (existingSession?.topicId == lesson.topic.id &&
        existingSession?.subtopicCode == resolvedSubtopicCode &&
        existingSession!.currentStepIndex < lesson.steps.length) {
      existingSession.updatedAt = DateTime.now();
      await saveSession(existingSession);
      return;
    }

    final now = DateTime.now();
    await saveSession(
      LearningSession(
        topicId: lesson.topic.id,
        subtopicCode: resolvedSubtopicCode,
        currentStepIndex: 0,
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
  Future<QuizStartData> startQuizBySubtopicCode(
    String subtopicCode,
    String topicCode,
  ) => _remoteDataSource.startQuizBySubtopicCode(subtopicCode, topicCode);

  @override
  Future<QuizResult> submitQuiz(
    int attemptId,
    List<QuizAnswerInput> answers,
    int durationSeconds,
  ) => _remoteDataSource.submitQuiz(attemptId, answers, durationSeconds);

  @override
  Future<void> completeSubtopic(String subtopicCode) =>
      _remoteDataSource.completeSubtopic(subtopicCode);

  int _clampPageIndex(int value, int stepCount) {
    if (stepCount <= 0) return 0;
    if (value < 0) return 0;
    if (value >= stepCount) return stepCount - 1;
    return value;
  }

  int _maxInt(int a, int b) => a > b ? a : b;
}
