class ExploreSectionModel {
  final int id;
  final String code;
  final int orderIndex;
  final String icon;
  final String title;
  final String description;
  final List<ExploreTopicModel> topics;
  final int lessonsDone;
  final int lessonsTotal;

  const ExploreSectionModel({
    required this.id,
    required this.code,
    required this.orderIndex,
    required this.icon,
    required this.title,
    required this.description,
    required this.topics,
    required this.lessonsDone,
    required this.lessonsTotal,
  });

  factory ExploreSectionModel.fromJson(Map<String, dynamic> json) {
    return ExploreSectionModel(
      id: (json['id'] as num).toInt(),
      code: (json['code'] as String?) ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      icon: (json['icon'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      topics: (json['topics'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ExploreTopicModel.fromJson)
          .toList(),
      lessonsDone: (json['lessonsDone'] as num?)?.toInt() ?? 0,
      lessonsTotal: (json['lessonsTotal'] as num?)?.toInt() ?? 0,
    );
  }
}

class ExploreTopicModel {
  final int id;
  final String code;
  final String title;
  final String description;
  final String level;
  final int orderIndex;
  final int estimatedMinutes;
  final int lessonsDone;
  final int lessonsTotal;
  final int xpReward;
  final String? iconPath;

  const ExploreTopicModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.level,
    required this.orderIndex,
    required this.estimatedMinutes,
    required this.lessonsDone,
    required this.lessonsTotal,
    required this.xpReward,
    this.iconPath,
  });

  factory ExploreTopicModel.fromJson(Map<String, dynamic> json) {
    return ExploreTopicModel(
      id: (json['id'] as num).toInt(),
      code: (json['code'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      level: (json['level'] as String?) ?? 'beginner',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0,
      lessonsDone: (json['lessonsDone'] as num?)?.toInt() ?? 0,
      lessonsTotal: (json['lessonsTotal'] as num?)?.toInt() ?? 0,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
      iconPath: json['icon_path'] as String? ?? json['iconPath'] as String?,
    );
  }
}
