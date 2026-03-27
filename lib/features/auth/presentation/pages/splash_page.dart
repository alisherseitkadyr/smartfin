import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_providers.dart';
import 'login_page.dart';

/// Shown on app launch. Checks auth state, then routes accordingly.
/// Replace the Navigator calls with your go_router/auto_route redirect
/// once you have a router set up.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (_, next) {
      next.whenData((authState) {
        if (!context.mounted) return;
        if (authState.isAuthenticated) {
          // Navigate to home — swap with router redirect
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      });
    });

    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.green),
      ),
    );
  }
}