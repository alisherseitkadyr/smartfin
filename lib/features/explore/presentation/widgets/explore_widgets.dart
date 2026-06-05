import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';

// ── Difficulty dot ────────────────────────────────────────────
class DifficultyDot extends StatelessWidget {
  final TopicLevel level;
  final double size;
  const DifficultyDot({super.key, required this.level, this.size = 10});

  Color get _color {
    switch (level) {
      case TopicLevel.beginner:
        return AppColors.green;
      case TopicLevel.intermediate:
        return AppColors.blue;
      case TopicLevel.advanced:
        return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

// ── Level chip ────────────────────────────────────────────────
class LevelChip extends ConsumerWidget {
  final TopicLevel level;
  const LevelChip({super.key, required this.level});

  Color get _bg {
    switch (level) {
      case TopicLevel.beginner:
        return AppColors.greenLight;
      case TopicLevel.intermediate:
        return AppColors.blueLight;
      case TopicLevel.advanced:
        return AppColors.indigoLight;
    }
  }

  Color get _fg {
    switch (level) {
      case TopicLevel.beginner:
        return AppColors.greenDark;
      case TopicLevel.intermediate:
        return AppColors.indigoDark;
      case TopicLevel.advanced:
        return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 3,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        l10n.levelLabel(level),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _fg),
      ),
    );
  }
}

// ── XP chip ───────────────────────────────────────────────────
class XpChip extends StatelessWidget {
  final int xp;
  const XpChip({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 3,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '⭐ $xp XP',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.amberDark),
      ),
    );
  }
}

// ── Duration chip ─────────────────────────────────────────────
class DurationChip extends StatelessWidget {
  final String duration;
  const DurationChip({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 3,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.getMutedLightColor(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text('⏱ $duration', style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

// ── Topic card ────────────────────────────────────────────────
class TopicCard extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final VoidCallback onTap;
  final int animationIndex;

  const TopicCard({
    super.key,
    required this.topicWithStatus,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = topicWithStatus.topic;
    final status = topicWithStatus.status;
    final isLocked = topicWithStatus.isLocked;
    final isCompleted = topicWithStatus.isCompleted;
    final isDark = AppColors.isDark(context);
    final completedBg = isDark ? AppColors.greenDeep : AppColors.greenLight;
    final completedBorder = isDark ? AppColors.greenDark : AppColors.greenMid;

    return Animate(
      effects: [
        FadeEffect(
          delay: AppDurations.staggerStep * animationIndex,
          duration: AppDurations.slow,
        ),
        SlideEffect(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
          delay: AppDurations.staggerStep * animationIndex,
          duration: AppDurations.slow,
          curve: Curves.easeOut,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: isCompleted
                ? completedBg
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.cardLg),
            border: Border.all(
              color: isCompleted ? completedBorder : context.borderColor,
              width: 1.5,
            ),
            boxShadow: AppShadows.card,
          ),
          child: Opacity(
            opacity: isLocked ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  DifficultyDot(level: t.level),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm + 2),
                        Wrap(
                          spacing: AppSpacing.sm - 2,
                          runSpacing: AppSpacing.sm - 2,
                          children: [
                            DurationChip(duration: t.duration),
                            XpChip(xp: t.xp),
                            LevelChip(level: t.level),
                          ],
                        ),
                        if (status == TopicStatus.inProgress) ...[
                          const SizedBox(height: AppSpacing.sm + 2),
                          _ProgressRow(topicWithStatus: topicWithStatus),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _ActionIcon(status: status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  const _ProgressRow({required this.topicWithStatus});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: topicWithStatus.progressPercent,
              backgroundColor: context.borderColor,
              color: AppColors.green,
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${topicWithStatus.completedSteps}/${topicWithStatus.topic.stepCount}',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.greenDark),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final TopicStatus status;
  const _ActionIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    switch (status) {
      case TopicStatus.completed:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? AppColors.greenDark : AppColors.greenLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: isDark ? Colors.white : AppColors.greenDark,
            size: 16,
          ),
        );
      case TopicStatus.locked:
        return const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.muted,
          size: 20,
        );
      case TopicStatus.inProgress:
        return const Icon(
          Icons.play_circle_filled_rounded,
          color: AppColors.green,
          size: 26,
        );
      case TopicStatus.available:
        return const SizedBox.shrink();
    }
  }
}

// ── Locked topic sheet ────────────────────────────────────────
class LockedTopicSheet extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final String? prerequisiteTitle;
  final VoidCallback? onGoToPrerequisite;

  const LockedTopicSheet({
    super.key,
    required this.topicWithStatus,
    this.prerequisiteTitle,
    this.onGoToPrerequisite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ),
          const Text('🔒', style: TextStyle(fontSize: 36)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Topic Locked',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            prerequisiteTitle != null
                ? 'Complete "$prerequisiteTitle" to unlock this topic.'
                : 'Complete the prerequisite topic first.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (onGoToPrerequisite != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onGoToPrerequisite!();
                },
                child: Text('Go to ${prerequisiteTitle ?? 'prerequisite'} →'),
              ),
            ),
          const SizedBox(height: AppSpacing.sm + 2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.borderColor),
                foregroundColor: AppColors.muted,
              ),
              child: const Text('Maybe later'),
            ),
          ),
        ],
      ),
    );
  }
}
