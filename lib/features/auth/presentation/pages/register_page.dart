import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).registerWithEmail(
          _nameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  Future<void> _onGoogleRegister() async {
    await ref.read(authNotifierProvider.notifier).loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final errorMsg = authState.error?.toString();

    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((state) {
        if (state.isAuthenticated && context.mounted) {
          context.go('/home');
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.text,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Header ───────────────────────────────────
                Text(
                  'Create account 🌱',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey to financial freedom.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),

                const SizedBox(height: 32),

                // ── Google button ────────────────────────────
                GoogleSignInButton(
                  onTap: isLoading ? null : _onGoogleRegister,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),
                const AuthDivider(),
                const SizedBox(height: 24),

                // ── Name ─────────────────────────────────────
                AuthTextField(
                  label: 'Full name',
                  hint: 'Alex Johnson',
                  controller: _nameCtrl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Email ─────────────────────────────────────
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Password ──────────────────────────────────
                AuthTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  controller: _passwordCtrl,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 8) return 'At least 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ── Confirm password ──────────────────────────
                AuthTextField(
                  label: 'Confirm password',
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // ── Error ─────────────────────────────────────
                if (errorMsg != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      errorMsg,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: const Color(0xFFDC2626)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Submit ────────────────────────────────────
                AuthPrimaryButton(
                  label: 'Create Account',
                  onTap: isLoading ? null : _onRegister,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // ── Login link ────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              color: AppColors.greenDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}