import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final authState = await ref.read(authNotifierProvider.future);
    if (!mounted) return;

    if (!authState.isAuthenticated) {
      context.go('/login');
      return;
    }

    try {
      final isComplete =
          await ref.read(onboardingStatusProvider.future);
      if (!mounted) return;
      context.go(isComplete ? '/home' : '/onboarding');
    } catch (_) {
      // If the profile check fails (e.g. network error), fall back to onboarding
      // so the user can complete setup rather than landing in a broken home state.
      if (!mounted) return;
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AFINE',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  fontSize: 44
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
