import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:vesteraalen_timelapse/core/config/env_config.dart';
import 'package:vesteraalen_timelapse/core/theme/app_theme.dart';
import 'package:vesteraalen_timelapse/core/providers/shared_preferences_provider.dart';
import 'package:vesteraalen_timelapse/core/providers/theme_provider.dart';
import 'package:vesteraalen_timelapse/core/providers/locale_provider.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';
import 'package:vesteraalen_timelapse/features/cameras/pages/cameras_list_page.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/cameras_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for all supported locales
  await initializeDateFormatting();

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

class VesteraalenTimelapseApp extends ConsumerStatefulWidget {
  const VesteraalenTimelapseApp({super.key});

  @override
  ConsumerState<VesteraalenTimelapseApp> createState() =>
      _VesteraalenTimelapseAppState();
}

class _VesteraalenTimelapseAppState
    extends ConsumerState<VesteraalenTimelapseApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camerasNotifier = ref.read(camerasProvider.notifier);

    if (state == AppLifecycleState.resumed) {
      // App came to foreground - resume polling and reconnect WebSocket if needed
      camerasNotifier.resumePolling();
      // Also do a silent refresh to catch any missed updates
      camerasNotifier.loadCameras(silent: true, forceRefresh: true);
    } else if (state == AppLifecycleState.paused) {
      // App went to background - stop polling (WebSocket stays connected)
      camerasNotifier.stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Vesterålen',
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
