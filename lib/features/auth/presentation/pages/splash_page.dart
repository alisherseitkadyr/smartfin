import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_startup_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrapAndNavigate);
  }

  Future<void> _bootstrapAndNavigate() async {
    final startupFuture = ref.read(appStartupProvider.future);
    final authFuture = ref.read(authNotifierProvider.future);

    await startupFuture;
    if (!mounted) return;

    final authState = await authFuture;
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
