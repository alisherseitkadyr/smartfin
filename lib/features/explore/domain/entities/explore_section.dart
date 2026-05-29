import 'topic_item.dart';

class ExploreSection {
  final int id;
  final String code;
  final int orderIndex;
  final String icon;
  final String title;
  final String description;
  final List<TopicWithStatus> topics;
  final int lessonsDone;
  final int lessonsTotal;

  const ExploreSection({
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
}
