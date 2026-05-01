import '../../domain/entities/topic_item.dart';

class TopicItemModel {
  final String id;
  final String title;
  final String description;
  final String level;
  final String duration;
  final int xp;
  final int stepCount;
  final String? prerequisiteId;
  final String icon;

  const TopicItemModel({
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

  factory TopicItemModel.fromJson(Map<String, dynamic> json) {
    // Safely extract values with defaults
    final id = (json['id'] ?? json['code'] ?? '').toString();
    final title = (json['title'] as String?) ?? '';
    final description = (json['description'] as String?) ?? '';
    final level =
        (json['level'] as String?) ??
        (json['difficulty'] as String?) ??
        'beginner';
    final estimatedMinutes = (json['estimatedMinutes'] as num?)?.toInt();
    final duration =
        (json['duration'] as String?) ??
        (estimatedMinutes == null ? '10 min' : '$estimatedMinutes min');
    final xp = (json['xp'] as num?)?.toInt() ?? 50;
    final rawStepCount = json['step_count'] ?? json['stepCount'];
    final stepCount = rawStepCount is num ? rawStepCount.toInt() : 0;
    final prerequisiteId = json['prerequisite_id'] as String?;
    final icon = (json['icon'] as String?) ?? '📚';

    return TopicItemModel(
      id: id,
      title: title,
      description: description,
      level: level,
      duration: duration,
      xp: xp,
      stepCount: stepCount,
      prerequisiteId: prerequisiteId,
      icon: icon,
    );
  }

  TopicItem toEntity() {
    return TopicItem(
      id: id,
      title: title,
      description: description,
      level: _parseLevel(level),
      duration: duration,
      xp: xp,
      stepCount: stepCount,
      prerequisiteId: prerequisiteId,
      icon: icon,
    );
  }

  TopicLevel _parseLevel(String raw) {
    switch (raw) {
      case 'intermediate':
        return TopicLevel.intermediate;
      case 'advanced':
        return TopicLevel.advanced;
      default:
        return TopicLevel.beginner;
    }
  }
}
