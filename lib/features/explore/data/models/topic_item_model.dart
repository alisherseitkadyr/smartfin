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
    return TopicItemModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      duration: json['duration'] as String,
      xp: json['xp'] as int,
      stepCount: json['step_count'] as int,
      prerequisiteId: json['prerequisite_id'] as String?,
      icon: json['icon'] as String,
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
      case 'intermediate': return TopicLevel.intermediate;
      case 'advanced': return TopicLevel.advanced;
      default: return TopicLevel.beginner;
    }
  }
}