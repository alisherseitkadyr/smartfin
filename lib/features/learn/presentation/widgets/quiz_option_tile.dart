import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

class QuizOptionTile extends StatelessWidget {
  final int index;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;   // green — confirmed correct in review
  final bool isWrong;     // red  — confirmed wrong in review
  final bool isDisabled;  // greyed out (not selected, answer is locked)

  static const _letters = ['A', 'B', 'C', 'D', 'E'];

  const QuizOptionTile({
    super.key,
    required this.index,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final letter = _letters[index % _letters.length];

    final Color bg;
    final Color border;
    final Color textColor;
    final Widget? trailing;

    if (isCorrect) {
      bg = AppColors.greenLight;
      border = AppColors.green;
      textColor = AppColors.greenDark;
      trailing = const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20);
    } else if (isWrong) {
      bg = AppColors.redLight;
      border = AppColors.red;
      textColor = AppColors.red;
      trailing = const Icon(Icons.cancel_rounded, color: AppColors.red, size: 20);
    } else if (isSelected) {
      bg = Theme.of(context).colorScheme.surface;
      border = AppColors.green;
      textColor = AppColors.getTextColor(context);
      trailing = const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20);
    } else if (isDisabled) {
      bg = AppColors.getMutedXLightColor(context);
      border = AppColors.getMutedLightColor(context);
      textColor = AppColors.getMutedColor(context);
      trailing = null;
    } else {
      bg = Theme.of(context).colorScheme.surface;
      border = context.borderColor;
      textColor = AppColors.getTextColor(context);
      trailing = null;
    }

    final isActive = isSelected || isCorrect || isWrong;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.medium,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: border, width: isActive ? 2 : 1.5),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            _LetterBadge(
              letter: letter,
              isSelected: isSelected,
              isCorrect: isCorrect,
              isWrong: isWrong,
              isDisabled: isDisabled,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: textColor,
                    ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;

  const _LetterBadge({
    required this.letter,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (isWrong) {
      bg = AppColors.red;
      fg = Colors.white;
    } else if (isCorrect) {
      bg = AppColors.green;
      fg = Colors.white;
    } else if (isSelected) {
      bg = AppColors.greenLight;
      fg = AppColors.green;
    } else if (isDisabled) {
      bg = AppColors.getMutedXLightColor(context);
      fg = AppColors.getMutedColor(context);
    } else {
      bg = context.mutedXLight;
      fg = AppColors.getMutedColor(context);
    }

    return AnimatedContainer(
      duration: AppDurations.medium,
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
