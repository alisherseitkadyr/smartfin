import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/platform_google_sign_in_button.dart';

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

  Future<void> _navigateAfterLogin() async {
    try {
      final isComplete = await ref.read(onboardingStatusProvider.future);
      if (!mounted) return;
      context.go(isComplete ? '/home' : '/onboarding');
    } catch (_) {
      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final errorMsg = authState.error?.toString();

    // After successful login, check whether onboarding is complete before routing.
    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((state) {
        if (state.isAuthenticated && context.mounted) {
          _navigateAfterLogin();
        }
      });
    });

    final l10n = ref.watch(appL10nProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),

                Text(
                  l10n.welcomeBack,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInSubtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),

                const SizedBox(height: 40),

                PlatformGoogleSignInButton(
                  onTap: isLoading ? null : _onGoogleLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),
                const AuthDivider(),
                const SizedBox(height: 24),

                AuthTextField(
                  label: l10n.email,
                  hint: l10n.emailHint,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.enterEmail;
                    if (!v.contains('@')) return l10n.enterValidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                AuthTextField(
                  label: l10n.password,
                  hint: l10n.passwordHint,
                  controller: _passwordCtrl,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.enterPassword;
                    return null;
                  },
                ),

                const SizedBox(height: 28),

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

                AuthPrimaryButton(
                  label: l10n.signInButton,
                  onTap: isLoading ? null : _onEmailLogin,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: _goToRegister,
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(text: l10n.noAccount),
                          TextSpan(
                            text: l10n.signUpLink,
                            style: const TextStyle(
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
