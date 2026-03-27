import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).loginWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  Future<void> _onGoogleLogin() async {
    await ref.read(authNotifierProvider.notifier).loginWithGoogle();
  }

  void _goToRegister() {
    context.push('/register');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final errorMsg = authState.error?.toString();

    // Listen for successful auth → navigate away
    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((state) {
        if (state.isAuthenticated && context.mounted) {
          context.go('/home');
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),

                // ── Header ───────────────────────────────────
                Text(
                  'Welcome back 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue your learning journey.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),

                const SizedBox(height: 40),

                // ── Google button ────────────────────────────
                GoogleSignInButton(

                  onTap: isLoading ? null : _onGoogleLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),
                const AuthDivider(),
                const SizedBox(height: 24),

                // ── Email field ──────────────────────────────
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

                // ── Password field ───────────────────────────
                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your password';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // ── Error message ────────────────────────────
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

                // ── Submit button ────────────────────────────
                AuthPrimaryButton(
                  label: 'Sign In',
                  onTap: isLoading ? null : _onEmailLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // ── Register link ────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _goToRegister,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign up',
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