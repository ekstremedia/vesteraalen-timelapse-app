import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

/// A card widget displaying camera information and current image.
class CameraCard extends StatelessWidget {
  final Camera camera;
  final VoidCallback? onTimelapsePressed;

  const CameraCard({super.key, required this.camera, this.onTimelapsePressed});

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
              onTap: camera.hasCurrentImage
                  ? () => _showImageFullscreen(context, camera)
                  : null,
              child: _buildImage(context),
            ),
          ),

          // Camera info and timelapse button
          Padding(
            padding: const EdgeInsets.all(12),
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

                const SizedBox(height: 4),

                // Location or video count
                Row(
                  children: [
                    Icon(
                      camera.location != null
                          ? Icons.location_on_outlined
                          : Icons.video_library_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        camera.location ?? l10n.videoCount(camera.videoCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // See timelapse button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTimelapsePressed,
                    icon: const Icon(Icons.play_circle_outline, size: 18),
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

  Widget _buildImage(BuildContext context) {
    final theme = Theme.of(context);

    if (!camera.hasCurrentImage) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.camera_alt_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: camera.currentImageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
        // Zoom hint icon
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  void _showImageFullscreen(BuildContext context, Camera camera) {
    final theme = Theme.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
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
                imageUrl: camera.currentImageUrl!,
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
