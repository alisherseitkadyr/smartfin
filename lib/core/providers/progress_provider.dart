import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Active topic UI state (home page "Continue Learning" banner) ──────────────
// This is ONLY for the transient home-page banner while a lesson is open.
// It is intentionally in-memory and NOT persisted — it reflects the currently
// active lesson session. Backend + SubtopicProgressStorage are the sources of
// truth for all persisted completion data.

class ActiveTopic {
  final String id;
  final String title;
  final String icon;
  final String level;
  final int xp;
  final String duration;
  final int completedSteps;
  final int totalSteps;

  const ActiveTopic({
    required this.id,
    required this.title,
    required this.icon,
    required this.level,
    required this.xp,
    required this.duration,
    required this.completedSteps,
    required this.totalSteps,
  });

  double get progressPercent =>
      totalSteps > 0 ? completedSteps / totalSteps : 0.0;

  ActiveTopic copyWithSteps(int completed) => ActiveTopic(
        id: id,
        title: title,
        icon: icon,
        level: level,
        xp: xp,
        duration: duration,
        completedSteps: completed,
        totalSteps: totalSteps,
      );
}

class ProgressState {
  final ActiveTopic? currentTopic;

  const ProgressState({this.currentTopic});

  ProgressState copyWith({ActiveTopic? currentTopic, bool clearCurrent = false}) {
    return ProgressState(
      currentTopic:
          clearCurrent ? null : (currentTopic ?? this.currentTopic),
    );
  }
}

class ProgressNotifier extends Notifier<ProgressState> {
  @override
  ProgressState build() => const ProgressState();

  void startTopic(ActiveTopic topic) {
    state = state.copyWith(currentTopic: topic);
  }

  void updateStep(String topicId, int completedSteps) {
    if (state.currentTopic?.id != topicId) return;
    state = state.copyWith(
      currentTopic: state.currentTopic!.copyWithSteps(completedSteps),
    );
  }

  /// Called when the topic lesson+quiz flow completes.
  /// Clears the banner so the home page returns to the backend's current topic.
  void completeTopic(String topicId) {
    state = const ProgressState();
  }
}

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
