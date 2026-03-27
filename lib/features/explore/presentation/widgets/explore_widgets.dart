import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';

// ── Difficulty dot ─────────────────────────────────────────────
class DifficultyDot extends StatelessWidget {
  final TopicLevel level;
  final double size;
  const DifficultyDot({super.key, required this.level, this.size = 10});

  Color get _color {
    switch (level) {
      case TopicLevel.beginner: return AppColors.green;
      case TopicLevel.intermediate: return AppColors.blue;
      case TopicLevel.advanced: return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

// ── Level chip ────────────────────────────────────────────────
class LevelChip extends StatelessWidget {
  final TopicLevel level;
  const LevelChip({super.key, required this.level});

  Color get _bg {
    switch (level) {
      case TopicLevel.beginner: return AppColors.greenLight;
      case TopicLevel.intermediate: return AppColors.blueLight;
      case TopicLevel.advanced: return const Color(0xFFEEF2FF);
    }
  }

  Color get _fg {
    switch (level) {
      case TopicLevel.beginner: return AppColors.greenDark;
      case TopicLevel.intermediate: return const Color(0xFF1D4ED8);
      case TopicLevel.advanced: return AppColors.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        level.label,
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '⭐ $xp XP',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF92400E)),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getMutedLightColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '⏱ $duration',
        style: Theme.of(context).textTheme.labelSmall,
      ),
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

    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: animationIndex * 60), duration: 300.ms),
        SlideEffect(
          begin: const Offset(0, 0.05), end: Offset.zero,
          delay: Duration(milliseconds: animationIndex * 60), duration: 300.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: 150.ms,
          decoration: BoxDecoration(
            color: isLocked ? AppColors.surface.withOpacity(0.6) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? AppColors.greenMid : context.borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4, offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Opacity(
            opacity: isLocked ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Dot
                  DifficultyDot(level: t.level),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 3),
                        Text(
                          t.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: [
                            DurationChip(duration: t.duration),
                            XpChip(xp: t.xp),
                            LevelChip(level: t.level),
                          ],
                        ),
                        // In-progress bar
                        if (status == TopicStatus.inProgress) ...[
                          const SizedBox(height: 10),
                          _ProgressRow(topicWithStatus: topicWithStatus),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action icon
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: topicWithStatus.progressPercent,
                  backgroundColor: context.borderColor,
                  color: AppColors.green,
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${topicWithStatus.completedSteps}/${topicWithStatus.topic.stepCount}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.greenDark),
            ),
          ],
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
    switch (status) {
      case TopicStatus.completed:
        return Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: AppColors.greenDark, size: 16),
        );
      case TopicStatus.locked:
        return const Icon(Icons.lock_outline_rounded, color: AppColors.muted, size: 20);
      case TopicStatus.inProgress:
        return const Icon(Icons.play_circle_filled_rounded, color: AppColors.green, size: 26);
      case TopicStatus.available:
        return const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.muted, size: 16);
    }
  }
}

// ── Filter chip row item ───────────────────────────────────────
class FilterChipItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterChipItem({
    super.key, required this.label, required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 150.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.green : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.green : context.borderColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isActive ? Colors.white : AppColors.getMutedColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Section header with progress ─────────────────────────────
class SectionGroupHeader extends StatelessWidget {
  final TopicLevel level;
  final int done;
  final int total;

  const SectionGroupHeader({
    super.key, required this.level, required this.done, required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Text(level.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            level.label.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const Spacer(),
          Text(
            '$done / $total done',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.greenDark),
          ),
        ],
      ),
    );
  }
}

// ── Empty search state ────────────────────────────────────────
class ExploreEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const ExploreEmptyState({super.key, required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
        child: Column(
          children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              'No topics match "$query"',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onClear,
              child: Text(
                'Clear search',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greenDark, fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Locked topic bottom sheet ─────────────────────────────────
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
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: context.borderColor, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('🔒', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text('Topic Locked', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            prerequisiteTitle != null
                ? 'Complete "$prerequisiteTitle" to unlock this topic.'
                : 'Complete the prerequisite topic first.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (onGoToPrerequisite != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); onGoToPrerequisite!(); },
                child: Text('Go to ${prerequisiteTitle ?? 'prerequisite'} →'),
              ),
            ),
          const SizedBox(height: 10),
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