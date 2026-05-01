import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/safe_storage.dart';

final themeNotifierProvider = AsyncNotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  static const _kThemeKey = 'app_theme_mode';
  SafeStorage get _storage => const SafeStorage();

  @override
  Future<ThemeMode> build() async {
    final raw = await _storage.read(key: _kThemeKey);
    if (raw == 'dark') return ThemeMode.dark;
    if (raw == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? ThemeMode.system;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setMode(next);
  }

  Future<void> setMode(ThemeMode next) async {
    await _storage.write(
      key: _kThemeKey,
      value: next == ThemeMode.dark ? 'dark' : 'light',
    );
    state = AsyncData(next);
  }

  bool get isDark => state.valueOrNull == ThemeMode.dark;
}
