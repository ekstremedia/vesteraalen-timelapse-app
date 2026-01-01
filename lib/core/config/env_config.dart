import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file.
class EnvConfig {
  static bool _initialized = false;

  /// Initialize environment configuration.
  /// Call this before runApp().
  static Future<void> load() async {
    if (_initialized) return;

    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
    } catch (e) {
      // Fallback to .env.example if .env doesn't exist (CI/CD builds)
      try {
        await dotenv.load(fileName: '.env.example');
        _initialized = true;
      } catch (e) {
        // Use default values if no env file exists
        _initialized = true;
      }
    }
  }

  /// API base URL for the backend.
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://ekstremedia.no';

  /// Cache TTL for cameras list in seconds.
  static int get cacheCamerasTtl =>
      int.tryParse(dotenv.env['CACHE_CAMERAS_TTL'] ?? '') ?? 30;

  /// Cache TTL for today's timelapse in seconds.
  static int get cacheTimelapseTodayTtl =>
      int.tryParse(dotenv.env['CACHE_TIMELAPSE_TODAY_TTL'] ?? '') ?? 30;

  /// Cache TTL for historical timelapse in seconds.
  static int get cacheTimelapseHistoricalTtl =>
      int.tryParse(dotenv.env['CACHE_TIMELAPSE_HISTORICAL_TTL'] ?? '') ?? 300;

  /// Cache TTL for available dates in seconds.
  static int get cacheAvailableDatesTtl =>
      int.tryParse(dotenv.env['CACHE_AVAILABLE_DATES_TTL'] ?? '') ?? 3600;

  /// Polling interval for camera updates in seconds.
  static int get pollingInterval =>
      int.tryParse(dotenv.env['POLLING_INTERVAL'] ?? '') ?? 60;
}
