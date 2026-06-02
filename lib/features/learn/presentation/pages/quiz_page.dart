import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../explore/presentation/providers/explore_providers.dart';
import '../../domain/entities/lesson_topic.dart';
import '../../domain/entities/quiz.dart';
import '../providers/learn_providers.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/quiz_option_tile.dart';
import 'lesson_complete_page.dart';

enum _QuizPhase { loading, answering, submitting, error }

class QuizPage extends ConsumerStatefulWidget {
  final LessonTopic lesson;

  /// When set, starts a subtopic quiz (2-3 questions).
  /// When null, starts the topic final quiz (10 questions).
  final String? subtopicId;

  const QuizPage({super.key, required this.lesson, this.subtopicId});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  _QuizPhase _phase = _QuizPhase.loading;
  QuizStartData? _quizData;
  String? _errorMessage;

  int _questionIndex = 0;
  int? _selectedOptionId;
  bool _isChecked = false;
  final List<QuizAnswerInput> _collectedAnswers = [];
  late final int _startMs;

  @override
  void initState() {
    super.initState();
    _startMs = DateTime.now().millisecondsSinceEpoch;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startQuiz());
  }

  Future<void> _startQuiz() async {
    setState(() {
      _phase = _QuizPhase.loading;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(learnRepositoryProvider);
      final data = widget.subtopicId != null
          ? await repo.startQuizBySubtopicCode(
              widget.subtopicId!,
              widget.lesson.topic.id,
            )
          : await repo.startQuizByTopicCode(widget.lesson.topic.id);
      if (mounted) {
        setState(() {
          _quizData = data;
          _phase = _QuizPhase.answering;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _phase = _QuizPhase.error;
        });
      }
    }
  }

  QuizQuestion get _currentQuestion => _quizData!.questions[_questionIndex];
  bool get _isLastQuestion => _questionIndex == _quizData!.questions.length - 1;
  QuizOption? get _selectedOption => _currentQuestion.options
      .where((option) => option.id == _selectedOptionId)
      .firstOrNull;
  int? get _currentCorrectOptionId => _currentQuestion.options
      .where((option) => option.isCorrect == true)
      .firstOrNull
      ?.id;
  bool get _hasCurrentAnswerKey =>
      _currentQuestion.options.any((option) => option.isCorrect == true);
  bool? get _selectedAnswerIsCorrect => _isChecked && _hasCurrentAnswerKey
      ? _selectedOption?.isCorrect == true
      : null;

  void _onOptionTap(int optionId) {
    if (_isChecked) return;
    setState(() => _selectedOptionId = optionId);
  }

  void _onCheck() {
    if (_selectedOptionId == null || _isChecked) return;
    _collectedAnswers.add(
      QuizAnswerInput(
        questionId: _currentQuestion.id,
        selectedOptionIds: [_selectedOptionId!],
      ),
    );
    setState(() => _isChecked = true);
  }

  void _onNext() {
    if (_isLastQuestion) {
      _submitQuiz();
    } else {
      setState(() {
        _questionIndex++;
        _selectedOptionId = null;
        _isChecked = false;
      });
    }
  }

  Future<void> _submitQuiz() async {
    setState(() => _phase = _QuizPhase.submitting);
    final durationSeconds =
        (DateTime.now().millisecondsSinceEpoch - _startMs) ~/ 1000;
    try {
      final result = await ref
          .read(learnRepositoryProvider)
          .submitQuiz(_quizData!.attemptId, _collectedAnswers, durationSeconds);

      // Mark the subtopic complete only after the quiz is actually submitted.
      final subtopicCode = widget.subtopicId ?? widget.lesson.subtopicCode;
      if (subtopicCode != null) {
        try {
          await ref.read(learnRepositoryProvider).completeSubtopic(subtopicCode);
        } catch (_) {
          // Don't block navigation if this fails — quiz result is already saved.
        }
        // Write to local Hive immediately so the badge and topic status update
        // before the backend progress cache refreshes (2-min TTL).
        try {
          await ref
              .read(exploreRepositoryProvider)
              .markSubtopicsCompleted(widget.lesson.topic.id, {subtopicCode});
        } catch (_) {}
      }

      // Determine whether this was the last subtopic so the completion page
      // can show the right label and navigate to the topic preview.
      var isLastSubtopic = false;
      if (subtopicCode != null) {
        try {
          final subtopics = await ref.read(
            topicSubtopicsProvider(widget.lesson.topic.id).future,
          );
          final idx = subtopics.indexWhere((s) => s.id == subtopicCode);
          isLastSubtopic = idx >= 0 && idx + 1 >= subtopics.length;
        } catch (_) {}
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LessonCompletePage(
              quizResult: result,
              completedTopicId: widget.lesson.topic.id,
              completedSubtopicId: widget.subtopicId,
              isLastSubtopic: isLastSubtopic,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        final isIncomplete = msg.contains('INCOMPLETE_QUIZ_ATTEMPT');
        setState(() {
          _errorMessage = isIncomplete
              ? 'Quiz session was interrupted. Please restart.'
              : msg;
          _phase = isIncomplete ? _QuizPhase.error : _QuizPhase.answering;
          if (!isIncomplete) _isChecked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _QuizPhase.loading => const _QuizLoadingView(label: 'Preparing quiz…'),
      _QuizPhase.submitting => const _QuizLoadingView(
        label: 'Calculating results…',
      ),
      _QuizPhase.error => _QuizErrorView(
        message: _errorMessage ?? '',
        onRetry: _startQuiz,
      ),
      _QuizPhase.answering => _QuizAnsweringView(
        lesson: widget.lesson,
        quizData: _quizData!,
        questionIndex: _questionIndex,
        selectedOptionId: _selectedOptionId,
        isChecked: _isChecked,
        answerIsCorrect: _selectedAnswerIsCorrect,
        correctOptionId: _currentCorrectOptionId,
        isLastQuestion: _isLastQuestion,
        errorMessage: _errorMessage,
        onOptionTap: _onOptionTap,
        onCheck: _onCheck,
        onNext: _onNext,
        onClose: () => Navigator.of(context).pop(),
      ),
    };
  }
}

// ── Loading ────────────────────────────────────────────────────
class _QuizLoadingView extends StatelessWidget {
  final String label;
  const _QuizLoadingView({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.green),
            const SizedBox(height: AppSpacing.xl),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────
class _QuizErrorView extends ConsumerWidget {
  final String message;
  final VoidCallback onRetry;
  const _QuizErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.couldntLoadLesson,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Answering ──────────────────────────────────────────────────
class _QuizAnsweringView extends ConsumerWidget {
  final LessonTopic lesson;
  final QuizStartData quizData;
  final int questionIndex;
  final int? selectedOptionId;
  final bool isChecked;
  final bool? answerIsCorrect;
  final int? correctOptionId;
  final bool isLastQuestion;
  final String? errorMessage;
  final ValueChanged<int> onOptionTap;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const _QuizAnsweringView({
    required this.lesson,
    required this.quizData,
    required this.questionIndex,
    required this.selectedOptionId,
    required this.isChecked,
    required this.answerIsCorrect,
    required this.correctOptionId,
    required this.isLastQuestion,
    required this.errorMessage,
    required this.onOptionTap,
    required this.onCheck,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final total = quizData.questions.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _QuizTopBar(
              title: l10n.knowledgeCheck,
              trailing: Text(
                l10n.qOf(questionIndex + 1, total),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onClose: onClose,
            ),
            LessonProgressBar(
              value: (questionIndex + 1) / total,
              trackColor: context.borderColor,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppDurations.medium,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _QuestionContent(
                  key: ValueKey(questionIndex),
                  question: quizData.questions[questionIndex],
                  selectedOptionId: selectedOptionId,
                  isLocked: isChecked,
                  reviewCorrect: isChecked ? correctOptionId : null,
                  reviewWrong: isChecked && answerIsCorrect == false
                      ? selectedOptionId
                      : null,
                  onOptionTap: isChecked ? null : onOptionTap,
                ),
              ),
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  errorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _QuizBottomBar(
              isChecked: isChecked,
              canCheck: selectedOptionId != null,
              answerIsCorrect: answerIsCorrect,
              isLastQuestion: isLastQuestion,
              onCheck: onCheck,
              onNext: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared top bar ─────────────────────────────────────────────
class _QuizTopBar extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback onClose;

  const _QuizTopBar({
    required this.title,
    required this.trailing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xl,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.muted,
            iconSize: 22,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ── Bottom bar: Check / Next ───────────────────────────────────
class _QuizBottomBar extends StatelessWidget {
  final bool isChecked;
  final bool canCheck;
  final bool? answerIsCorrect;
  final bool isLastQuestion;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const _QuizBottomBar({
    required this.isChecked,
    required this.canCheck,
    required this.answerIsCorrect,
    required this.isLastQuestion,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final String label;
    final VoidCallback? handler;

    if (!isChecked) {
      label = 'Check';
      handler = canCheck ? onCheck : null;
    } else {
      label = isLastQuestion ? 'See Results' : 'Next';
      handler = onNext;
    }

    final feedbackColor = answerIsCorrect == true
        ? AppColors.green
        : answerIsCorrect == false
        ? AppColors.red
        : AppColors.muted;
    final feedbackLabel = answerIsCorrect == true
        ? 'Correct!'
        : answerIsCorrect == false
        ? 'Incorrect'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feedbackLabel != null) ...[
            Row(
              children: [
                Icon(
                  answerIsCorrect == true
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: feedbackColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  feedbackLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: feedbackColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: handler,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: context.borderColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question content ───────────────────────────────────────────
class _QuestionContent extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedOptionId;
  final bool isLocked; // after check — disables tapping
  final int? reviewCorrect; // option id to show as correct in review
  final int? reviewWrong; // option id to show as wrong in review
  final ValueChanged<int>? onOptionTap;

  const _QuestionContent({
    super.key,
    required this.question,
    required this.selectedOptionId,
    required this.isLocked,
    this.reviewCorrect,
    this.reviewWrong,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.getTextColor(context),
              height: 1.35,
            ),
          ).animate().fadeIn(duration: AppDurations.cta),
          const SizedBox(height: 28),
          ...question.options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isSelected = selectedOptionId == opt.id;
            final isCorrect = reviewCorrect == opt.id;
            final isWrong = reviewWrong == opt.id;
            final isDisabled =
                isLocked && !isSelected && !isCorrect && !isWrong;

            return QuizOptionTile(
                  index: i,
                  label: opt.text,
                  isSelected: isSelected && !isCorrect && !isWrong,
                  isCorrect: isCorrect,
                  isWrong: isWrong,
                  isDisabled: isDisabled,
                  onTap: onOptionTap != null
                      ? () => onOptionTap!(opt.id)
                      : null,
                )
                .animate(
                  delay: Duration(
                    milliseconds:
                        AppDurations.staggerStep.inMilliseconds +
                        i * AppDurations.staggerStep.inMilliseconds,
                  ),
                )
                .fadeIn(duration: AppDurations.cta)
                .slideY(
                  begin: 0.05,
                  end: 0,
                  duration: AppDurations.cta,
                  curve: Curves.easeOut,
                );
          }),
        ],
      ),
    );
  }
}
