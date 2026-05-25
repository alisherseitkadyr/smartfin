import 'package:hive/hive.dart';

part 'learning_session.g.dart';

@HiveType(typeId: 1)
class LearningSession extends HiveObject {
  @HiveField(0)
  String topicId;

  @HiveField(1)
  String subtopicCode;

  @HiveField(2)
  int currentStepIndex;

  @HiveField(3)
  List<String> completedStepIds;

  @HiveField(4)
  DateTime startedAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool synced;

  LearningSession({
    required this.topicId,
    required this.subtopicCode,
    required this.currentStepIndex,
    required this.completedStepIds,
    required this.startedAt,
    required this.updatedAt,
    required this.synced,
  });
}
