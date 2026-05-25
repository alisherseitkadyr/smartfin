import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_topic.dart';

/// Horizontal scrollable row of nearby / "Up next" topic cards.
class NearbyTopicsRow extends StatelessWidget {
  final List<NearbyTopic> topics;
  final ValueChanged<NearbyTopic> onTap;

  const NearbyTopicsRow({super.key, required this.topics, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm + 2),
        itemBuilder: (context, i) {
          return _NearbyTopicCard(
                nearby: topics[i],
                onTap: () => onTap(topics[i]),
              )
              .animate(delay: AppDurations.staggerStep * i)
              .fadeIn(duration: AppDurations.cta)
              .slideX(
                begin: 0.05,
                end: 0,
                duration: AppDurations.cta,
                curve: Curves.easeOut,
              );
        },
      ),
    );
  }
}

class _NearbyTopicCard extends StatelessWidget {
  final NearbyTopic nearby;
  final VoidCallback onTap;
  const _NearbyTopicCard({required this.nearby, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = nearby.topic;
    final isDone = nearby.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: AppDurations.fast,
        opacity: 1.0,
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: isDone ? AppColors.greenMid : context.borderColor,
              width: 1.5,
            ),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: AppSpacing.sm - 2),
              Expanded(
                child: Text(
                  t.title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(height: 1.2, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.sm - 2),
              Text(
                isDone ? '✅ Done' : '⭐ ${t.xp} XP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDone
                      ? AppColors.greenDark
                      : AppColors.getMutedColor(context),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
