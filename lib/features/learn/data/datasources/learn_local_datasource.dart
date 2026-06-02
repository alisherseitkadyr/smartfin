import 'package:afine/core/storage/learning_session.dart';
import 'package:afine/core/storage/learning_session_storage.dart';

abstract class LearnLocalDataSource {
  Future<void> saveSession(LearningSession session);
  LearningSession? getCurrentSession();
  Future<void> clearSession();
  Future<void> completeStep({
    required String completedStepId,
    required int currentStepIndex,
  });
}

class LearnLocalDataSourceImpl implements LearnLocalDataSource {
  final LearningSessionStorage _storage;
  LearnLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveSession(LearningSession session) async {
    await _storage.saveSession(session);
  }

  @override
  LearningSession? getCurrentSession() {
    return _storage.getCurrentSession();
  }

  @override
  Future<void> clearSession() async {
    await _storage.clearSession();
  }

  @override
  Future<void> completeStep({
    required String completedStepId,
    required int currentStepIndex,
  }) async {
    await _storage.completeStep(
      completedStepId: completedStepId,
      currentStepIndex: currentStepIndex,
    );
  }
}
