// smartfin/lib/features/learn/presentation/providers/lesson_flow_providers.dart
//
// Providers specific to the lesson flow (step reader + quiz).
// Keep quiz state here so it's scoped to the flow and auto-disposed on pop.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson_topic.dart';
import 'learn_providers.dart';

// ── Lesson by topic id (family — one per topicId) ────────────────────────────
// Used by LessonFlowPage to load steps for the active topic.
final lessonForTopicProvider =
    FutureProvider.family<LessonTopic, String>((ref, topicId) async {
  final useCase = ref.watch(getLessonForTopicProvider);
  return useCase(topicId);
});

// ── Quiz state ───────────────────────────────────────────────────────────────
// Tracks answers for the knowledge check in the current flow.
// auto-dispose ensures it resets every time the user enters the quiz.

class QuizState {
  final int currentQuestionIndex;
  final List<int?> answers; // null = not answered yet
  final int totalQuestions;

  const QuizState({
    required this.currentQuestionIndex,
    required this.answers,
    required this.totalQuestions,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    List<int?>? answers,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      totalQuestions: totalQuestions,
    );
  }

  bool get isComplete => currentQuestionIndex >= totalQuestions;

  int get correctCount => 0; // wired up in QuizPage directly for prototype

  bool isAnswered(int index) => answers[index] != null;
}

class QuizNotifier extends AutoDisposeNotifier<QuizState> {
  @override
  QuizState build() {
    return const QuizState(
      currentQuestionIndex: 0,
      answers: [],
      totalQuestions: 2,
    );
  }

  void init(int totalQuestions) {
    state = QuizState(
      currentQuestionIndex: 0,
      answers: List.filled(totalQuestions, null),
      totalQuestions: totalQuestions,
    );
  }

  void answer(int questionIndex, int selectedOption) {
    final updated = List<int?>.from(state.answers);
    updated[questionIndex] = selectedOption;
    state = state.copyWith(answers: updated);
  }

  void nextQuestion() {
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }
}

final quizNotifierProvider =
    AutoDisposeNotifierProvider<QuizNotifier, QuizState>(QuizNotifier.new);