import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/core/config/env_config.dart';
import 'package:vesteraalen_timelapse/core/services/api_client.dart';
import 'package:vesteraalen_timelapse/core/services/cache_service.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/services/camera_service.dart';

/// Provider for the CacheService singleton.
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Provider for the ApiClient singleton.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for the CameraService.
final cameraServiceProvider = Provider<CameraService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final cacheService = ref.watch(cacheServiceProvider);
  return CameraService(apiClient, cacheService);
});

/// State for the cameras list.
class CamerasState {
  final List<Camera> cameras;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const CamerasState({
    this.cameras = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  CamerasState copyWith({
    List<Camera>? cameras,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CamerasState(
      cameras: cameras ?? this.cameras,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if we have cameras data.
  bool get hasData => cameras.isNotEmpty;

  /// Check if we have an error.
  bool get hasError => error != null;
}

/// Provider for the cameras list with automatic polling.
final camerasProvider = NotifierProvider<CamerasNotifier, CamerasState>(
  CamerasNotifier.new,
);

/// Notifier for managing cameras list state with polling.
class CamerasNotifier extends Notifier<CamerasState> {
  Timer? _pollingTimer;

  @override
  CamerasState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    // Defer polling until after build() completes and state is initialized
    Future.microtask(() => _startPolling());

    return const CamerasState(isLoading: true);
  }

  void _startPolling() {
    // Initial load
    loadCameras();

    // Set up polling timer
    final interval = Duration(seconds: EnvConfig.pollingInterval);
    _pollingTimer = Timer.periodic(interval, (_) {
      loadCameras(silent: true);
    });
  }

  /// Load cameras from the API.
  Future<void> loadCameras({
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final service = ref.read(cameraServiceProvider);
      final cameras = await service.getCameras(forceRefresh: forceRefresh);

      state = state.copyWith(
        cameras: cameras,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load cameras');
    }
  }

  /// Force refresh cameras from the API.
  Future<void> refresh() => loadCameras(forceRefresh: true);

  /// Update a single camera in the list (e.g., from WebSocket event).
  void updateCamera(Camera updatedCamera) {
    final cameras = state.cameras.map((c) {
      if (c.cameraId == updatedCamera.cameraId) {
        return updatedCamera;
      }
      return c;
    }).toList();

    state = state.copyWith(cameras: cameras, lastUpdated: DateTime.now());
  }

  /// Stop polling (call when app goes to background).
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Resume polling (call when app returns to foreground).
  void resumePolling() {
    if (_pollingTimer == null) {
      _startPolling();
    }
  }
}
