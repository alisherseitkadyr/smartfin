import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../domain/entities/lesson_topic.dart';

/// Single "Up next" card — shows either the next subtopic or the next topic.
class UpNextCard extends StatelessWidget {
  final UpNextItem item;
  final VoidCallback? onTap;

  const UpNextCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: switch (item) {
        UpNextSubtopic() => _SubtopicUpNextCard(
            item: item as UpNextSubtopic,
            onTap: onTap,
          )
              .animate()
              .fadeIn(duration: AppDurations.cta)
              .slideX(begin: 0.05, end: 0, duration: AppDurations.cta, curve: Curves.easeOut),
        UpNextNextTopic() => _TopicUpNextCard(
            item: item as UpNextNextTopic,
            onTap: onTap,
          )
              .animate()
              .fadeIn(duration: AppDurations.cta)
              .slideX(begin: 0.05, end: 0, duration: AppDurations.cta, curve: Curves.easeOut),
      },
    );
  }
}

class _SubtopicUpNextCard extends ConsumerWidget {
  final UpNextSubtopic item;
  final VoidCallback? onTap;
  const _SubtopicUpNextCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final isDone = item.isCompleted;
    final isLocked = item.isLocked;
    final effectiveOnTap = isLocked ? null : onTap;

    return GestureDetector(
      onTap: effectiveOnTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isDone
                ? AppColors.greenMid
                : isLocked
                    ? context.borderColor.withValues(alpha: 0.5)
                    : context.borderColor,
            width: 1.5,
          ),
          boxShadow: isLocked ? null : AppShadows.card,
        ),
        child: Row(
          children: [
            _Badge(
              index: item.subtopic.orderIndex,
              isDone: isDone,
              isLocked: isLocked,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subtopic.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 13,
                          color: isLocked
                              ? AppColors.getMutedColor(context)
                              : null,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                    Text(
                    isDone
                      ? '✅ Done'
                      : isLocked
                        ? '🔒 Complete previous first'
                        : '⏱ ${l10n.minutesLabel(item.subtopic.estimatedMinutes)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: isDone
                          ? AppColors.greenDark
                          : AppColors.getMutedColor(context),
                      ),
                    ),
                ],
              ),
            ),
            if (!isLocked)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.getMutedColor(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int index;
  final bool isDone;
  final bool isLocked;
  const _Badge({required this.index, required this.isDone, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Widget child;
    if (isDone) {
      bg = isDark ? AppColors.greenDark : AppColors.greenMid;
      child = const Icon(Icons.check_rounded, size: 14, color: Colors.white);
    } else if (isLocked) {
      bg = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      child = Icon(Icons.lock_outline_rounded, size: 13,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500);
    } else {
      bg = isDark ? const Color(0xFF1B2A3A) : const Color(0xFFEAF2FF);
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2563EB),
        ),
      );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _TopicUpNextCard extends StatelessWidget {
  final UpNextNextTopic item;
  final VoidCallback? onTap;
  const _TopicUpNextCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = item.nearbyTopic.topic;
    final isDone = item.nearbyTopic.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isDone ? AppColors.greenMid : context.borderColor,
            width: 1.5,
          ),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            _TopicIcon(icon: t.icon, iconPath: t.iconPath, size: 26),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone ? '✅ Done' : '⭐ ${t.xp} XP',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          color: isDone
                              ? AppColors.greenDark
                              : AppColors.getMutedColor(context),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.getMutedColor(context),
            ),
          ],
        ),
      ),
    );
  }
}

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
              _TopicIcon(icon: t.icon, iconPath: t.iconPath, size: 20),
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

class _TopicIcon extends StatelessWidget {
  final String icon;
  final String? iconPath;
  final double size;

  const _TopicIcon({required this.icon, this.iconPath, required this.size});

  @override
  Widget build(BuildContext context) {
    final path = iconPath;
    if (path != null && path.isNotEmpty) {
      return path.startsWith('http')
          ? Image.network(path, width: size, height: size, fit: BoxFit.contain)
          : Image.asset(path, width: size, height: size, fit: BoxFit.contain);
    }
    return Text(icon, style: TextStyle(fontSize: size));
  }
}
