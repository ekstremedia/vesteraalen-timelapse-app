import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/core/providers/shared_preferences_provider.dart';

/// Provider for the current theme mode.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Notifier for managing theme mode state.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getString(_key);

    // Default to dark mode for new users (matches website aesthetic)
    if (value == null) return ThemeMode.dark;

    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.dark,
    );
  }

  /// Set the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = mode;
    await prefs.setString(_key, mode.name);
  }

  /// Toggle between light and dark themes.
  /// If currently system, switches to dark.
  Future<void> toggle() async {
    final newMode = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
    await setThemeMode(newMode);
  }
}
