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
  final bool isDone;
  final VoidCallback onTap;

  const SubtopicCard({
    super.key,
    required this.subtopic,
    required this.index,
    required this.isSelected,
    this.isDone = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark
        ? const Color(0xFF1B2A3A)
        : const Color(0xFFEAF2FF);

    final selectedBorder = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF3B82F6);

    final doneBg = isDark ? AppColors.greenDeep : AppColors.greenLight;
    final doneCircleBg = isDark ? AppColors.greenDark : AppColors.greenMid;
    final doneIconBg = isDark ? AppColors.greenDeep : AppColors.greenLight;

    final baseShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      )
    ];

    final selectedShadow = [
      BoxShadow(
        color: Colors.blue.withValues(alpha: 0.18),
        blurRadius: 18,
        offset: const Offset(0, 6),
      )
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedBg
                  : isDone
                      ? doneBg
                      : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
    
              boxShadow: isSelected ? selectedShadow : baseShadow,
            ),
            child: Row(
              children: [
                // ── Step indicator ──
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : isDone
                            ? doneCircleBg
                            : const Color.fromARGB(255, 229, 255, 245),
                  ),
                  child: Center(
                    child: isDone && !isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtopic.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF1D4ED8))
                                  : null,
                            ),
                      ),

                      if (subtopic.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtopic.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isSelected
                                    ? (isDark
                                        ? Colors.white70
                                        : const Color(0xFF2563EB))
                                    : null,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ── Right side info ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (subtopic.estimatedMinutes > 0)
                      Text(
                        '${subtopic.estimatedMinutes} min',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color:
                                  AppColors.getMutedColor(
                                    context,
                                  ),
                            ),
                      ),

                    const SizedBox(height: 6),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : isDone
                                ? doneIconBg
                                : Colors.transparent,
                        border: Border.all(
                          color: isSelected || isDone
                              ? Colors.transparent
                              : AppColors.green,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isSelected || isDone
                            ? Icons.check_rounded
                            : Icons.play_arrow_rounded,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : isDone
                                ? AppColors.greenDark
                                : AppColors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 220.ms)
        .slideX(
          begin: 0.04,
          end: 0,
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
