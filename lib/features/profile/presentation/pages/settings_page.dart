import 'package:flutter/foundation.dart' show kDebugMode;
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
import '../widgets/editprofile.dart';
import '../widgets/actionprofile.dart';
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
        data: (profile) =>
            _buildContent(context, ref, l10n, profile.name, profile.email),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(context, ref, l10n, '', ''),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
    String name,
    String email,
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
              label: l10n.editProfile,
              onTap: () => _showEditProfile(context, name, email),
            ),
            SettingsRow(
              icon: Icons.notifications_none_rounded,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: l10n.notifications,
              onTap: () => _showNotificationSettings(context, ref, l10n),
            ),
            SettingsRow(
              icon: Icons.lock_outline_rounded,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: l10n.changePassword,
              onTap: () => _showComingSoon(context, l10n),
              isLast: true,
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
              onTap: () => _showComingSoon(context, l10n),
            ),
            SettingsRow(
              icon: Icons.article_outlined,
              iconBg: AppColors.mutedXLight,
              iconColor: AppColors.muted,
              label: l10n.termsOfService,
              onTap: () => _showComingSoon(context, l10n),
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
              showChevron: false,
              isLast: true,
            ),
          ],
        ).animate().fadeIn(delay: 120.ms, duration: 300.ms),

        const SizedBox(height: 10),

        SettingsSection(
          children: [
            SettingsRow(
              icon: Icons.delete_outline_rounded,
              iconBg: AppColors.redLight,
              iconColor: AppColors.red,
              label: l10n.deleteAccount,
              labelColor: AppColors.red,
              showChevron: false,
              onTap: () => _showDeleteConfirm(context, ref, l10n),
            ),
            SettingsRow(
              icon: Icons.logout_rounded,
              iconBg: AppColors.redLight,
              iconColor: AppColors.red,
              label: l10n.signOut,
              labelColor: AppColors.red,
              showChevron: false,
              isLast: true,
              onTap: () => _showLogoutConfirm(context, ref, l10n),
            ),
          ],
        ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

      ],
    );
  }

  void _showComingSoon(BuildContext context, AppL10n l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoon),
        backgroundColor: AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(seconds: 1),
      ),
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

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, AppL10n l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmSheet(
        title: l10n.deleteAccountTitle,
        body: l10n.deleteAccountBody,
        confirmLabel: l10n.deleteAccountConfirm,
        confirmColor: AppColors.red,
        onConfirm: () async {
          Navigator.pop(context);
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
      ),
    );
  }

  void _showEditProfile(BuildContext context, String name, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(name: name, email: email),
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
            title: Text('Enable lesson reminders'),
            subtitle: Text('Receive a notification when it is time to return.'),
            onChanged: (value) async {
              setState(() => _enabled = value);
              await ref.read(notificationServiceProvider).setEnabled(value);
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Reminder delay',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [1, 15, 30, 60].map((minutes) {
              return ChoiceChip(
                label: Text('${minutes}m'),
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
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
          if (kDebugMode) ...[
            const Divider(height: 32),
            _DebugNotificationPanel(),
          ],
        ],
      ),
    );
  }
}

// ── Debug notification panel (debug builds only) ───────────────
class _DebugNotificationPanel extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DebugNotificationPanel> createState() =>
      _DebugNotificationPanelState();
}

class _DebugNotificationPanelState
    extends ConsumerState<_DebugNotificationPanel> {
  Map<String, String> _status = {};
  bool _repeating = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final s = await ref.read(notificationServiceProvider).debugStatus();
    if (mounted) setState(() => _status = s);
  }

  @override
  Widget build(BuildContext context) {
    final svc = ref.read(notificationServiceProvider);
    final ok = _status['initialized'] == 'true' &&
        _status['permission'] == 'true';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DEBUG',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: Colors.orange)),
        const SizedBox(height: 6),
        // Status rows
        for (final entry in _status.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Text('${entry.key}: ',
                    style: Theme.of(context).textTheme.bodySmall),
                Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: entry.value == 'true'
                        ? Colors.green
                        : entry.value == 'false'
                            ? Colors.red
                            : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        if (!ok && _status.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Permission denied or not initialized — tap "Grant permission" first',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.red),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () async {
                await svc.requestPermissions();
                await _loadStatus();
              },
              child: const Text('Grant permission'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                await svc.debugShowNow();
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('show() called — check status bar')),
                );
                await _loadStatus();
              },
              child: const Text('Show now'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                if (_repeating) {
                  await svc.debugStop();
                  setState(() => _repeating = false);
                } else {
                  await svc.debugStartMinuteRepeating();
                  setState(() => _repeating = true);
                }
                await _loadStatus();
              },
              style: _repeating
                  ? FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade100)
                  : null,
              child: Text(_repeating ? 'Stop repeating' : 'Every minute'),
            ),
            OutlinedButton(
              onPressed: _loadStatus,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ],
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
    final platformIsDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformIsDark);
    final surface = Theme.of(context).colorScheme.surface;
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? context.borderColor;
    final purpleBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D1F5E)
        : const Color(0xFFEDE9FE);
    const purpleFg = Color(0xFF7C3AED);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
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
              InkWell(
                onTap: () => ref
                    .read(themeNotifierProvider.notifier)
                    .setMode(isDark ? ThemeMode.light : ThemeMode.dark),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: dividerColor, width: 1),
                    ),
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
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: purpleFg,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          l10n.darkTheme,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _ToggleSwitch(isOn: isDark),
                    ],
                  ),
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
              SettingsRow(
                icon: Icons.currency_exchange_rounded,
                iconBg: purpleBg,
                iconColor: purpleFg,
                label: l10n.currency,
                isLast: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₸ KZT',
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
                onTap: () {},
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

// ── Animated toggle switch ─────────────────────────────────────
class _ToggleSwitch extends StatelessWidget {
  final bool isOn;
  const _ToggleSwitch({required this.isOn});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 46,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: isOn ? AppColors.green : context.borderColor,
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: isOn ? 22 : 2,
            top: 3,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
