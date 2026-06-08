import '../../../explore/domain/entities/topic_item.dart';
import '../entities/lesson_topic.dart';
import '../entities/quiz.dart';
import '../../../../../core/storage/learning_session.dart';

abstract class LearnRepository {
  Future<LessonTopic> getCurrentLesson();
  Future<LessonTopic> getLessonForTopic(String topicId);

  /// Load the lesson for one specific subtopic inside a section (topicId).
  /// Returns a LessonTopic whose steps are the subtopic's lesson steps.
  Future<LessonTopic> getLessonForSubtopic(String topicId, String subtopicId);

  /// Same as [getLessonForTopic] / [getLessonForSubtopic] but accepts an
  /// already-loaded [TopicWithStatus] so the network round-trips to
  /// /content/topics and /adaptation/learning-map can be skipped.
  Future<LessonTopic> getLessonGivenStatus(
    TopicWithStatus topicWithStatus,
    String topicId, {
    String? subtopicId,
  });

  Future<List<NearbyTopic>> getNearbyTopics(String currentTopicId);
  Future<void> setCurrentTopic(
    String topicId, {
    String? subtopicCode,
    String? subtopicTitle,
    int? stepCount,
  });
  Future<List<TopicWithStatus>> getAllTopics();
  Future<QuizStartData> startQuizByTopicCode(String topicCode);
  Future<QuizStartData> startQuizBySubtopicCode(
    String subtopicCode,
    String topicCode,
  );
  Future<QuizResult> submitQuiz(
    int attemptId,
    List<QuizAnswerInput> answers,
    int durationSeconds,
  );
  Future<void> saveSession(LearningSession session);
  LearningSession? getCurrentSession();
  Future<void> clearSession();
  Future<void> completeStep({
    required String completedStepId,
    required int currentStepIndex,
  });
  Future<void> completeSubtopic(String subtopicCode);
}
