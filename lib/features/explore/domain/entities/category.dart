import 'package:equatable/equatable.dart';
import 'topic_item.dart';

enum CategoryColor { green, blue, navy }

class Category extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final CategoryColor color;
  final List<String> topicIds;

  const Category({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.topicIds,
  });

  @override
  List<Object?> get props => [id];
}

/// Category enriched with its topics + computed stats
class CategoryWithTopics extends Equatable {
  final Category category;
  final List<TopicWithStatus> topics;

  const CategoryWithTopics({
    required this.category,
    required this.topics,
  });

  int get totalXp => topics.fold(0, (sum, t) => sum + t.topic.xp);

  int get completedCount => topics.where((t) => t.isCompleted).length;

  bool get isStarted => topics.any((t) => t.isCompleted || t.isInProgress);

  bool get isFullyCompleted => topics.every((t) => t.isCompleted);

  /// The next topic the user should work on
  TopicWithStatus? get nextTopic {
    for (final t in topics) {
      if (t.isInProgress) return t;
    }
    for (final t in topics) {
      if (t.isAvailable) return t;
    }
    return null;
  }

  String get totalDuration {
    // Parse "X min" strings and sum them
    final total = topics.fold<int>(0, (sum, t) {
      final match = RegExp(r'(\d+)').firstMatch(t.topic.duration);
      return sum + (match != null ? int.parse(match.group(1)!) : 0);
    });
    return '$total min';
  }

  double get progressPercent {
    if (topics.isEmpty) return 0;
    return completedCount / topics.length;
  }

  @override
  List<Object?> get props => [category.id, completedCount];
}