import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';

/// Single row in the curriculum list on the topic preview page.
class SubtopicCard extends StatelessWidget {
  final SubtopicItem subtopic;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const SubtopicCard({
    super.key,
    required this.subtopic,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.greenLight.withValues(alpha: 0.6)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: isSelected ? AppColors.greenMid : context.borderColor,
                width: 1.5,
              ),
              boxShadow: AppShadows.card,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md + 2,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _OrderBadge(index: index),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _SubtopicInfo(subtopic: subtopic)),
                const SizedBox(width: AppSpacing.sm),
                if (subtopic.estimatedMinutes > 0)
                  _MinutesLabel(minutes: subtopic.estimatedMinutes),
                const SizedBox(width: AppSpacing.sm - 2),
                const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.green,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: AppDurations.staggerStep * index)
        .fadeIn(duration: AppDurations.medium)
        .slideX(
          begin: 0.04,
          end: 0,
          duration: AppDurations.medium,
          curve: Curves.easeOut,
        );
  }
}

class _OrderBadge extends StatelessWidget {
  final int index;
  const _OrderBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: AppColors.greenLight,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.greenDark,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _SubtopicInfo extends StatelessWidget {
  final SubtopicItem subtopic;
  const _SubtopicInfo({required this.subtopic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtopic.title, style: Theme.of(context).textTheme.titleSmall),
        if (subtopic.description.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtopic.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _MinutesLabel extends StatelessWidget {
  final int minutes;
  const _MinutesLabel({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$minutes min',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.getMutedColor(context),
          ),
    );
  }
}
