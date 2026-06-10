import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_l10n.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/language_provider.dart';
import '../../../../../core/providers/notification_provider.dart';
import '../../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/actionprofile.dart';
import 'account_page.dart';
import 'legal_page.dart';
import '../widgets/settings_section.dart';
import '../providers/profileProvider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: profileAsync.when(
        data: (_) => _buildContent(context, ref, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(context, ref, l10n),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
  ) {
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      children: [
        SettingsSection(
          children: [
            SettingsRow(
              icon: Icons.person_outline_rounded,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: l10n.account,
              showChevron: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountPage()),
              ),
            ),
            SettingsRow(
              icon: Icons.notifications_none_rounded,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: l10n.notifications,
              showChevron: false,
              onTap: () => _showNotificationSettings(context, ref, l10n),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 10),

        _PreferencesSection().animate().fadeIn(delay: 60.ms, duration: 300.ms),

        const SizedBox(height: 10),

        SettingsSection(
          label: l10n.sectionAbout,
          children: [
            SettingsRow(
              icon: Icons.privacy_tip_outlined,
              iconBg: AppColors.mutedXLight,
              iconColor: AppColors.muted,
              label: l10n.privacyPolicy,
              showChevron: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalPage(
                    title: l10n.privacyPolicy,
                    lastUpdated: l10n.lastUpdated('June 2025'),
                    sections: l10n.privacyPolicySections,
                  ),
                ),
              ),
            ),
            SettingsRow(
              icon: Icons.article_outlined,
              iconBg: AppColors.mutedXLight,
              iconColor: AppColors.muted,
              label: l10n.termsOfService,
              showChevron: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LegalPage(
                    title: l10n.termsOfService,
                    lastUpdated: l10n.lastUpdated('June 2025'),
                    sections: l10n.termsOfServiceSections,
                  ),
                ),
              ),
            ),
            SettingsRow(
              icon: Icons.info_outline_rounded,
              iconBg: AppColors.mutedXLight,
              iconColor: AppColors.muted,
              label: l10n.appVersion,
              trailing: Text(
                '1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 120.ms, duration: 300.ms),

        const SizedBox(height: 10),

        SettingsSection(
          children: [
            SettingsRow(
              icon: Icons.logout_rounded,
              iconBg: AppColors.redLight,
              iconColor: AppColors.red,
              label: l10n.signOut,
              labelColor: AppColors.red,
              showChevron: false,
              onTap: () => _showLogoutConfirm(context, ref, l10n),
            ),
          ],
        ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

      ],
    );
  }

  void _showNotificationSettings(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationSettingsSheet(
        l10n: l10n,
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref, AppL10n l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmSheet(
        title: l10n.signOutTitle,
        body: l10n.signOutBody,
        confirmLabel: l10n.signOutConfirm,
        confirmColor: AppColors.red,
        onConfirm: () async {
          Navigator.pop(context);
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
      ),
    );
  }


}

class NotificationSettingsSheet extends ConsumerStatefulWidget {
  final AppL10n l10n;

  const NotificationSettingsSheet({super.key, required this.l10n});

  @override
  ConsumerState<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends ConsumerState<NotificationSettingsSheet> {
  late bool _enabled;
  late int _delayMinutes;

  @override
  void initState() {
    super.initState();
    final service = ref.read(notificationServiceProvider);
    _enabled = service.enabled;
    _delayMinutes = service.reminderDelayMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.notifications,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _enabled,
            title: Text(l10n.enableLessonReminders),
            subtitle: Text(l10n.remindersSubtitle),
            onChanged: (value) async {
              setState(() => _enabled = value);
              await ref.read(notificationServiceProvider).setEnabled(value);
            },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.reminderDelay,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [15, 30, 60].map((minutes) {
              return ChoiceChip(
                label: Text(l10n.minutesLabel(minutes)),
                selected: _delayMinutes == minutes,
                onSelected: _enabled
                    ? (selected) async {
                        if (!selected) return;
                        setState(() => _delayMinutes = minutes);
                        await ref
                            .read(notificationServiceProvider)
                            .setDelayMinutes(minutes);
                      }
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Preferences section (dark mode + language + currency) ──────
class _PreferencesSection extends ConsumerWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final themeAsync = ref.watch(themeNotifierProvider);
    final themeMode = themeAsync.valueOrNull ?? ThemeMode.system;
    final currentLang =
        ref.watch(languageNotifierProvider).valueOrNull ?? 'en';
    final surface = Theme.of(context).colorScheme.surface;

    final purpleBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D1F5E)
        : const Color(0xFFEDE9FE);
    const purpleFg = Color(0xFF7C3AED);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Text(
            l10n.sectionPreferences,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(letterSpacing: 0.6),
          ),
        ),
        Container(
          color: surface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: purpleBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.brightness_6_rounded,
                        color: purpleFg,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                          l10n.appearance,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ),
                    _ThemePill(themeMode: themeMode),
                  ],
                ),
              ),
              SettingsRow(
                icon: Icons.language_rounded,
                iconBg: purpleBg,
                iconColor: purpleFg,
                label: l10n.language,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      languageLabel(currentLang),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ],
                ),
                showChevron: false,
                onTap: () => _showLanguagePicker(context, ref, currentLang),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) {
    const options = [
      ('en', 'English', '🇬🇧'),
      ('ru', 'Русский', '🇷🇺'),
      ('kk', 'Қазақша', '🇰🇿'),
    ];

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              for (final (code, label, flag) in options)
                ListTile(
                  leading: Text(flag, style: const TextStyle(fontSize: 24)),
                  title: Text(label),
                  trailing: current == code
                      ? const Icon(Icons.check_rounded, color: Colors.green)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(languageNotifierProvider.notifier)
                        .setLanguage(code);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Three-segment theme pill ───────────────────────────────────
class _ThemePill extends ConsumerWidget {
  final ThemeMode themeMode;
  const _ThemePill({required this.themeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? const Color(0xFF3A3A3C)
        : const Color(0xFFE5E7EB);

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillSegment(
            icon: Icons.brightness_auto_rounded,
            selected: themeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () => ref
                .read(themeNotifierProvider.notifier)
                .setMode(ThemeMode.system),
          ),
          _PillSegment(
            icon: Icons.light_mode_rounded,
            selected: themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () => ref
                .read(themeNotifierProvider.notifier)
                .setMode(ThemeMode.light),
          ),
          _PillSegment(
            icon: Icons.dark_mode_rounded,
            selected: themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () => ref
                .read(themeNotifierProvider.notifier)
                .setMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _PillSegment extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _PillSegment({
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark ? const Color(0xFF636366) : Colors.white;
    final selectedIcon = isDark ? Colors.white : Colors.black87;
    final unselectedIcon = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 42,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          boxShadow: selected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? selectedIcon : unselectedIcon,
        ),
      ),
    );
  }
}
