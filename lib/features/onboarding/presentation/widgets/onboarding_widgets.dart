import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ── Progress header ───────────────────────────────────────────────────────────

class OnboardingHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback? onBack;

  const OnboardingHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  color: AppColors.muted,
                  iconSize: 20,
                )
              else
                const SizedBox(width: 48),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: (step - 1) / totalSteps, end: progress),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: v,
                      backgroundColor: Theme.of(context).dividerColor,
                      color: AppColors.green,
                      minHeight: 6,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$step/$totalSteps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Single-select option card ─────────────────────────────────────────────────

class OptionCard extends StatelessWidget {
  final String value;
  final String label;
  final String? subtitle;
  final String? emoji;
  final bool selected;
  final ValueChanged<String> onTap;

  const OptionCard({
    super.key,
    required this.value,
    required this.label,
    this.subtitle,
    this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark
        ? AppColors.green.withValues(alpha: 0.15)
        : AppColors.greenLight;

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? selectedBg
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.greenDark : null,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.green : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.green : Theme.of(context).dividerColor,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Multi-select topic chip ───────────────────────────────────────────────────

class TopicChip extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  final bool selected;
  final ValueChanged<String> onToggle;

  const TopicChip({
    super.key,
    required this.value,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark
        ? AppColors.green.withValues(alpha: 0.15)
        : AppColors.greenLight;

    return GestureDetector(
      onTap: () => onToggle(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? selectedBg
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.greenDark : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step content shell ────────────────────────────────────────────────────────

class StepContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;

  const StepContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.muted,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 24),
          body,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Continue / finish button ──────────────────────────────────────────────────

class ContinueButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final bool isLastStep;
  final VoidCallback? onTap;

  const ContinueButton({
    super.key,
    required this.enabled,
    required this.isLoading,
    required this.isLastStep,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(
        width: double.infinity,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1.0 : 0.45,
          child: ElevatedButton(
            onPressed: enabled && !isLoading ? onTap : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.green,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    isLastStep ? 'Start Learning' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
