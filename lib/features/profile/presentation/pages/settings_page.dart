import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_l10n.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/providers/language_provider.dart';
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 60,
            surfaceTintColor: Colors.transparent,
            elevation: 0.5,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 20, 14),
              title: Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: profileAsync.when(
              data: (profile) =>
                  _buildContent(context, ref, l10n, profile.name, profile.email),
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _buildContent(context, ref, l10n, '', ''),
            ),
          ),
        ],
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
    return Column(
      children: [
        const SizedBox(height: 10),

        SettingsSection(
          label: l10n.sectionAccount,
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
              onTap: () => _showComingSoon(context, l10n),
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

        const SizedBox(height: 100),
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
