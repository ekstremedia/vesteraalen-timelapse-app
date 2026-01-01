import 'package:flutter/material.dart';

/// Localization support for Norwegian Bokmål (nb), Nynorsk (nn), and English (en).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('nb'), // Norwegian Bokmål
    Locale('nn'), // Norwegian Nynorsk
    Locale('en'), // English
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'appTitle': 'Vesterålen Timelapse',
      'appSubtitle': 'Live cameras from Northern Norway',

      // Navigation
      'cameras': 'Cameras',
      'settings': 'Settings',

      // Cameras
      'cameraNotFound': 'Camera not found',
      'currentImage': 'Current Image',
      'updatedAgo': 'Updated {time} ago',
      'justNow': 'just now',
      'minutesAgo': '{count} min ago',
      'hoursAgo': '{count} h ago',
      'noImage': 'No image available',
      'noCameras': 'No cameras available',
      'loadingCameras': 'Loading cameras...',
      'videoCount': '{count} videos',
      'videoCountOne': '1 video',

      // Timelapse
      'timelapse': 'Timelapse',
      'noTimelapseAvailable': 'No timelapse available for this date',
      'showingYesterdaysTimelapse':
          "Today's timelapse is still being created. Showing yesterday's timelapse.",
      'dailyImages': 'Daily Images',
      'daytime': 'Daytime',
      'evening': 'Evening',
      'keogram': 'Keogram',
      'watchOnYoutube': 'Watch on YouTube',

      // Date navigation
      'today': 'Today',
      'yesterday': 'Yesterday',
      'goToToday': 'Go to today',
      'previousDay': 'Previous day',
      'nextDay': 'Next day',
      'selectDate': 'Select date',

      // Settings
      'appearance': 'Appearance',
      'theme': 'Theme',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'language': 'Language',
      'languageEnglish': 'English',
      'languageNorwegianBokmal': 'Norwegian (Bokmål)',
      'languageNorwegianNynorsk': 'Norwegian (Nynorsk)',
      'about': 'About',
      'version': 'Version',
      'website': 'Visit Website',

      // General
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'cancel': 'Cancel',
      'ok': 'OK',
      'close': 'Close',
      'noInternetConnection': 'No internet connection',
      'somethingWentWrong': 'Something went wrong',
    },
    'nb': {
      // App
      'appTitle': 'Vesterålen Timelapse',
      'appSubtitle': 'Direktekameraer fra Nord-Norge',

      // Navigation
      'cameras': 'Kameraer',
      'settings': 'Innstillinger',

      // Cameras
      'cameraNotFound': 'Kamera ikke funnet',
      'currentImage': 'Nåværende bilde',
      'updatedAgo': 'Oppdatert for {time} siden',
      'justNow': 'akkurat nå',
      'minutesAgo': '{count} min siden',
      'hoursAgo': '{count} t siden',
      'noImage': 'Ingen bilde tilgjengelig',
      'noCameras': 'Ingen kameraer tilgjengelig',
      'loadingCameras': 'Laster kameraer...',
      'videoCount': '{count} videoer',
      'videoCountOne': '1 video',

      // Timelapse
      'timelapse': 'Timelapse',
      'noTimelapseAvailable': 'Ingen timelapse tilgjengelig for denne datoen',
      'showingYesterdaysTimelapse':
          'Dagens timelapse lages fortsatt. Viser gårsdagens timelapse.',
      'dailyImages': 'Daglige bilder',
      'daytime': 'Dag',
      'evening': 'Kveld',
      'keogram': 'Keogram',
      'watchOnYoutube': 'Se på YouTube',

      // Date navigation
      'today': 'I dag',
      'yesterday': 'I går',
      'goToToday': 'Gå til i dag',
      'previousDay': 'Forrige dag',
      'nextDay': 'Neste dag',
      'selectDate': 'Velg dato',

      // Settings
      'appearance': 'Utseende',
      'theme': 'Tema',
      'themeLight': 'Lyst',
      'themeDark': 'Mørkt',
      'themeSystem': 'System',
      'language': 'Språk',
      'languageEnglish': 'Engelsk',
      'languageNorwegianBokmal': 'Norsk (Bokmål)',
      'languageNorwegianNynorsk': 'Norsk (Nynorsk)',
      'about': 'Om',
      'version': 'Versjon',
      'website': 'Besøk nettside',

      // General
      'loading': 'Laster...',
      'error': 'Feil',
      'retry': 'Prøv igjen',
      'refresh': 'Oppdater',
      'cancel': 'Avbryt',
      'ok': 'OK',
      'close': 'Lukk',
      'noInternetConnection': 'Ingen internettforbindelse',
      'somethingWentWrong': 'Noe gikk galt',
    },
    'nn': {
      // App
      'appTitle': 'Vesterålen Timelapse',
      'appSubtitle': 'Direktekamera frå Nord-Noreg',

      // Navigation
      'cameras': 'Kamera',
      'settings': 'Innstillingar',

      // Cameras
      'cameraNotFound': 'Kamera ikkje funne',
      'currentImage': 'Noverande bilete',
      'updatedAgo': 'Oppdatert for {time} sidan',
      'justNow': 'akkurat no',
      'minutesAgo': '{count} min sidan',
      'hoursAgo': '{count} t sidan',
      'noImage': 'Ingen bilete tilgjengeleg',
      'noCameras': 'Ingen kamera tilgjengelege',
      'loadingCameras': 'Lastar kamera...',
      'videoCount': '{count} videoar',
      'videoCountOne': '1 video',

      // Timelapse
      'timelapse': 'Timelapse',
      'noTimelapseAvailable': 'Ingen timelapse tilgjengeleg for denne datoen',
      'showingYesterdaysTimelapse':
          'Dagens timelapse vert laga. Viser gårsdagens timelapse.',
      'dailyImages': 'Daglege bilete',
      'daytime': 'Dag',
      'evening': 'Kveld',
      'keogram': 'Keogram',
      'watchOnYoutube': 'Sjå på YouTube',

      // Date navigation
      'today': 'I dag',
      'yesterday': 'I går',
      'goToToday': 'Gå til i dag',
      'previousDay': 'Førre dag',
      'nextDay': 'Neste dag',
      'selectDate': 'Vel dato',

      // Settings
      'appearance': 'Utsjånad',
      'theme': 'Tema',
      'themeLight': 'Lyst',
      'themeDark': 'Mørkt',
      'themeSystem': 'System',
      'language': 'Språk',
      'languageEnglish': 'Engelsk',
      'languageNorwegianBokmal': 'Norsk (Bokmål)',
      'languageNorwegianNynorsk': 'Norsk (Nynorsk)',
      'about': 'Om',
      'version': 'Versjon',
      'website': 'Besøk nettside',

      // General
      'loading': 'Lastar...',
      'error': 'Feil',
      'retry': 'Prøv på nytt',
      'refresh': 'Oppdater',
      'cancel': 'Avbryt',
      'ok': 'OK',
      'close': 'Lukk',
      'noInternetConnection': 'Inga internettilkopling',
      'somethingWentWrong': 'Noko gjekk gale',
    },
  };

  String _get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // App
  String get appTitle => _get('appTitle');
  String get appSubtitle => _get('appSubtitle');

  // Navigation
  String get cameras => _get('cameras');
  String get settings => _get('settings');

  // Cameras
  String get cameraNotFound => _get('cameraNotFound');
  String get currentImage => _get('currentImage');
  String updatedAgo(String time) => _get('updatedAgo').replaceAll('{time}', time);
  String get justNow => _get('justNow');
  String minutesAgo(int count) =>
      _get('minutesAgo').replaceAll('{count}', count.toString());
  String hoursAgo(int count) =>
      _get('hoursAgo').replaceAll('{count}', count.toString());
  String get noImage => _get('noImage');
  String get noCameras => _get('noCameras');
  String get loadingCameras => _get('loadingCameras');
  String videoCount(int count) => count == 1
      ? _get('videoCountOne')
      : _get('videoCount').replaceAll('{count}', count.toString());

  // Timelapse
  String get timelapse => _get('timelapse');
  String get noTimelapseAvailable => _get('noTimelapseAvailable');
  String get showingYesterdaysTimelapse => _get('showingYesterdaysTimelapse');
  String get dailyImages => _get('dailyImages');
  String get daytime => _get('daytime');
  String get evening => _get('evening');
  String get keogram => _get('keogram');
  String get watchOnYoutube => _get('watchOnYoutube');

  // Date navigation
  String get today => _get('today');
  String get yesterday => _get('yesterday');
  String get goToToday => _get('goToToday');
  String get previousDay => _get('previousDay');
  String get nextDay => _get('nextDay');
  String get selectDate => _get('selectDate');

  // Settings
  String get appearance => _get('appearance');
  String get theme => _get('theme');
  String get themeLight => _get('themeLight');
  String get themeDark => _get('themeDark');
  String get themeSystem => _get('themeSystem');
  String get language => _get('language');
  String get languageEnglish => _get('languageEnglish');
  String get languageNorwegianBokmal => _get('languageNorwegianBokmal');
  String get languageNorwegianNynorsk => _get('languageNorwegianNynorsk');
  String get about => _get('about');
  String get version => _get('version');
  String get website => _get('website');

  // General
  String get loading => _get('loading');
  String get error => _get('error');
  String get retry => _get('retry');
  String get refresh => _get('refresh');
  String get cancel => _get('cancel');
  String get ok => _get('ok');
  String get close => _get('close');
  String get noInternetConnection => _get('noInternetConnection');
  String get somethingWentWrong => _get('somethingWentWrong');

  /// Format relative time (e.g., "5 min ago", "2 h ago", "just now")
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return justNow;
    } else if (difference.inHours < 1) {
      return minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return hoursAgo(difference.inHours);
    } else {
      return updatedAgo('${difference.inDays}d');
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'nb', 'nn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Custom Material localizations for Norwegian.
class NorwegianMaterialLocalizations extends DefaultMaterialLocalizations {
  const NorwegianMaterialLocalizations();

  @override
  String get cancelButtonLabel => 'Avbryt';

  @override
  String get closeButtonLabel => 'Lukk';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get saveButtonLabel => 'Lagre';
}

class NorwegianMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const NorwegianMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['nb', 'nn'].contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const NorwegianMaterialLocalizations();

  @override
  bool shouldReload(NorwegianMaterialLocalizationsDelegate old) => false;
}
