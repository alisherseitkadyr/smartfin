import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  unawaited(NotificationService.instance.init());

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    // ProviderScope wraps the entire app — Riverpod DI container
    const ProviderScope(child: AFinApp()),
  );
}

class AFinApp extends ConsumerWidget {
  const AFinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      final wasAuthenticated = prev?.valueOrNull?.isAuthenticated == true;
      final isNowUnauthenticated = next.valueOrNull?.isAuthenticated == false;
      if (wasAuthenticated && isNowUnauthenticated) {
        appRouter.go(Routes.login);
      }
    });

    return MaterialApp.router(
      title: 'AFine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode.valueOrNull ?? ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
