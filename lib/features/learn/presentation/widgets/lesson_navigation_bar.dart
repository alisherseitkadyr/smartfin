import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Bottom navigation bar for the lesson flow: back button, page dots,
/// and a Next / Quiz button.
class LessonNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const LessonNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
  });

  bool get _isLastStep => currentIndex == totalSteps - 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: context.borderColor, width: 1)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: Text(l10n.back),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.muted,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          Expanded(
            child: _PageDots(
              currentIndex: currentIndex,
              totalSteps: totalSteps,
            ),
          ),
          _NextButton(
            isLastStep: _isLastStep,
            label: _isLastStep ? l10n.quiz : l10n.next,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  const _PageDots({required this.currentIndex, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentIndex;
        return AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.green : AppColors.mutedLight,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLastStep;
  final String label;
  final VoidCallback onTap;

  const _NextButton({
    required this.isLastStep,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(width: AppSpacing.sm - 2),
          Icon(
            isLastStep ? Icons.quiz_rounded : Icons.arrow_forward_rounded,
            size: 18,
          ),
        ],
      ),
    );
  }
}
