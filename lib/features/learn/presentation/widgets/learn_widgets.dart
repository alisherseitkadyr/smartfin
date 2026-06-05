import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';

// ─────────────────────────────────────────────────────────────
// Sticky start / resume button at the bottom of LearnPage
// ─────────────────────────────────────────────────────────────
class LearnStickyStartButton extends ConsumerWidget {
  final LessonTopic lesson;
  final VoidCallback? onTap;

  const LearnStickyStartButton({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  String _label(AppL10n l10n) {
    if (lesson.isCompleted) return l10n.reviewLesson;
    if (lesson.isInProgress) return l10n.continueLesson(lesson.completedSteps + 1);
    return l10n.startLesson;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final isCompleted = lesson.isCompleted;
    final backgroundColor = isCompleted ? AppColors.navy : AppColors.green;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        bottomInset > 0 ? bottomInset + AppSpacing.sm : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: AppShadows.elevated,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(
            isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
            size: 22,
          ),
          label: Text(_label(l10n)),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            elevation: 0,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section title
// ─────────────────────────────────────────────────────────────
class LearnSectionTitle extends StatelessWidget {
  final String title;
  const LearnSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Steps timeline list
// ─────────────────────────────────────────────────────────────
class StepsList extends StatelessWidget {
  final LessonTopic lesson;

  const StepsList({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final steps = lesson.steps;
    final completedSteps =
        lesson.isCompleted ? steps.length : lesson.completedSteps;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardLg),
        border: Border.all(color: context.borderColor, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isDone = i < completedSteps;
            final isCurrent = !lesson.isCompleted && i == completedSteps;
            final isLast = i == steps.length - 1;

            return _StepRow(
                  step: step,
                  index: i,
                  isDone: isDone,
                  isCurrent: isCurrent,
                  isUpcoming: !isDone && !isCurrent,
                  isLastStep: isLast,
                  showConnector: true,
                )
                .animate(delay: AppDurations.staggerStep * i)
                .fadeIn(duration: AppDurations.cta)
                .slideX(
                  begin: -0.03,
                  end: 0,
                  duration: AppDurations.cta,
                  curve: Curves.easeOut,
                );
          }),

          const SizedBox(height: AppSpacing.sm),
          _QuizRow(lesson: lesson),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final LessonStep step;
  final int index;
  final bool isDone;
  final bool isCurrent;
  final bool isUpcoming;
  final bool isLastStep;
  final bool showConnector;

  const _StepRow({
    required this.step,
    required this.index,
    required this.isDone,
    required this.isCurrent,
    required this.isUpcoming,
    required this.isLastStep,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.cardLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 15,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 36,
              child: _StepCircle(
                index: index,
                isDone: isDone,
                isCurrent: isCurrent,
              ),
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title, style: Theme.of(context).textTheme.titleMedium),
                  if (isDone || isCurrent) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _StepBadge(isDone: isDone, isCurrent: isCurrent),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isCurrent;
  const _StepCircle({
    required this.index,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Widget child;

    if (isDone) {
      bg = AppColors.greenLight;
      fg = AppColors.greenDark;
      child = const Icon(Icons.check, size: 16, color: AppColors.greenDark);
    } else if (isCurrent) {
      bg = AppColors.green;
      fg = Colors.white;
      child = Text(
        '${index + 1}',
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
      );
    } else {
      bg = AppColors.getMutedXLightColor(context);
      fg = AppColors.getMutedColor(context);
      child = Text(
        '${index + 1}',
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700),
      );
    }

    return AnimatedContainer(
      duration: AppDurations.fast,
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}

class _StepBadge extends ConsumerWidget {
  final bool isDone;
  final bool isCurrent;
  const _StepBadge({required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    if (isDone) {
      return _Badge(
        text: l10n.stepDone,
        bg: AppColors.greenLight,
        fg: AppColors.greenDark,
      );
    }
    if (isCurrent) {
      return _Badge(
        text: l10n.stepInProgress,
        bg: AppColors.amberLight,
        fg: AppColors.amberDark,
      );
    }
    return const SizedBox.shrink();
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

class _QuizRow extends ConsumerWidget {
  final LessonTopic lesson;
  const _QuizRow({required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final isQuizDone = lesson.isCompleted;
    final isQuizAvailable = lesson.completedSteps >= lesson.steps.length;
    final stepcount = lesson.steps.length + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isQuizDone
                  ? AppColors.greenLight
                  : isQuizAvailable
                      ? AppColors.green
                      : AppColors.getMutedXLightColor(context),
              shape: BoxShape.circle,
              boxShadow: isQuizAvailable && !isQuizDone
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isQuizDone
                  ? const Icon(Icons.check, size: 16, color: AppColors.greenDark)
                  : Text(
                      '$stepcount',
                      style: TextStyle(
                        color: isQuizAvailable
                            ? Colors.white
                            : AppColors.getMutedColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.knowledgeCheck,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                if (isQuizDone)
                  _Badge(
                    text: l10n.quizPassed,
                    bg: AppColors.greenLight,
                    fg: AppColors.greenDark,
                  )
                else if (isQuizAvailable)
                  _Badge(
                    text: l10n.takeTheQuiz,
                    bg: AppColors.amberLight,
                    fg: AppColors.amberDark,
                  )
                else
                  _Badge(
                    text: l10n.quizLabel,
                    bg: AppColors.indigoLight,
                    fg: AppColors.navy,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
