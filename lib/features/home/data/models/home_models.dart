// smartfin/lib/features/home/data/models/home_models.dart
import '../../domain/entities/home_entities.dart';

class UserSummaryModel extends Equatable {
  final String name;
  final int totalXp;
  final int level;
  final int streakDays;
  final int completedTopics;
  final int totalTopics;

  const UserSummaryModel({
    required this.name,
    required this.totalXp,
    required this.level,
    required this.streakDays,
    required this.completedTopics,
    required this.totalTopics,
  });

  UserSummary toEntity() => UserSummary(
        name: name,
        totalXp: totalXp,
        level: level,
        streakDays: streakDays,
        completedTopics: completedTopics,
        totalTopics: totalTopics,
      );

  @override
  List<Object?> get props => [name, totalXp, level];
}

class FeaturedTopicModel extends Equatable {
  final String topicId;
  final String title;
  final String emoji;
  final String level;
  final int xp;
  final String duration;
  final bool isInProgress;
  final double progressPercent;

  const FeaturedTopicModel({
    required this.topicId,
    required this.title,
    required this.emoji,
    required this.level,
    required this.xp,
    required this.duration,
    required this.isInProgress,
    required this.progressPercent,
  });

  FeaturedTopic toEntity() => FeaturedTopic(
        topicId: topicId,
        title: title,
        emoji: emoji,
        level: level,
        xp: xp,
        duration: duration,
        isInProgress: isInProgress,
        progressPercent: progressPercent,
      );

  @override
  List<Object?> get props => [topicId];
}

class MonthlySnapshotModel extends Equatable {
  final int totalSpent;
  final int totalSaved;
  final String currency;
  final String monthLabel;
  final double spentChangePercent;
  final double savedChangePercent;

  const MonthlySnapshotModel({
    required this.totalSpent,
    required this.totalSaved,
    required this.currency,
    required this.monthLabel,
    required this.spentChangePercent,
    required this.savedChangePercent,
  });

  MonthlySnapshot toEntity() => MonthlySnapshot(
        totalSpent: totalSpent,
        totalSaved: totalSaved,
        currency: currency,
        monthLabel: monthLabel,
        spentChangePercent: spentChangePercent,
        savedChangePercent: savedChangePercent,
      );

  @override
  List<Object?> get props => [totalSpent, totalSaved, monthLabel];
}

class QuickActionModel extends Equatable {
  final String id;
  final String label;
  final String emoji;
  final String route;

  const QuickActionModel({
    required this.id,
    required this.label,
    required this.emoji,
    required this.route,
  });

  QuickAction toEntity() => QuickAction(id: id, label: label, emoji: emoji, route: route);

  @override
  List<Object?> get props => [id];
}

class HomeDataModel extends Equatable {
  final UserSummaryModel user;
  final FeaturedTopicModel? currentTopic;
  final List<FeaturedTopicModel> recommendedTopics;
  final MonthlySnapshotModel snapshot;
  final List<QuickActionModel> quickActions;

  const HomeDataModel({
    required this.user,
    this.currentTopic,
    required this.recommendedTopics,
    required this.snapshot,
    required this.quickActions,
  });

  HomeData toEntity() => HomeData(
        user: user.toEntity(),
        currentTopic: currentTopic?.toEntity(),
        recommendedTopics: recommendedTopics.map((m) => m.toEntity()).toList(),
        snapshot: snapshot.toEntity(),
        quickActions: quickActions.map((m) => m.toEntity()).toList(),
      );

  @override
  List<Object?> get props => [user];
}

// ignore: must_be_immutable
class Equatable {
  const Equatable();
  List<Object?> get props => [];
}