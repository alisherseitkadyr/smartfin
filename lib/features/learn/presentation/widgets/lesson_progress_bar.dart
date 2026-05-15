import 'package:flutter/material.dart';

import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated progress bar shared between lesson flow and quiz pages.
///
/// Smoothly animates from the previous [value] to the new one whenever
/// the widget rebuilds — no sudden jumps.
class LessonProgressBar extends StatefulWidget {
  final double value;
  final Color? trackColor;

  const LessonProgressBar({super.key, required this.value, this.trackColor});

  @override
  State<LessonProgressBar> createState() => _LessonProgressBarState();
}

class _LessonProgressBarState extends State<LessonProgressBar> {
  double _from = 0;

  @override
  void didUpdateWidget(LessonProgressBar old) {
    super.didUpdateWidget(old);
    _from = old.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm + 2,
        AppSpacing.xl,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: _from, end: widget.value),
          duration: AppDurations.progressBar,
          curve: Curves.easeOut,
          builder: (context, v, _) => LinearProgressIndicator(
            value: v,
            backgroundColor:
                widget.trackColor ?? AppColors.getMutedLightColor(context),
            color: AppColors.green,
            minHeight: 6,
          ),
        ),
      ),
    );
  }
}
