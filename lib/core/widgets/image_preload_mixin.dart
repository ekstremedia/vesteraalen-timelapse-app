import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vesteraalen_timelapse/core/constants/app_constants.dart';

/// Mixin that provides seamless image preloading functionality.
///
/// This mixin handles the logic for preloading new images before displaying
/// them, ensuring smooth transitions without flickering when images update.
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with ImagePreloadMixin {
///   @override
///   void initState() {
///     super.initState();
///     initializeDisplayedUrl(initialUrl);
///   }
///
///   @override
///   void didUpdateWidget(MyWidget oldWidget) {
///     super.didUpdateWidget(oldWidget);
///     handleUrlChange(newUrl);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Image.network(displayedImageUrl ?? '');
///   }
/// }
/// ```
mixin ImagePreloadMixin<T extends StatefulWidget> on State<T> {
  String? _displayedImageUrl;
  String? _previousImageUrl;
  String? _pendingImageUrl;

  /// The currently displayed image URL.
  ///
  /// This URL is only updated after the new image has been fully preloaded,
  /// ensuring seamless transitions.
  String? get displayedImageUrl => _displayedImageUrl;

  /// The previous image URL, kept visible during transitions.
  ///
  /// Used to prevent flickering by showing the old image underneath
  /// while the new image loads.
  String? get previousImageUrl => _previousImageUrl;

  /// Whether there is a displayable image URL.
  bool get hasDisplayableImage =>
      _displayedImageUrl != null && _displayedImageUrl!.isNotEmpty;

  /// Callback invoked when an image has been successfully preloaded and displayed.
  ///
  /// Override this method to perform actions after image updates,
  /// such as triggering animations.
  void onImagePreloaded() {}

  /// Initializes the displayed URL without preloading.
  ///
  /// Call this in [initState] to set the initial image URL.
  void initializeDisplayedUrl(String? url) {
    _displayedImageUrl = url;
  }

  /// Handles a URL change by preloading the new image before displaying.
  ///
  /// Call this in [didUpdateWidget] when the image URL may have changed.
  /// The new image will only be displayed after it's fully loaded.
  void handleUrlChange(String? newUrl) {
    if (newUrl != null &&
        newUrl != _displayedImageUrl &&
        newUrl != _pendingImageUrl) {
      _pendingImageUrl = newUrl;
      _preloadAndSwitch(newUrl);
    }
  }

  /// Preloads an image and switches to it once loaded.
  ///
  /// Uses [CachedNetworkImageProvider] for efficient caching.
  /// Keeps the previous image URL so it can be shown during transition.
  /// If preloading fails, the image is still displayed to allow
  /// the image widget to handle the error gracefully.
  Future<void> _preloadAndSwitch(String url) async {
    try {
      await precacheImage(
        CachedNetworkImageProvider(
          url,
          maxWidth: AppDimensions.imageCacheWidth,
        ),
        context,
      );
      if (mounted && _pendingImageUrl == url) {
        setState(() {
          _previousImageUrl = _displayedImageUrl;
          _displayedImageUrl = url;
          _pendingImageUrl = null;
        });
        onImagePreloaded();
        // Clear previous URL after a short delay to allow smooth transition
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _previousImageUrl = null;
            });
          }
        });
      }
    } catch (_) {
      // If preload fails, still display the image to let the widget handle errors
      if (mounted && _pendingImageUrl == url) {
        setState(() {
          _previousImageUrl = _displayedImageUrl;
          _displayedImageUrl = url;
          _pendingImageUrl = null;
        });
      }
    }
  }
}
