import '../../../explore/domain/entities/topic_item.dart';
import '../entities/lesson_topic.dart';
import '../repositories/learn_repository.dart';
import '../../../../../core/storage/learning_session.dart';

class GetCurrentLesson {
  final LearnRepository _repository;
  const GetCurrentLesson(this._repository);

  Future<LessonTopic> call() => _repository.getCurrentLesson();
}

class GetLessonForTopic {
  final LearnRepository _repository;
  const GetLessonForTopic(this._repository);

  Future<LessonTopic> call(String topicId) =>
      _repository.getLessonForTopic(topicId);
}

class GetLessonForSubtopic {
  final LearnRepository _repository;
  const GetLessonForSubtopic(this._repository);

  Future<LessonTopic> call(String topicId, String subtopicId) =>
      _repository.getLessonForSubtopic(topicId, subtopicId);
}

class GetNearbyTopics {
  final LearnRepository _repository;
  const GetNearbyTopics(this._repository);

  Future<List<NearbyTopic>> call(String currentTopicId) =>
      _repository.getNearbyTopics(currentTopicId);
}

class SetCurrentTopic {
  final LearnRepository _repository;
  const SetCurrentTopic(this._repository);

  Future<void> call(String topicId) => _repository.setCurrentTopic(topicId);
}

class GetAllTopics {
  final LearnRepository _repository;
  const GetAllTopics(this._repository);

  Future<List<TopicWithStatus>> call() => _repository.getAllTopics();
}

class LearningSessionUseCases {
  final LearnRepository _repository;
  const LearningSessionUseCases(this._repository);

  Future<void> saveSession(LearningSession session) =>
      _repository.saveSession(session);
  LearningSession? getCurrentSession() => _repository.getCurrentSession();
  Future<void> clearSession() => _repository.clearSession();
  Future<void> completeStep({
    required String completedStepId,
    required int currentStepIndex,
  }) => _repository.completeStep(
    completedStepId: completedStepId,
    currentStepIndex: currentStepIndex,
  );
}
