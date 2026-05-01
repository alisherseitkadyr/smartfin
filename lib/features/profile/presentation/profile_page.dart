import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../home/presentation/providers/home_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeDataProvider);
    final authAsync = ref.watch(authNotifierProvider);

    final userName = authAsync.valueOrNull?.user?.name ?? 'User';
    final userEmail = authAsync.valueOrNull?.user?.email ?? '';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: _bg(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            expandedHeight: 60,
            surfaceTintColor: Colors.transparent,
            elevation: 0.5,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Text(
                'Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Header card ──────────────────────────────
                _ProfileHeader(
                  name: userName,
                  email: userEmail,
                  initial: initial,
                  homeAsync: homeAsync,
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 10),

                // ── Account section ──────────────────────────
                _SettingsSection(
                  label: 'ACCOUNT',
                  children: [
                    _SettingsRow(
                      icon: Icons.person_outline_rounded,
                      iconBg: AppColors.blueLight,
                      iconColor: AppColors.blue,
                      label: 'Edit profile',
                      onTap: () =>
                          _showEditProfile(context, userName, userEmail),
                    ),
                    _SettingsRow(
                      icon: Icons.notifications_none_rounded,
                      iconBg: AppColors.blueLight,
                      iconColor: AppColors.blue,
                      label: 'Notifications',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsRow(
                      icon: Icons.lock_outline_rounded,
                      iconBg: AppColors.blueLight,
                      iconColor: AppColors.blue,
                      label: 'Change password',
                      onTap: () => _showComingSoon(context),
                      isLast: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 60.ms, duration: 300.ms),

                const SizedBox(height: 10),

                // ── Preferences section ──────────────────────
                _PreferencesSection().animate().fadeIn(
                  delay: 120.ms,
                  duration: 300.ms,
                ),

                const SizedBox(height: 10),

                // ── About section ────────────────────────────
                _SettingsSection(
                  label: 'ABOUT',
                  children: [
                    _SettingsRow(
                      icon: Icons.privacy_tip_outlined,
                      iconBg: AppColors.mutedXLight,
                      iconColor: AppColors.muted,
                      label: 'Privacy policy',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsRow(
                      icon: Icons.article_outlined,
                      iconBg: AppColors.mutedXLight,
                      iconColor: AppColors.muted,
                      label: 'Terms of service',
                      onTap: () => _showComingSoon(context),
                    ),
                    _SettingsRow(
                      icon: Icons.info_outline_rounded,
                      iconBg: AppColors.mutedXLight,
                      iconColor: AppColors.muted,
                      label: 'App version',
                      trailing: Text(
                        '1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      showChevron: false,
                      isLast: true,
                    ),
                  ],
                ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

                const SizedBox(height: 10),

                // ── Danger zone ──────────────────────────────
                _SettingsSection(
                  children: [
                    _SettingsRow(
                      icon: Icons.delete_outline_rounded,
                      iconBg: AppColors.redLight,
                      iconColor: AppColors.red,
                      label: 'Delete account',
                      labelColor: AppColors.red,
                      showChevron: false,
                      onTap: () => _showDeleteConfirm(context, ref),
                    ),
                    _SettingsRow(
                      icon: Icons.logout_rounded,
                      iconBg: AppColors.redLight,
                      iconColor: AppColors.red,
                      label: 'Sign out',
                      labelColor: AppColors.red,
                      showChevron: false,
                      isLast: true,
                      onTap: () => _showLogoutConfirm(context, ref),
                    ),
                  ],
                ).animate().fadeIn(delay: 240.ms, duration: 300.ms),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _bg(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF0F1117)
        : AppColors.bg;
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon'),
        backgroundColor: AppColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        title: 'Sign out?',
        body: 'You can sign back in anytime.',
        confirmLabel: 'Sign out',
        confirmColor: AppColors.red,
        onConfirm: () async {
          Navigator.pop(context);
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        },
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmSheet(
        title: 'Delete account?',
        body:
            'This will permanently delete all your data, progress, and settings. This action cannot be undone.',
        confirmLabel: 'Delete account',
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
      builder: (_) => _EditProfileSheet(name: name, email: email),
    );
  }
}

// ── Profile header ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String initial;
  final AsyncValue homeAsync;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.initial,
    required this.homeAsync,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Avatar + info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green, AppColors.greenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Sora',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(email, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: const [
                        _StatBadge(
                          text: 'Level 5',
                          bg: AppColors.greenLight,
                          fg: AppColors.greenDark,
                        ),
                        _StatBadge(
                          text: '2,150 XP',
                          bg: AppColors.amberLight,
                          fg: Color(0xFFD97706),
                        ),
                        _StatBadge(
                          text: '🔥 12 days',
                          bg: Color(0xFFFFF7ED),
                          fg: Color(0xFFEA580C),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),

          // Stats row
          IntrinsicHeight(
            child: Row(
              children: [
                _StatCell(value: '3/7', label: 'Topics done'),
                const VerticalDivider(width: 1),
                _StatCell(value: '12', label: 'Day streak'),
                const VerticalDivider(width: 1),
                _StatCell(value: '2,150', label: 'Total XP'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _StatBadge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ── Settings section wrapper ───────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String? label;
  final List<Widget> children;
  const _SettingsSection({this.label, required this.children});

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
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final Widget? trailing;
  final bool showChevron;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.trailing,
    this.showChevron = true,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? context.borderColor;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: dividerColor, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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

// ── Preferences section (dark mode toggle + language/currency) ─
class _PreferencesSection extends ConsumerWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeNotifierProvider);
    final themeMode = themeAsync.valueOrNull ?? ThemeMode.system;
    final platformIsDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && platformIsDark);
    final surface = Theme.of(context).colorScheme.surface;
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? context.borderColor;
    final purpleBg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2D1F5E)
        : const Color(0xFFEDE9FE);
    final purpleFg = const Color(0xFF7C3AED);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Text(
            'PREFERENCES',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(letterSpacing: 0.6),
          ),
        ),
        Container(
          color: surface,
          child: Column(
            children: [
              // Dark theme toggle
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
                          'Dark theme',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // Custom toggle switch
                      _ToggleSwitch(isOn: isDark),
                    ],
                  ),
                ),
              ),

              // Language
              _SettingsRow(
                icon: Icons.language_rounded,
                iconBg: purpleBg,
                iconColor: purpleFg,
                label: 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'English',
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

              // Currency
              _SettingsRow(
                icon: Icons.currency_exchange_rounded,
                iconBg: purpleBg,
                iconColor: purpleFg,
                label: 'Currency',
                isLast: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₸ KZT', style: Theme.of(context).textTheme.bodySmall),
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

// ── Confirm bottom sheet ───────────────────────────────────────
class _ConfirmSheet extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.muted,
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: BorderSide(color: context.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit profile bottom sheet ──────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final String name;
  final String email;
  const _EditProfileSheet({required this.name, required this.email});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Edit profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text('Full name', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: 16),
            Text('Email', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.email),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              decoration: const InputDecoration(
                hintText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
