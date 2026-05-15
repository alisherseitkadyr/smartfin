import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';

/// Scrollable content for one lesson step: title, body, optional example
/// callout, and optional tip callout.
class LessonStepView extends StatelessWidget {
  final LessonStep step;
  final int stepIndex;

  const LessonStepView({
    super.key,
    required this.step,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
          )
              .animate(key: ValueKey('title_$stepIndex'))
              .fadeIn(duration: AppDurations.cta)
              .slideY(
                begin: 0.06,
                end: 0,
                duration: AppDurations.cta,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            step.body,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(height: 1.65),
          )
              .animate(key: ValueKey('body_$stepIndex'))
              .fadeIn(
                delay: AppDurations.staggerStep,
                duration: AppDurations.cta,
              ),
          if (step.example.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxl),
            LessonExampleBlock(text: step.example, stepIndex: stepIndex),
          ],
          if (step.tip.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            LessonTipBlock(text: step.tip, stepIndex: stepIndex),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

/// Blue left-bordered callout for real-world examples.
class LessonExampleBlock extends ConsumerWidget {
  final String text;
  final int stepIndex;

  const LessonExampleBlock({
    super.key,
    required this.text,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: const Border(
          left: BorderSide(color: AppColors.blue, width: 3.5),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.example,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.blueDark,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy,
                  height: 1.55,
                ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey('example_$stepIndex'))
        .fadeIn(delay: 120.ms, duration: AppDurations.slow)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: AppDurations.slow,
          curve: Curves.easeOut,
        );
  }
}

/// Green left-bordered callout for key tips to remember.
class LessonTipBlock extends ConsumerWidget {
  final String text;
  final int stepIndex;

  const LessonTipBlock({
    super.key,
    required this.text,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 3.5),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.rememberThis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.greenDark,
                  letterSpacing: 0.3,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greenDark,
                  height: 1.55,
                ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey('tip_$stepIndex'))
        .fadeIn(delay: 180.ms, duration: AppDurations.slow)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: AppDurations.slow,
          curve: Curves.easeOut,
        );
  }
}
