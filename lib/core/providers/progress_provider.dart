import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── In-progress / completed topic state ───────────────────────
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
  final Set<String> completedTopicIds;

  const ProgressState({
    this.currentTopic,
    this.completedTopicIds = const {},
  });

  ProgressState copyWith({
    ActiveTopic? currentTopic,
    bool clearCurrent = false,
    Set<String>? completedTopicIds,
  }) {
    return ProgressState(
      currentTopic: clearCurrent ? null : (currentTopic ?? this.currentTopic),
      completedTopicIds: completedTopicIds ?? this.completedTopicIds,
    );
  }
}

class ProgressNotifier extends Notifier<ProgressState> {
  @override
  ProgressState build() => const ProgressState();

  void startTopic(ActiveTopic topic) {
    // Don't overwrite if this topic is already complete
    if (state.completedTopicIds.contains(topic.id)) return;
    state = state.copyWith(currentTopic: topic);
  }

  void updateStep(String topicId, int completedSteps) {
    if (state.currentTopic?.id != topicId) return;
    state = state.copyWith(
      currentTopic: state.currentTopic!.copyWithSteps(completedSteps),
    );
  }

  void completeTopic(String topicId) {
    final newCompleted = Set<String>.from(state.completedTopicIds)..add(topicId);
    // Keep showing until user goes back to home; clear current topic
    state = ProgressState(
      currentTopic: null,
      completedTopicIds: newCompleted,
    );
  }
}

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
