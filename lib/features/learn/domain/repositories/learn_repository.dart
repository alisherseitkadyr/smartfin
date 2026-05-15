import '../../../explore/domain/entities/topic_item.dart';
import '../entities/lesson_topic.dart';
import '../entities/quiz.dart';
import '../../../../../core/storage/learning_session.dart';

abstract class LearnRepository {
  Future<LessonTopic> getCurrentLesson();
  Future<LessonTopic> getLessonForTopic(String topicId);
  Future<List<NearbyTopic>> getNearbyTopics(String currentTopicId);
  Future<void> setCurrentTopic(String topicId);
  Future<List<TopicWithStatus>> getAllTopics();
  Future<QuizStartData> startQuizByTopicCode(String topicCode);
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
}