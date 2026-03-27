import 'package:equatable/equatable.dart';

enum TopicLevel { beginner, intermediate, advanced }

enum TopicStatus { locked, available, inProgress, completed }

extension TopicLevelExtension on TopicLevel {
  String get label {
    switch (this) {
      case TopicLevel.beginner: return 'Beginner';
      case TopicLevel.intermediate: return 'Intermediate';
      case TopicLevel.advanced: return 'Advanced';
    }
  }

  String get emoji {
    switch (this) {
      case TopicLevel.beginner: return '🌱';
      case TopicLevel.intermediate: return '📈';
      case TopicLevel.advanced: return '🎯';
    } 
  }
}

class TopicItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final TopicLevel level;
  final String duration;
  final int xp;
  final int stepCount;
  final String? prerequisiteId;
  final String icon;

  const TopicItem({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.duration,
    required this.xp,
    required this.stepCount,
    this.prerequisiteId,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, title, level, xp, stepCount, prerequisiteId];
}

// Combines TopicItem with runtime status — returned by use cases
class TopicWithStatus extends Equatable {
  final TopicItem topic;
  final TopicStatus status;
  final int completedSteps;

  const TopicWithStatus({
    required this.topic,
    required this.status,
    required this.completedSteps,
  });

  bool get isLocked => status == TopicStatus.locked;
  bool get isCompleted => status == TopicStatus.completed;
  bool get isInProgress => status == TopicStatus.inProgress;
  bool get isAvailable => status == TopicStatus.available;

  double get progressPercent {
    if (topic.stepCount == 0) return 0;
    return completedSteps / topic.stepCount;
  }

  @override
  List<Object?> get props => [topic.id, status, completedSteps];
}