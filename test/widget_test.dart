import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afine/core/providers/theme_provider.dart';
import 'package:afine/main.dart';

class _TestThemeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async => ThemeMode.light;
}

void main() {
  testWidgets('AFinApp builds the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeNotifierProvider.overrideWith(_TestThemeNotifier.new)],
        child: const AFinApp(),
      ),
    );

    await tester.pump();

    expect(find.text('AFINE'), findsOneWidget);
  });
}
