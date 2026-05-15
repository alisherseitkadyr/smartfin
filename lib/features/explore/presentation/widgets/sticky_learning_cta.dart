import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Full-width sticky button shown at the bottom of the topic preview page
/// once the user has selected a subtopic.
class StickyLearningCta extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final VoidCallback? onTap;

  const StickyLearningCta({
    super.key,
    required this.label,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = AppColors.getMutedColor(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompleted ? context.borderColor : AppColors.green,
            foregroundColor: isCompleted ? disabledColor : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isCompleted ? disabledColor : Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
