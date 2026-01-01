import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vesteraalen_timelapse/core/providers/shared_preferences_provider.dart';
import 'package:vesteraalen_timelapse/core/theme/app_theme.dart';

void main() {
  testWidgets('App smoke test - renders without errors', (
    WidgetTester tester,
  ) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build a minimal app for testing
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Scaffold(body: Center(child: Text('Test App'))),
        ),
      ),
    );

    // Verify the app renders
    expect(find.text('Test App'), findsOneWidget);
  });

  test('AppTheme - dark theme has correct properties', () {
    expect(AppTheme.primaryColor, const Color(0xFF4DB6AC));
    expect(AppTheme.darkTheme.brightness, Brightness.dark);
    expect(AppTheme.lightTheme.brightness, Brightness.light);
  });

  test('AppTheme - primary colors match', () {
    expect(AppTheme.primaryDark, const Color(0xFF009688));
    expect(AppTheme.surfaceDark, const Color(0xFF0F1419));
  });
}
