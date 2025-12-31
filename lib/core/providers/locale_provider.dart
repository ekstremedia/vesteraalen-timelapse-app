import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/core/providers/shared_preferences_provider.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

/// Provider for the current locale.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Notifier for managing locale state.
class LocaleNotifier extends Notifier<Locale> {
  static const _key = 'locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedLocale = prefs.getString(_key);

    if (savedLocale != null) {
      return Locale(savedLocale);
    }

    // Get system locale and check if it's supported
    final systemLocale = PlatformDispatcher.instance.locale;
    final isSupported = AppLocalizations.supportedLocales.any(
      (loc) => loc.languageCode == systemLocale.languageCode,
    );

    // Default to Norwegian Bokmål if system locale isn't supported
    return isSupported ? Locale(systemLocale.languageCode) : const Locale('nb');
  }

  /// Set the locale.
  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = locale;
    await prefs.setString(_key, locale.languageCode);
  }

  /// Get the display name for a locale.
  String getLocaleName(Locale locale, AppLocalizations l10n) {
    return switch (locale.languageCode) {
      'nb' => l10n.languageNorwegianBokmal,
      'nn' => l10n.languageNorwegianNynorsk,
      'en' => l10n.languageEnglish,
      _ => locale.languageCode,
    };
  }
}

/// Helper class for locale-related utilities.
class LocaleUtils {
  /// Get the locale string for intl package.
  /// Nynorsk falls back to Bokmål for date formatting since intl doesn't support nn.
  static String getIntlLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return switch (locale.languageCode) {
      'nn' => 'nb', // Nynorsk falls back to Bokmål for intl
      _ => locale.languageCode,
    };
  }
}
