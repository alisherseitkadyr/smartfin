import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../explore/domain/entities/topic_item.dart';
import '../../domain/entities/lesson_topic.dart';

/// Full-width gradient hero card shown at the top of [LearnPage].
class LearnHeroBanner extends StatelessWidget {
  final LessonTopic lesson;
  const LearnHeroBanner({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.greenDeep, AppColors.greenDark, AppColors.green],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: AppSpacing.sm),
                if (lesson.subtopicTitle != null) ...[
                  Text(
                    lesson.topic.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                  ).animate().fadeIn(delay: AppDurations.staggerStep, duration: 250.ms),
                  const SizedBox(height: 4),
                ],
                Text(
                  lesson.subtopicTitle ?? lesson.topic.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                )
                    .animate()
                    .fadeIn(
                      delay: AppDurations.staggerStep,
                      duration: 350.ms,
                    )
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.sm - 2),
                Text(
                  lesson.topic.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.5,
                      ),
                ).animate().fadeIn(delay: 100.ms, duration: AppDurations.slow),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _HeroChip(text: '⏱ ${lesson.topic.duration}'),
                    _HeroChip(text: '⭐ ${lesson.topic.xp} XP'),
                    _HeroChip(text: lesson.topic.level.label),
                    _HeroChip(text: '${lesson.steps.length} steps'),
                  ],
                ).animate().fadeIn(delay: 140.ms, duration: AppDurations.slow),
                const SizedBox(height: 18),
                _ProgressSection(lesson: lesson)
                    .animate()
                    .fadeIn(delay: 180.ms, duration: AppDurations.slow),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLabel extends StatelessWidget {
  final String text;
  const _HeroLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
            letterSpacing: 0.8,
          ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String text;
  const _HeroChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final LessonTopic lesson;
  const _ProgressSection({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final completed =
        lesson.isCompleted ? lesson.steps.length : lesson.completedSteps;
    final total = lesson.steps.length;
    final pct = total > 0 ? completed / total : 0.0;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '$completed / $total steps',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}
