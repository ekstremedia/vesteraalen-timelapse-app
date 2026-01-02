import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vesteraalen_timelapse/core/constants/app_constants.dart';
import 'package:vesteraalen_timelapse/core/widgets/image_preload_mixin.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/cameras_provider.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

/// A card widget displaying camera information and current image.
///
/// Features:
/// - Displays camera thumbnail with tap-to-fullscreen functionality
/// - Shows camera name, location/video count, and last update time
/// - Seamless image transitions using preloading (no flickering)
/// - Green flash animation on clock icon when image updates
/// - "See timelapse" button to navigate to camera detail
class CameraCard extends StatefulWidget {
  /// The camera data to display.
  final Camera camera;

  /// Callback when the timelapse button is pressed.
  final VoidCallback? onTimelapsePressed;

  const CameraCard({super.key, required this.camera, this.onTimelapsePressed});

  @override
  State<CameraCard> createState() => _CameraCardState();
}

class _CameraCardState extends State<CameraCard>
    with SingleTickerProviderStateMixin, ImagePreloadMixin {
  late AnimationController _flashController;

  Camera get camera => widget.camera;
  VoidCallback? get onTimelapsePressed => widget.onTimelapsePressed;

  @override
  void initState() {
    super.initState();
    initializeDisplayedUrl(camera.currentImageUrl);

    // Animation controller for clock icon flash (normal → green → normal)
    _flashController = AnimationController(
      duration: AppDurations.imageFlashAnimation,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CameraCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleUrlChange(camera.currentImageUrl);
  }

  @override
  void onImagePreloaded() {
    // Trigger green flash animation on clock icon
    _flashController.forward().then((_) {
      if (mounted) _flashController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Camera image - tappable to view fullscreen
          Expanded(
            child: InkWell(
              onTap: hasDisplayableImage
                  ? () => _showImageFullscreen(context, camera)
                  : null,
              child: _buildImage(context),
            ),
          ),

          // Camera info and timelapse button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Camera name
                Text(
                  camera.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Location/video count and time ago in one row
                Row(
                  children: [
                    Icon(
                      camera.location != null
                          ? Icons.location_on_outlined
                          : Icons.video_library_outlined,
                      size: AppDimensions.iconSm,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        camera.location ?? l10n.videoCount(camera.videoCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (camera.currentImageUpdatedAt != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Text(
                          '•',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _flashController,
                        builder: (context, child) {
                          final curvedValue = Curves.easeInOut.transform(
                            _flashController.value,
                          );
                          final normalColor =
                              theme.colorScheme.onSurfaceVariant;
                          return Icon(
                            Icons.access_time,
                            size: AppDimensions.iconSm,
                            color: Color.lerp(
                              normalColor,
                              AppStatusColors.connected,
                              curvedValue,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.formatRelativeTime(camera.currentImageUpdatedAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // See timelapse button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTimelapsePressed,
                    icon: const Icon(
                      Icons.play_circle_outline,
                      size: AppDimensions.iconMd,
                    ),
                    label: Text(l10n.seeTimelapse),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the camera image with placeholder and error handling.
  ///
  /// Uses a Stack to show both previous and current images during transitions,
  /// preventing any flickering when images update.
  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasDisplayableImage) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: AppDimensions.iconXl,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Previous image (shown underneath during transition)
          if (previousImageUrl != null)
            CachedNetworkImage(
              imageUrl: previousImageUrl!,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox.shrink(),
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              memCacheWidth: AppDimensions.imageCacheWidth,
              errorWidget: (context, url, error) => const SizedBox.shrink(),
            ),
          // Current image (on top)
          CachedNetworkImage(
            imageUrl: displayedImageUrl!,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox.shrink(),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            memCacheWidth: AppDimensions.imageCacheWidth,
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: AppDimensions.iconXl,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
          // Zoom hint icon
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: const Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: AppDimensions.iconLg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the fullscreen image viewer for the camera.
  void _showImageFullscreen(BuildContext context, Camera camera) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullscreenImageViewer(cameraId: camera.cameraId),
      ),
    );
  }
}

/// Fullscreen image viewer with pinch-to-zoom and real-time updates.
///
/// Watches the cameras provider for updates via polling and WebSocket,
/// using preloading for seamless image transitions.
class _FullscreenImageViewer extends ConsumerStatefulWidget {
  final String cameraId;

  const _FullscreenImageViewer({required this.cameraId});

  @override
  ConsumerState<_FullscreenImageViewer> createState() =>
      _FullscreenImageViewerState();
}

class _FullscreenImageViewerState
    extends ConsumerState<_FullscreenImageViewer> {
  String? _displayedImageUrl;
  String? _pendingImageUrl;

  @override
  void initState() {
    super.initState();
    final camerasState = ref.read(camerasProvider);
    final camera = camerasState.cameras
        .where((c) => c.cameraId == widget.cameraId)
        .firstOrNull;
    _displayedImageUrl = camera?.currentImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final camerasState = ref.watch(camerasProvider);

    // Find the camera by ID
    final camera = camerasState.cameras
        .where((c) => c.cameraId == widget.cameraId)
        .firstOrNull;

    // Check for new image URL and preload
    final newUrl = camera?.currentImageUrl;
    if (newUrl != null &&
        newUrl != _displayedImageUrl &&
        newUrl != _pendingImageUrl) {
      _pendingImageUrl = newUrl;
      _preloadAndSwitch(newUrl);
    }

    if (camera == null || _displayedImageUrl == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: theme.scaffoldBackgroundColor),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: Icon(Icons.broken_image, size: AppDimensions.iconXxl),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(camera.name),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: _displayedImageUrl!,
            fit: BoxFit.contain,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (context, url) => const SizedBox.shrink(),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Preloads an image and switches to it once loaded.
  Future<void> _preloadAndSwitch(String url) async {
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
      if (mounted && _pendingImageUrl == url) {
        setState(() {
          _displayedImageUrl = url;
          _pendingImageUrl = null;
        });
      }
    } catch (_) {
      if (mounted && _pendingImageUrl == url) {
        setState(() {
          _displayedImageUrl = url;
          _pendingImageUrl = null;
        });
      }
    }
  }
}
