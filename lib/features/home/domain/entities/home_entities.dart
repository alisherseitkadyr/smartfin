// smartfin/lib/features/home/domain/entities/home_entities.dart
import 'package:equatable/equatable.dart';

// ── User summary shown in the greeting card ───────────────────
class UserSummary extends Equatable {
  final String name;
  final int totalXp;
  final int level;
  final int streakDays;
  final int completedTopics;
  final int totalTopics;

  const UserSummary({
    required this.name,
    required this.totalXp,
    required this.level,
    required this.streakDays,
    required this.completedTopics,
    required this.totalTopics,
  });

  double get progressToNextLevel {
    // Each level requires 500 XP
    return (totalXp % 500) / 500;
  }

  int get xpToNextLevel => 500 - (totalXp % 500);

  @override
  List<Object?> get props => [name, totalXp, level, streakDays];
}

// ── A single "quick action" tile on the home dashboard ────────
class QuickAction extends Equatable {
  final String id;
  final String label;
  final String emoji;
  final String route;

  const QuickAction({
    required this.id,
    required this.label,
    required this.emoji,
    required this.route,
  });

  @override
  List<Object?> get props => [id];
}

// ── A highlighted topic card shown on home ────────────────────
class FeaturedTopic extends Equatable {
  final String topicId;
  final String title;
  final String emoji;
  final String level;
  final int xp;
  final String duration;
  final bool isInProgress;
  final double progressPercent;

  const FeaturedTopic({
    required this.topicId,
    required this.title,
    required this.emoji,
    required this.level,
    required this.xp,
    required this.duration,
    required this.isInProgress,
    required this.progressPercent,
  });

  @override
  List<Object?> get props => [topicId, isInProgress, progressPercent];
}

// ── Monthly finance snapshot shown on home ────────────────────
class MonthlySnapshot extends Equatable {
  final int totalSpent;       // in tenge (smallest unit)
  final int totalSaved;
  final String currency;      // '₸'
  final String monthLabel;    // 'February 2026'
  final double spentChangePercent;
  final double savedChangePercent;

  const MonthlySnapshot({
    required this.totalSpent,
    required this.totalSaved,
    required this.currency,
    required this.monthLabel,
    required this.spentChangePercent,
    required this.savedChangePercent,
  });

  @override
  List<Object?> get props => [totalSpent, totalSaved, monthLabel];
}

// ── Full home screen data ─────────────────────────────────────
class HomeData extends Equatable {
  final UserSummary user;
  final FeaturedTopic? currentTopic;
  final List<FeaturedTopic> recommendedTopics;
  final MonthlySnapshot snapshot;
  final List<QuickAction> quickActions;

  const HomeData({
    required this.user,
    this.currentTopic,
    required this.recommendedTopics,
    required this.snapshot,
    required this.quickActions,
  });

  @override
  List<Object?> get props => [user, snapshot];
}