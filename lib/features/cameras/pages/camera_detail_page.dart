import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/selected_camera_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/timelapse_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/widgets/date_navigation.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

/// Detail page showing timelapse and images for a specific camera.
class CameraDetailPage extends ConsumerWidget {
  const CameraDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final camera = ref.watch(selectedCameraProvider);
    final timelapseState = ref.watch(timelapseProvider);

    if (camera == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.cameraNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(camera.name)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(timelapseProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Date navigation bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const DateNavigationBar(),
              ),
            ),

            // Content based on state
            _buildContent(context, timelapseState, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TimelapseState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && !state.hasData) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError && !state.hasData) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(state.error ?? l10n.somethingWentWrong),
            ],
          ),
        ),
      );
    }

    if (!state.hasData) {
      return SliverFillRemaining(
        child: Center(child: Text(l10n.noTimelapseAvailable)),
      );
    }

    final detail = state.detail!;
    final video = detail.video;

    return SliverList(
      delegate: SliverChildListDelegate([
        // Loading indicator during refresh
        if (state.isLoading) const LinearProgressIndicator(),

        // Video section
        if (video != null && video.hasYouTube) ...[
          _buildYouTubePlayer(context, video.youtubeId!, l10n),
        ],

        // Current image for today
        if (detail.isToday && detail.currentImage != null) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentImage,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: detail.currentImage!.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                if (detail.currentImage?.updatedAt case final updatedAt?)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.formatRelativeTime(updatedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],

        // Daily images section
        if (video != null && video.hasImages) ...[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyImages,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildImageGrid(context, video, l10n),
              ],
            ),
          ),
        ],

        // No content message
        if (video == null && !detail.isToday)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.videocam_off_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTimelapseAvailable,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

        // Bottom padding
        const SizedBox(height: 32),
      ]),
    );
  }

  /// Check if embedded YouTube player is supported on this platform.
  bool get _supportsEmbeddedPlayer {
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS) return true;
    return false; // Linux, Windows, macOS don't support WebView well
  }

  Widget _buildYouTubePlayer(
    BuildContext context,
    String youtubeId,
    AppLocalizations l10n,
  ) {
    // Use external link on unsupported platforms (Linux, Windows, macOS)
    if (!_supportsEmbeddedPlayer) {
      return _buildYouTubeThumbnail(context, youtubeId, l10n);
    }

    final controller = YoutubePlayerController.fromVideoId(
      videoId: youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
        showControls: true,
        enableCaption: false,
        playsInline: true,
        strictRelatedVideos: true,
        origin: 'https://www.youtube.com',
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.timelapse,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openYouTube(youtubeId),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(l10n.watchOnYoutube),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubeThumbnail(
    BuildContext context,
    String youtubeId,
    AppLocalizations l10n,
  ) {
    final thumbnailUrl =
        'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openYouTube(youtubeId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      l10n.watchOnYoutube,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openYouTube(String youtubeId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$youtubeId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildImageGrid(
    BuildContext context,
    dynamic video,
    AppLocalizations l10n,
  ) {
    final images = <MapEntry<String, String>>[];

    if (video.daytimeUrl != null) {
      images.add(MapEntry(l10n.daytime, video.daytimeUrl!));
    }
    if (video.nightUrl != null) {
      images.add(MapEntry(l10n.evening, video.nightUrl!));
    }
    if (video.keogramUrl != null) {
      images.add(MapEntry(l10n.keogram, video.keogramUrl!));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 16 / 9,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final entry = images[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () =>
                      _showImageFullscreen(context, entry.value, entry.key),
                  child: CachedNetworkImage(
                    imageUrl: entry.value,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
      },
    );
  }

  void _showImageFullscreen(BuildContext context, String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: url,
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
