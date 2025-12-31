import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/cameras_provider.dart';

/// Provider for the currently selected camera ID.
final selectedCameraIdProvider = StateProvider<String?>((ref) => null);

/// Provider for the currently selected camera.
/// Derived from the cameras list and selected ID.
final selectedCameraProvider = Provider<Camera?>((ref) {
  final cameraId = ref.watch(selectedCameraIdProvider);
  if (cameraId == null) return null;

  final camerasState = ref.watch(camerasProvider);
  return camerasState.cameras
      .where((c) => c.cameraId == cameraId)
      .firstOrNull;
});
