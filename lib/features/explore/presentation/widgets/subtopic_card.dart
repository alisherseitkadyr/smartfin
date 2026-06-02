import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';

/// Single row in the curriculum list on the topic preview page.
class SubtopicCard extends StatelessWidget {
  final SubtopicItem subtopic;
  final int index;
  final bool isSelected;
  final bool isDone;
  final bool isLocked;
  final VoidCallback? onTap;

  const SubtopicCard({
    super.key,
    required this.subtopic,
    required this.index,
    required this.isSelected,
    this.isDone = false,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark ? const Color(0xFF1B2A3A) : const Color(0xFFEAF2FF);
    final doneBg = isDark ? AppColors.greenDeep : AppColors.greenLight;
    final doneCircleBg = isDark ? AppColors.greenDark : AppColors.greenMid;
    final doneIconBg = isDark ? AppColors.greenDeep : AppColors.greenLight;
    final lockedBg = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final lockedCircleBg = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final lockedTextColor = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

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

    Color badgeColor() {
      if (isSelected) return const Color(0xFF3B82F6);
      if (isDone) return doneCircleBg;
      if (isLocked) return lockedCircleBg;
      return const Color.fromARGB(255, 229, 255, 245);
    }

    Widget badgeChild() {
      if (isDone && !isSelected) {
        return const Icon(Icons.check_rounded, size: 16, color: Colors.white);
      }
      if (isLocked) {
        return Icon(Icons.lock_outline_rounded, size: 14, color: lockedTextColor);
      }
      return Text(
        '${index + 1}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : const Color(0xFF2563EB),
        ),
      );
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedBg
                  : isDone
                      ? doneBg
                      : isLocked
                          ? lockedBg
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
                    color: badgeColor(),
                  ),
                  child: Center(child: badgeChild()),
                ),

                const SizedBox(width: 12),

                // ── Content ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtopic.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected
                                  ? (isDark ? Colors.white : const Color(0xFF1D4ED8))
                                  : isLocked
                                      ? lockedTextColor
                                      : null,
                            ),
                      ),
                      if (subtopic.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtopic.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? (isDark ? Colors.white70 : const Color(0xFF2563EB))
                                    : isLocked
                                        ? lockedTextColor
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isLocked
                                  ? lockedTextColor
                                  : AppColors.getMutedColor(context),
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
                          color: isSelected || isDone || isLocked
                              ? Colors.transparent
                              : AppColors.green,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        isSelected || isDone
                            ? Icons.check_rounded
                            : isLocked
                                ? Icons.lock_outline_rounded
                                : Icons.play_arrow_rounded,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : isDone
                                ? AppColors.greenDark
                                : isLocked
                                    ? lockedTextColor
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
        .slideX(begin: 0.04, end: 0, curve: Curves.easeOut);
  }
}
