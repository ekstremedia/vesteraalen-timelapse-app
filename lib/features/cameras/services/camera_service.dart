import 'package:dio/dio.dart';
import 'package:vesteraalen_timelapse/core/config/env_config.dart';
import 'package:vesteraalen_timelapse/core/constants/app_constants.dart';
import 'package:vesteraalen_timelapse/core/services/api_client.dart';
import 'package:vesteraalen_timelapse/core/services/cache_service.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/timelapse_video.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';

/// Service for fetching camera and timelapse data from the API.
///
/// Provides methods to fetch cameras, timelapse videos, and available dates
/// with built-in caching to reduce API calls and improve performance.
///
/// Cache durations:
/// - Cameras list: 30 seconds (images update frequently)
/// - Today's timelapse: 30 seconds (may still be processing)
/// - Historical timelapse: 5 minutes (won't change)
/// - Available dates: 1 hour (changes once daily)
class CameraService {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  CameraService(this._apiClient, this._cacheService);

  /// Fetches all active cameras with current images and latest video info.
  ///
  /// Returns a list of [Camera] objects from the API or cache.
  /// Set [forceRefresh] to true to bypass the cache and fetch fresh data.
  ///
  /// Throws [ApiException] if the API request fails.
  Future<List<Camera>> getCameras({bool forceRefresh = false}) async {
    final cacheDuration = Duration(seconds: EnvConfig.cacheCamerasTtl);

    if (!forceRefresh) {
      final cached = _cacheService.get<List<dynamic>>(CacheKeys.camerasList);
      if (cached != null) {
        return cached
            .map((json) => Camera.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.cameras);
      final data = response.data;

      // Validate response format
      if (data is! Map || data['cameras'] is! List) {
        throw ApiException(message: 'Invalid API response format');
      }

      final List<dynamic> cameras = data['cameras'] as List<dynamic>;
      _cacheService.set(CacheKeys.camerasList, cameras, cacheDuration);

      return cameras
          .map((json) => Camera.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Fetches timelapse detail for a specific camera and date.
  ///
  /// Returns a [TimelapseDetail] object with video URLs and image gallery.
  /// Recent dates (today/yesterday) use shorter cache TTL since they may
  /// still be processing.
  ///
  /// Set [forceRefresh] to true to bypass the cache.
  /// Throws [ApiException] if the API request fails.
  Future<TimelapseDetail> getTimelapse(
    String cameraId,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final dateStr = date.toApiFormat();
    final cacheKey = CacheKeys.timelapse(cameraId, dateStr);

    // Use shorter cache for recent dates that may still be updating
    final isRecent = _isRecentDate(date);
    final cacheDuration = Duration(
      seconds: isRecent
          ? EnvConfig.cacheTimelapseTodayTtl
          : EnvConfig.cacheTimelapseHistoricalTtl,
    );

    if (!forceRefresh) {
      final cached = _cacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return TimelapseDetail.fromJson(cached);
      }
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.timelapse(cameraId, dateStr),
      );
      final data = response.data;

      // Validate response format
      if (data is! Map<String, dynamic>) {
        throw ApiException(message: 'Invalid API response format');
      }

      _cacheService.set(cacheKey, data, cacheDuration);
      return TimelapseDetail.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Fetches available timelapse dates for a camera.
  ///
  /// Returns a list of [DateTime] objects representing dates with timelapse
  /// videos. Cached for 1 hour since new dates are only added once per day.
  ///
  /// Set [forceRefresh] to true to bypass the cache.
  /// Throws [ApiException] if the API request fails.
  Future<List<DateTime>> getAvailableDates(
    String cameraId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheKeys.availableDates(cameraId);
    final cacheDuration = Duration(seconds: EnvConfig.cacheAvailableDatesTtl);

    if (!forceRefresh) {
      final cached = _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((s) => DateTime.parse(s as String)).toList();
      }
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.availableDates(cameraId),
      );
      final data = response.data;

      // Validate response format
      if (data is! Map || data['dates'] is! List) {
        throw ApiException(message: 'Invalid API response format');
      }

      final List<dynamic> dates = data['dates'] as List<dynamic>;
      _cacheService.set(cacheKey, dates, cacheDuration);

      return dates.map((s) => DateTime.parse(s as String)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Invalidates the cached cameras list, forcing a fresh fetch on next call.
  void invalidateCameras() {
    _cacheService.invalidate(CacheKeys.camerasList);
  }

  /// Invalidates cached timelapse for a specific camera and date.
  void invalidateTimelapse(String cameraId, DateTime date) {
    final dateStr = date.toApiFormat();
    _cacheService.invalidate(CacheKeys.timelapse(cameraId, dateStr));
  }

  /// Invalidates cached available dates for a camera.
  void invalidateAvailableDates(String cameraId) {
    _cacheService.invalidate(CacheKeys.availableDates(cameraId));
  }

  /// Invalidates all cached data for a specific camera.
  void invalidateCamera(String cameraId) {
    _cacheService.invalidatePattern(cameraId);
    _cacheService.invalidate(CacheKeys.camerasList);
  }

  /// Clears all cached data.
  void clearCache() {
    _cacheService.clear();
  }

  /// Checks if a date is recent (today or yesterday).
  ///
  /// Recent dates use shorter cache TTL since timelapse videos
  /// may still be processing.
  bool _isRecentDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    return dateOnly == today || dateOnly == yesterday;
  }
}
