import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/pages/camera_detail_page.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/cameras_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/selected_camera_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/widgets/camera_card.dart';
import 'package:vesteraalen_timelapse/features/settings/pages/settings_page.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

/// Main page displaying a responsive grid of cameras.
class CamerasListPage extends ConsumerWidget {
  const CamerasListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final camerasState = ref.watch(camerasProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(camerasProvider.notifier).refresh(),
        child: _buildBody(context, camerasState, ref),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CamerasState state, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (state.isLoading && !state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingCameras),
          ],
        ),
      );
    }

    if (state.hasError && !state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error ?? l10n.somethingWentWrong,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.read(camerasProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (!state.hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, size: 64),
            const SizedBox(height: 16),
            Text(l10n.noCameras),
          ],
        ),
      );
    }

    return _buildCameraGrid(context, state, ref);
  }

  Widget _buildCameraGrid(
      BuildContext context, CamerasState state, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

    return CustomScrollView(
      slivers: [
        // Show subtle loading indicator when refreshing in background
        if (state.isLoading)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(),
          ),

        // Camera grid
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: _calculateChildAspectRatio(crossAxisCount),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final camera = state.cameras[index];
                return CameraCard(
                  camera: camera,
                  onTap: () => _openCameraDetail(context, ref, camera),
                );
              },
              childCount: state.cameras.length,
            ),
          ),
        ),
      ],
    );
  }

  /// Calculate number of columns based on screen width.
  int _calculateCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  /// Calculate aspect ratio based on number of columns.
  double _calculateChildAspectRatio(int crossAxisCount) {
    // More columns = wider cards, adjust ratio
    switch (crossAxisCount) {
      case 1:
        return 1.3; // Taller on phone
      case 2:
        return 1.1;
      case 3:
        return 1.0;
      default:
        return 0.9; // More square on large screens
    }
  }

  void _openCameraDetail(BuildContext context, WidgetRef ref, Camera camera) {
    // Set the selected camera
    ref.read(selectedCameraIdProvider.notifier).state = camera.cameraId;

    // Set the date to the camera's latest video date, or fall back to yesterday
    final latestVideoDate = camera.latestVideo?.date;
    if (latestVideoDate != null) {
      ref.read(selectedDateProvider.notifier).state = latestVideoDate;
    } else {
      final now = DateTime.now();
      ref.read(selectedDateProvider.notifier).state = DateTime(now.year, now.month, now.day - 1);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraDetailPage(),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }
}
