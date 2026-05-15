import 'package:hive/hive.dart';

import 'learning_session.dart';

class LearningSessionStorage {
  static const boxName = 'learning_sessions';
  static const _currentSessionKey = 'current_session';

  Box<LearningSession> get _box => Hive.box<LearningSession>(boxName);

  Future<void> saveSession(LearningSession session) async {
    await _box.put(_currentSessionKey, session);
  }

  LearningSession? getCurrentSession() {
    return _box.get(_currentSessionKey);
  }

  Future<void> clearSession() async {
    await _box.delete(_currentSessionKey);
  }

  Future<void> completeStep({
    required String completedStepId,
    required int currentStepIndex,
  }) async {
    final session = getCurrentSession();

    if (session == null) return;

    session.currentStepIndex = currentStepIndex;

    if (!session.completedStepIds.contains(completedStepId)) {
      // Hive deserializes lists as fixed-length; spread into a new growable list
      session.completedStepIds = [...session.completedStepIds, completedStepId];
    }

    session.updatedAt = DateTime.now();

    await session.save();
  }
}
