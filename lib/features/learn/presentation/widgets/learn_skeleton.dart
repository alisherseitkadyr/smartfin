import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Animated shimmer skeleton used throughout the Learn feature while
/// async data is loading.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: context.mutedLight,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        );
  }
}

/// Full-page skeleton shown while the current lesson loads on [LearnPage].
class LearnPageSkeleton extends StatelessWidget {
  const LearnPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.greenDark, AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 14),
                const SizedBox(height: AppSpacing.lg),
                SkeletonBox(width: double.infinity, height: 80),
                const SizedBox(height: AppSpacing.lg),
                SkeletonBox(width: double.infinity, height: 80),
                const SizedBox(height: AppSpacing.lg),
                SkeletonBox(width: double.infinity, height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
