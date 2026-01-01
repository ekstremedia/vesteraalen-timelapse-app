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
    expect(AppTheme.primaryColor, const Color(0xFF9D4EDD));
    expect(AppTheme.darkTheme.brightness, Brightness.dark);
    expect(AppTheme.lightTheme.brightness, Brightness.light);
  });

  test('AppTheme - primary colors match', () {
    expect(AppTheme.primaryDark, const Color(0xFF7B2CBF));
    expect(AppTheme.surfaceDark, const Color(0xFF0D0D1A));
  });

  test('AppTheme - accent colors are defined', () {
    expect(AppTheme.accentGreen, const Color(0xFF22C55E));
    expect(AppTheme.accentPurple, const Color(0xFF8B5CF6));
    expect(AppTheme.primaryLight, const Color(0xFFB76EF0));
  });

  test('AppTheme - dark theme surface colors', () {
    expect(AppTheme.surfaceContainerDark, const Color(0xFF1A1A2E));
    expect(AppTheme.surfaceContainerHighDark, const Color(0xFF252547));
  });

  test('AppTheme - dark theme text colors', () {
    expect(AppTheme.onSurfaceDark, const Color(0xFFFFFFFF));
    expect(AppTheme.onSurfaceVariantDark, const Color(0xFFB8B8D0));
  });

  test('AppTheme - light theme colors are defined', () {
    expect(AppTheme.surfaceLight, const Color(0xFFF8F9FA));
    expect(AppTheme.surfaceContainerLight, const Color(0xFFFFFFFF));
    expect(AppTheme.onSurfaceLight, const Color(0xFF1F2937));
  });

  test('AppTheme - dark theme uses Material 3', () {
    expect(AppTheme.darkTheme.useMaterial3, isTrue);
  });

  test('AppTheme - light theme uses Material 3', () {
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
  });
}
