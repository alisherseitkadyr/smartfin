import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/topic_item.dart';
import 'hero_chip.dart';
import 'topic_progress_section.dart';

/// Maps a [CategoryColor] to hero background and accent colors.
extension CategoryColorTheme on CategoryColor? {
  Color get heroBg {
    switch (this) {
      case CategoryColor.blue:
        return AppColors.blueLight;
      case CategoryColor.navy:
        return AppColors.indigoLight;
      case CategoryColor.green:
        return AppColors.greenLight;
      default:
        return AppColors.green;
    }
  }

  Color get heroAccent {
    switch (this) {
      case CategoryColor.blue:
        return AppColors.indigoDark;
      case CategoryColor.navy:
        return AppColors.navy;
      case CategoryColor.green:
        return AppColors.greenDark;
      default:
        return AppColors.greenDark;
    }
  }
}

/// Hero section at the top of [TopicPreviewPage]: icon, title, description,
/// metadata chips, and an optional in-progress bar.
class TopicPreviewHeader extends StatelessWidget {
  final TopicWithStatus topicWithStatus;
  final Color heroBg;
  final Color heroAccent;

  const TopicPreviewHeader({
    super.key,
    required this.topicWithStatus,
    required this.heroBg,
    required this.heroAccent,
  });

  @override
  Widget build(BuildContext context) {
    final t = topicWithStatus.topic;

    return Container(
      color: heroBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BackButton(accent: heroAccent),
              const SizedBox(height: AppSpacing.xl),
              _TopicIconBadge(icon: t.icon, iconPath: t.iconPath),
              const SizedBox(height: 14),
              Text(t.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm - 2),
              Text(
                t.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: heroAccent.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  HeroInfoChip(label: t.level.label, accent: heroAccent),
                  HeroInfoChip(label: '⭐ ${t.xp} XP', accent: heroAccent),
                  HeroInfoChip(label: '⏱ ${t.duration}', accent: heroAccent),
                ],
              ),
              if (topicWithStatus.isInProgress) ...[
                const SizedBox(height: AppSpacing.lg),
                TopicProgressSection(
                  topicWithStatus: topicWithStatus,
                  accent: heroAccent,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppDurations.slow);
  }
}

class _BackButton extends StatelessWidget {
  final Color accent;
  const _BackButton({required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: accent),
      ),
    );
  }
}

class _TopicIconBadge extends StatelessWidget {
  final String icon;
  final String? iconPath;
  const _TopicIconBadge({required this.icon, this.iconPath});

  @override
  Widget build(BuildContext context) {
    Widget child;
    final path = iconPath;
    if (path != null && path.isNotEmpty) {
      child = ClipOval(
        child: path.startsWith('http')
            ? Image.network(path, width: 64, height: 64, fit: BoxFit.cover)
            : Image.asset(path, width: 64, height: 64, fit: BoxFit.cover),
      );
    } else {
      child = Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 30)),
        ),
      );
    }
    return child;
  }
}
