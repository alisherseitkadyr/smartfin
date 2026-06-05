import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';
import 'lesson_interactive_view.dart';

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
          if (step.body.trim().isNotEmpty)
            Text(
                  step.body,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.65),
                )
                .animate(key: ValueKey('body_$stepIndex'))
                .fadeIn(
                  delay: AppDurations.staggerStep,
                  duration: AppDurations.cta,
                ),
          if (step.hasInteractiveContent) ...[
            if (step.body.trim().isNotEmpty)
              const SizedBox(height: AppSpacing.xxl),
            LessonInteractiveView(step: step)
                .animate(key: ValueKey('interactive_$stepIndex'))
                .fadeIn(delay: 120.ms, duration: AppDurations.slow)
                .slideY(
                  begin: 0.04,
                  end: 0,
                  duration: AppDurations.slow,
                  curve: Curves.easeOut,
                ),
          ],
          if (step.hasTables) ...[
            const SizedBox(height: AppSpacing.xxl),
            for (final table in step.tables!)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: LessonTableBlock(rows: table, stepIndex: stepIndex),
              ),
          ],
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
    final isDark = AppColors.isDark(context);
    return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.blue.withValues(alpha: 0.14)
                : AppColors.blueLight,
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
                  color: isDark ? AppColors.blue : AppColors.blueDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.text2Color,
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
    final isDark = AppColors.isDark(context);
    return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.green.withValues(alpha: 0.14)
                : AppColors.greenLight,
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
                  color: isDark ? AppColors.greenMid : AppColors.greenDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.text2Color,
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

/// Renders a structured table extracted from lesson block content.
class LessonTableBlock extends StatelessWidget {
  final List<List<String>> rows;
  final int stepIndex;

  const LessonTableBlock({
    super.key,
    required this.rows,
    required this.stepIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final isDark = AppColors.isDark(context);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.10);
    final headerBg = isDark
        ? AppColors.green.withValues(alpha: 0.18)
        : AppColors.greenLight;

    final columnCount = rows.fold(0, (max, row) => row.length > max ? row.length : max);
    if (columnCount == 0) return const SizedBox.shrink();

    return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: borderColor),
                verticalInside: BorderSide(color: borderColor),
              ),
              defaultColumnWidth: const FlexColumnWidth(),
              children: rows.asMap().entries.map((entry) {
                final isHeader = entry.key == 0;
                final cells = entry.value;
                return TableRow(
                  decoration: isHeader ? BoxDecoration(color: headerBg) : null,
                  children: List.generate(columnCount, (ci) {
                    final text = ci < cells.length ? cells[ci] : '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm + 2,
                      ),
                      child: Text(
                        text,
                        style: isHeader
                            ? Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              )
                            : Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.45,
                              ),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
        )
        .animate(key: ValueKey('table_${stepIndex}_${rows.hashCode}'))
        .fadeIn(delay: 100.ms, duration: AppDurations.slow)
        .slideY(begin: 0.04, end: 0, duration: AppDurations.slow, curve: Curves.easeOut);
  }
}
