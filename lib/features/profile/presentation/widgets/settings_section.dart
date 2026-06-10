import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
// ── Settings section wrapper ───────────────────────────────────
class SettingsSection extends StatelessWidget {
  final String? label;
  final List<Widget> children;
  const SettingsSection({super.key, this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              label!,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
            ),
          ),
        Container(
          color: surface,
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ── Single settings row ────────────────────────────────────────
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const SettingsRow({super.key, 
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontWeight: labelColor != null ? FontWeight.w500 : null,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}