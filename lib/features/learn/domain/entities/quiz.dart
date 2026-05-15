import 'package:equatable/equatable.dart';

class QuizOption extends Equatable {
  final int id;
  final int orderIndex;
  final String text;
  final bool? isCorrect;

  const QuizOption({
    required this.id,
    required this.orderIndex,
    required this.text,
    this.isCorrect,
  });

  @override
  List<Object?> get props => [id, isCorrect];
}

class QuizQuestion extends Equatable {
  final int id;
  final String questionType;
  final int orderIndex;
  final String questionText;
  final List<QuizOption> options;

  const QuizQuestion({
    required this.id,
    required this.questionType,
    required this.orderIndex,
    required this.questionText,
    required this.options,
  });

  @override
  List<Object?> get props => [id];
}

class QuizStartData extends Equatable {
  final int attemptId;
  final int quizId;
  final String quizType;
  final String title;
  final int totalQuestions;
  final List<QuizQuestion> questions;

  const QuizStartData({
    required this.attemptId,
    required this.quizId,
    required this.quizType,
    required this.title,
    required this.totalQuestions,
    required this.questions,
  });

  @override
  List<Object?> get props => [attemptId, quizId];
}

class QuizAnswerInput {
  final int questionId;
  final List<int> selectedOptionIds;

  const QuizAnswerInput({
    required this.questionId,
    required this.selectedOptionIds,
  });
}

class QuizResult extends Equatable {
  final int attemptId;
  final int quizId;
  final int scorePercent;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final bool passed;
  final int xpForScore;

  const QuizResult({
    required this.attemptId,
    required this.quizId,
    required this.scorePercent,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.passed,
    required this.xpForScore,
  });

  @override
  List<Object?> get props => [attemptId];
}

class QuizAnswerResult extends Equatable {
  final int questionId;
  final bool isCorrect;
  final List<int> selectedAnswerIds;
  final List<int> correctAnswerIds;

  const QuizAnswerResult({
    required this.questionId,
    required this.isCorrect,
    required this.selectedAnswerIds,
    this.correctAnswerIds = const [],
  });

  @override
  List<Object?> get props => [questionId];
}
