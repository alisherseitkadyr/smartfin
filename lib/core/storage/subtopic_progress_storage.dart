import 'package:hive/hive.dart';

/// Persists which subtopic IDs are completed per topic.
/// Key: topicId — Value: List of completed subtopicIds (strings).
/// Uses a plain Box of dynamic; no Hive adapter needed.
class SubtopicProgressStorage {
  static const boxName = 'subtopic_progress';

  Box<dynamic> get _box => Hive.box(boxName);

  Set<String> getCompletedSubtopicIds(String topicId) {
    final raw = _box.get(topicId);
    if (raw is List) return Set<String>.from(raw.map((e) => e.toString()));
    return const <String>{};
  }

  Future<void> saveCompletedSubtopicIds(
    String topicId,
    Set<String> ids,
  ) async {
    await _box.put(topicId, ids.toList());
  }

  Future<void> clear() async => _box.clear();
}
