import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:vesteraalen_timelapse/core/config/env_config.dart';
import 'package:vesteraalen_timelapse/core/theme/app_theme.dart';
import 'package:vesteraalen_timelapse/core/providers/shared_preferences_provider.dart';
import 'package:vesteraalen_timelapse/core/providers/theme_provider.dart';
import 'package:vesteraalen_timelapse/core/providers/locale_provider.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';
import 'package:vesteraalen_timelapse/features/cameras/pages/cameras_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration
  await EnvConfig.load();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const VesteraalenTimelapseApp(),
    ),
  );
}

class VesteraalenTimelapseApp extends ConsumerWidget {
  const VesteraalenTimelapseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Vesteraalen Timelapse',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        NorwegianMaterialLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current locale is supported
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // Default to Norwegian Bokmål
        return const Locale('nb');
      },

      // Home page
      home: const CamerasListPage(),
    );
  }
}
