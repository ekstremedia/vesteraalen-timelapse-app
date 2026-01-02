import 'package:flutter/material.dart';

/// Application-wide spacing constants for consistent padding and margins.
///
/// Usage: `padding: EdgeInsets.all(AppSpacing.md)`
abstract class AppSpacing {
  /// Extra small spacing (4.0)
  static const double xs = 4.0;

  /// Small spacing (8.0)
  static const double sm = 8.0;

  /// Medium spacing (12.0)
  static const double md = 12.0;

  /// Large spacing (16.0)
  static const double lg = 16.0;

  /// Extra large spacing (24.0)
  static const double xl = 24.0;

  /// Extra extra large spacing (32.0)
  static const double xxl = 32.0;
}

/// Application-wide dimension constants for sizes, breakpoints, and ratios.
abstract class AppDimensions {
  /// Standard video aspect ratio (16:9)
  static const double videoAspectRatio = 16 / 9;

  /// Icon sizes
  static const double iconSm = 14.0;
  static const double iconMd = 18.0;
  static const double iconLg = 20.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  /// Breakpoints for responsive grid layouts
  static const double breakpointXl = 1200.0;
  static const double breakpointLg = 900.0;
  static const double breakpointMd = 600.0;

  /// Image cache width for memory optimization
  static const int imageCacheWidth = 800;

  /// Border radius values
  static const double radiusSm = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;

  /// Status indicator size (connection dots, etc.)
  static const double statusIndicatorSize = 12.0;

  /// Returns the number of grid columns based on screen width.
  static int getGridColumns(double width) {
    if (width >= breakpointXl) return 4;
    if (width >= breakpointLg) return 3;
    if (width >= breakpointMd) return 2;
    return 1;
  }
}

/// API endpoint paths for the backend.
///
/// All endpoints are relative to the base URL configured in [EnvConfig].
abstract class ApiEndpoints {
  /// Get list of all cameras with current images
  static const String cameras = '/api/app/cameras';

  /// Get timelapse for a specific camera and date.
  /// Usage: `ApiEndpoints.timelapse(cameraId, date)`
  static String timelapse(String cameraId, String date) =>
      '/api/app/timelapse/$cameraId/$date';

  /// Get available dates for a camera's timelapse videos.
  /// Usage: `ApiEndpoints.availableDates(cameraId)`
  static String availableDates(String cameraId) =>
      '/api/app/timelapse/$cameraId/dates';
}

/// Cache key patterns for the in-memory cache service.
///
/// Provides consistent cache key naming across the application.
abstract class CacheKeys {
  /// Key for the cameras list cache
  static const String camerasList = 'cameras_list';

  /// Key pattern for timelapse data.
  /// Usage: `CacheKeys.timelapse(cameraId, date)`
  static String timelapse(String cameraId, String date) =>
      'timelapse_${cameraId}_$date';

  /// Key pattern for available dates.
  /// Usage: `CacheKeys.availableDates(cameraId)`
  static String availableDates(String cameraId) => 'available_dates_$cameraId';
}

/// Duration constants for timeouts, animations, and intervals.
abstract class AppDurations {
  /// API connection timeout
  static const Duration apiConnectTimeout = Duration(seconds: 10);

  /// API receive timeout
  static const Duration apiReceiveTimeout = Duration(seconds: 30);

  /// WebSocket ping interval
  static const Duration webSocketPingInterval = Duration(seconds: 30);

  /// WebSocket reconnect delay
  static const Duration webSocketReconnectDelay = Duration(seconds: 5);

  /// Maximum WebSocket reconnect attempts
  static const int webSocketMaxReconnectAttempts = 5;

  /// Image update flash animation duration
  static const Duration imageFlashAnimation = Duration(milliseconds: 800);

  /// Cache TTL for cameras list (updates frequently)
  static const Duration cacheCamerasList = Duration(seconds: 30);

  /// Cache TTL for today's timelapse (may still be processing)
  static const Duration cacheTodayTimelapse = Duration(seconds: 30);

  /// Cache TTL for historical timelapse (won't change)
  static const Duration cacheHistoricalTimelapse = Duration(minutes: 5);

  /// Cache TTL for available dates (changes once daily)
  static const Duration cacheAvailableDates = Duration(hours: 1);
}

/// Status indicator colors used throughout the app.
abstract class AppStatusColors {
  /// Connected/online status
  static const Color connected = Colors.green;

  /// Disconnected/offline status
  static const Color disconnected = Colors.red;

  /// Connecting/loading status
  static const Color connecting = Colors.orange;

  /// Disabled/inactive status
  static const Color disabled = Colors.grey;
}
