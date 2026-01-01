import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';
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
            _buildContent(context, ref, timelapseState, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
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

        // Info message for today (no timelapse available yet)
        if (detail.isToday && (video == null || !video.hasYouTube))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.todayTimelapseNotReady,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final yesterday = DateTime.now().subtract(
                          const Duration(days: 1),
                        );
                        ref.read(selectedDateProvider.notifier).state =
                            yesterday.dateOnly;
                      },
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: Text(l10n.seeYesterdaysVideo),
                    ),
                  ),
                ],
              ),
            ),
          ),

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

  Widget _buildYouTubePlayer(
    BuildContext context,
    String youtubeId,
    AppLocalizations l10n,
  ) {
    return _EmbeddedYoutubePlayer(
      youtubeId: youtubeId,
      onOpenExternal: () => _openYouTube(context, youtubeId),
    );
  }

  Future<void> _openYouTube(BuildContext context, String youtubeId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$youtubeId');
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open YouTube')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening YouTube: $e')));
      }
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
    final theme = Theme.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: theme.scaffoldBackgroundColor,
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
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

/// Embedded YouTube player widget with proper lifecycle management.
class _EmbeddedYoutubePlayer extends StatefulWidget {
  final String youtubeId;
  final VoidCallback onOpenExternal;

  const _EmbeddedYoutubePlayer({
    required this.youtubeId,
    required this.onOpenExternal,
  });

  @override
  State<_EmbeddedYoutubePlayer> createState() => _EmbeddedYoutubePlayerState();
}

class _EmbeddedYoutubePlayerState extends State<_EmbeddedYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: false,
        forceHD: false,
        hideControls: false,
      ),
    );
  }

  @override
  void didUpdateWidget(_EmbeddedYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.youtubeId != widget.youtubeId) {
      _controller.load(widget.youtubeId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
              builder: (context, player) {
                return AspectRatio(aspectRatio: 16 / 9, child: player);
              },
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
                    onPressed: widget.onOpenExternal,
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
}
