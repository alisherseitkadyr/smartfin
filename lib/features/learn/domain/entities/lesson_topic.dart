import 'package:equatable/equatable.dart';
import '../../../explore/domain/entities/topic_item.dart';

class LessonStep extends Equatable {
  final String id;
  final int order;
  final String title;
  final String body;
  final String example;
  final String tip;

  const LessonStep({
    required this.id,
    required this.order,
    required this.title,
    required this.body,
    required this.example,
    required this.tip,
  });

  @override
  List<Object?> get props => [id, order];
}

class LessonOutcome extends Equatable {
  final String text;
  const LessonOutcome({required this.text});
  @override
  List<Object?> get props => [text];
}

class LessonTopic extends Equatable {
  final TopicItem topic;
  final List<LessonStep> steps;
  final List<LessonOutcome> outcomes;
  final int completedSteps;
  final TopicStatus status;

  const LessonTopic({
    required this.topic,
    required this.steps,
    required this.outcomes,
    required this.completedSteps,
    required this.status,
  });

  bool get isCompleted => status == TopicStatus.completed;
  bool get isNotStarted => completedSteps == 0 && !isCompleted;
  bool get isInProgress => completedSteps > 0 && !isCompleted;

  double get progressPercent {
    if (steps.isEmpty) return 0;
    return completedSteps / steps.length;
  }

  String get startButtonLabel {
    if (isCompleted) return 'Review Lesson';
    if (isInProgress) return 'Continue — Step ${completedSteps + 1}';
    return 'Start Lesson';
  }

  @override
  List<Object?> get props => [topic.id, completedSteps, status];
}

// Nearby topic for the "Up next" section
class NearbyTopic extends Equatable {
  final TopicItem topic;
  final TopicStatus status;

  const NearbyTopic({required this.topic, required this.status});

  bool get isLocked => status == TopicStatus.locked;
  bool get isCompleted => status == TopicStatus.completed;

  @override
  List<Object?> get props => [topic.id, status];
}