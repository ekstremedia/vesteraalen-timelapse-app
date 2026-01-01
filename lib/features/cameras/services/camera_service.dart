import 'package:dio/dio.dart';
import 'package:vesteraalen_timelapse/core/config/env_config.dart';
import 'package:vesteraalen_timelapse/core/services/api_client.dart';
import 'package:vesteraalen_timelapse/core/services/cache_service.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/timelapse_video.dart';

/// Service for fetching camera and timelapse data from the API.
/// Includes caching to prevent excessive API calls.
class CameraService {
  final ApiClient _apiClient;
  final CacheService _cacheService;

  CameraService(this._apiClient, this._cacheService);

  /// Fetch all active cameras with current images and latest video info.
  /// Cached for 30 seconds by default.
  Future<List<Camera>> getCameras({bool forceRefresh = false}) async {
    const cacheKey = 'cameras_list';
    final cacheDuration = Duration(seconds: EnvConfig.cacheCamerasTtl);

    if (!forceRefresh) {
      final cached = _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached
            .map((json) => Camera.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      final response = await _apiClient.get('/api/app/cameras');
      final List<dynamic> data = response.data['cameras'] as List<dynamic>;

      _cacheService.set(cacheKey, data, cacheDuration);

      return data
          .map((json) => Camera.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Fetch timelapse detail for a specific camera and date.
  /// Cached for 30 seconds for today/yesterday, 5 minutes for historical dates.
  Future<TimelapseDetail> getTimelapse(
    String cameraId,
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final dateStr = _formatDate(date);
    final cacheKey = 'timelapse_${cameraId}_$dateStr';

    // Use shorter cache for recent dates
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
        '/api/app/timelapse/$cameraId/$dateStr',
      );
      final data = response.data as Map<String, dynamic>;

      _cacheService.set(cacheKey, data, cacheDuration);

      return TimelapseDetail.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Fetch available timelapse dates for a camera.
  /// Cached for 1 hour since new dates are only added once per day.
  Future<List<DateTime>> getAvailableDates(
    String cameraId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'available_dates_$cameraId';
    final cacheDuration = Duration(seconds: EnvConfig.cacheAvailableDatesTtl);

    if (!forceRefresh) {
      final cached = _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((s) => DateTime.parse(s as String)).toList();
      }
    }

    try {
      final response = await _apiClient.get(
        '/api/app/timelapse/$cameraId/dates',
      );
      final List<dynamic> dates = response.data['dates'] as List<dynamic>;

      _cacheService.set(cacheKey, dates, cacheDuration);

      return dates.map((s) => DateTime.parse(s as String)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Invalidate cached cameras list.
  void invalidateCameras() {
    _cacheService.invalidate('cameras_list');
  }

  /// Invalidate cached timelapse for a specific camera and date.
  void invalidateTimelapse(String cameraId, DateTime date) {
    final dateStr = _formatDate(date);
    _cacheService.invalidate('timelapse_${cameraId}_$dateStr');
  }

  /// Invalidate cached available dates for a camera.
  void invalidateAvailableDates(String cameraId) {
    _cacheService.invalidate('available_dates_$cameraId');
  }

  /// Invalidate all cached data for a camera.
  void invalidateCamera(String cameraId) {
    _cacheService.invalidatePattern(cameraId);
    _cacheService.invalidate('cameras_list');
  }

  /// Clear all cached data.
  void clearCache() {
    _cacheService.clear();
  }

  /// Format date for API requests.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if date is today or yesterday (recent).
  bool _isRecentDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    return dateOnly == today || dateOnly == yesterday;
  }
}
