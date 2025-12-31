import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/core/services/api_client.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/timelapse_video.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/cameras_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/selected_camera_provider.dart';

/// State for timelapse data.
class TimelapseState {
  final TimelapseDetail? detail;
  final bool isLoading;
  final String? error;

  const TimelapseState({
    this.detail,
    this.isLoading = false,
    this.error,
  });

  TimelapseState copyWith({
    TimelapseDetail? detail,
    bool? isLoading,
    String? error,
  }) {
    return TimelapseState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasData => detail != null;
  bool get hasError => error != null;
  bool get hasVideo => detail?.video != null;
}

/// Provider for timelapse detail.
/// Automatically loads when camera or date changes.
final timelapseProvider = NotifierProvider<TimelapseNotifier, TimelapseState>(
  TimelapseNotifier.new,
);

class TimelapseNotifier extends Notifier<TimelapseState> {
  @override
  TimelapseState build() {
    // Watch for changes to camera or date
    final cameraId = ref.watch(selectedCameraIdProvider);
    final date = ref.watch(selectedDateProvider);

    if (cameraId == null) {
      return const TimelapseState();
    }

    // Load timelapse when dependencies change
    Future.microtask(() => loadTimelapse(cameraId, date));

    return const TimelapseState(isLoading: true);
  }

  /// Load timelapse for the specified camera and date.
  Future<void> loadTimelapse(String cameraId, DateTime date, {bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(cameraServiceProvider);
      final detail = await service.getTimelapse(cameraId, date, forceRefresh: forceRefresh);

      state = state.copyWith(
        detail: detail,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load timelapse',
      );
    }
  }

  /// Force refresh timelapse data.
  Future<void> refresh() async {
    final cameraId = ref.read(selectedCameraIdProvider);
    final date = ref.read(selectedDateProvider);

    if (cameraId == null) return;

    await loadTimelapse(cameraId, date, forceRefresh: true);
  }
}

/// Provider for available timelapse dates for the selected camera.
final availableDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final cameraId = ref.watch(selectedCameraIdProvider);

  if (cameraId == null) {
    return [];
  }

  final service = ref.watch(cameraServiceProvider);
  return service.getAvailableDates(cameraId);
});

/// Provider to check if a specific date has a timelapse.
final hasTimelapseProvider = Provider.family<bool, DateTime>((ref, date) {
  final availableDates = ref.watch(availableDatesProvider);

  return availableDates.maybeWhen(
    data: (dates) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      return dates.any((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
    },
    orElse: () => false,
  );
});
