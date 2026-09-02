import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_l10n.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/actionprofile.dart';
import '../widgets/settings_section.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

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
          'Account',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: profileAsync.when(
        data: (profile) => _buildContent(context, ref, l10n, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildContent(
          context,
          ref,
          l10n,
          const UserProfile(name: '', email: '', status: '', xp: 0, topicsCompleted: 0),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppL10n l10n,
    UserProfile profile,
  ) {
    final mutedStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.muted,
    );

    Widget valueChevron(String value) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: mutedStyle),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
      ],
    );

    return ListView(
      padding: EdgeInsets.only(
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
      ),
      children: [
        SettingsSection(
          children: [
            SettingsRow(
              icon: Icons.person_outline_rounded,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: l10n.nameLabel,
              trailing: valueChevron(profile.name),
              showChevron: false,
              onTap: () => _editName(context, profile),
            ),
            SettingsRow(
              icon: Icons.email_outlined,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: 'Email',
              trailing: Text(profile.email, style: mutedStyle),
              showChevron: false,
            ),
            SettingsRow(
              icon: Icons.lock_outline_rounded,
              iconBg: AppColors.blueLight,
              iconColor: AppColors.blue,
              label: 'Password',
              trailing: valueChevron('••••••••'),
              showChevron: false,
              onTap: () => _editPassword(context),
            ),
          ],
        ),
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
          ],
        ),
      ],
    );
  }

  void _editName(BuildContext context, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NameEditSheet(initialName: profile.name),
    );
  }

  void _editPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PasswordEditSheet(),
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
          Navigator.pop(context); // close ConfirmSheet
          final navigator = Navigator.of(context);
          await ref.read(authNotifierProvider.notifier).deleteAccount();
          navigator.pop(); // pop AccountPage
          appRouter.go('/login');
        },
      ),
    );
  }
}

// ── Name edit sheet ────────────────────────────────────────────
class _NameEditSheet extends ConsumerStatefulWidget {
  final String initialName;
  const _NameEditSheet({required this.initialName});

  @override
  ConsumerState<_NameEditSheet> createState() => _NameEditSheetState();
}

class _NameEditSheetState extends ConsumerState<_NameEditSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            Text(ref.watch(appL10nProvider).nameLabel, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Text(ref.watch(appL10nProvider).fullName, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(hintText: ref.watch(appL10nProvider).yourNameHint),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(ref.watch(appL10nProvider).save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    final current = ref.read(userProfileProvider).valueOrNull;
    if (current == null) return;
    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
        UserProfile(
          name: name,
          email: current.email,
          status: current.status,
          xp: current.xp,
          topicsCompleted: current.topicsCompleted,
          assessedLevel: current.assessedLevel,
          preferences: current.preferences,
          lastAssessmentDate: current.lastAssessmentDate,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appL10nProvider).nameChanged)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ref.read(appL10nProvider).failedToUpdateName}: $e')),
      );
    }
  }
}

// ── Password edit sheet ────────────────────────────────────────
class _PasswordEditSheet extends ConsumerStatefulWidget {
  const _PasswordEditSheet();

  @override
  ConsumerState<_PasswordEditSheet> createState() => _PasswordEditSheetState();
}

class _PasswordEditSheetState extends ConsumerState<_PasswordEditSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
            Text(ref.watch(appL10nProvider).changePassword, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            _PasswordField(
              label: ref.watch(appL10nProvider).currentPasswordLabel,
              controller: _currentCtrl,
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: ref.watch(appL10nProvider).newPasswordLabel,
              controller: _newCtrl,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: ref.watch(appL10nProvider).confirmNewPasswordLabel,
              controller: _confirmCtrl,
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(ref.watch(appL10nProvider).save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (current.isEmpty || newPass.isEmpty) return;
    if (newPass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appL10nProvider).passwordsDoNotMatch)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(userProfileProvider.notifier).changePassword(current, newPass);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appL10nProvider).passwordChanged)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ref.read(appL10nProvider).failedToChangePassword}: $e')),
      );
    }
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.muted,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
