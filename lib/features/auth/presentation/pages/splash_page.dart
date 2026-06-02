import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_startup_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrapAndNavigate);
  }

  Future<void> _bootstrapAndNavigate() async {
    final isRetry = _hasError;
    if (isRetry) {
      setState(() => _hasError = false);
      // Force fresh recomputation — without this, re-reading returns the
      // cached failed future and the retry immediately fails again.
      ref.invalidate(appStartupProvider);
      ref.invalidate(authNotifierProvider);
    }

    // Start both in parallel: auth uses only secure storage, not Hive.
    final startupFuture = ref.read(appStartupProvider.future);
    final authFuture = ref.read(authNotifierProvider.future);

    try {
      await startupFuture;
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
      return;
    }
    if (!mounted) return;

    // Auth failure is a different failure mode (network, bad token) — route to
    // login rather than showing the storage crash screen.
    final AuthState authState;
    try {
      authState = await authFuture;
    } catch (_) {
      if (!mounted) return;
      context.go('/login');
      return;
    }
    if (!mounted) return;

    if (!authState.isAuthenticated) {
      context.go('/login');
      return;
    }

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
    if (_hasError) {
      return _SplashError(onRetry: _bootstrapAndNavigate);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Text(
            'AFINE',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              fontSize: 44,
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashError extends StatelessWidget {
  final VoidCallback onRetry;
  const _SplashError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('😕', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Could not start the app',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Storage initialisation failed.\nTry again or restart the app.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
