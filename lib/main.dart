import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/learning_session.dart';
import 'core/storage/learning_session_storage.dart';
import 'core/storage/subtopic_progress_storage.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(LearningSessionAdapter().typeId)) {
    Hive.registerAdapter(LearningSessionAdapter());
  }

  await Hive.openBox<LearningSession>(LearningSessionStorage.boxName);
  await Hive.openBox(SubtopicProgressStorage.boxName);
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

    return themeMode.when(
      data: (mode) {
        return MaterialApp.router(
          title: 'AFine',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: appRouter,
        );
      },
      loading: () => const _LoadingApp(),
      error: (_, __) {
        return MaterialApp.router(
          title: 'AFine',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig: appRouter,
        );
      },
    );
  }
}

class _LoadingApp extends StatelessWidget {
  const _LoadingApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
