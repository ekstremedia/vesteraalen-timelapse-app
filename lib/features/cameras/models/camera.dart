import 'package:vesteraalen_timelapse/features/cameras/models/timelapse_video.dart';

/// Camera model representing a camera location.
/// Maps to the Camera model in the Laravel backend.
class Camera {
  final int id;
  final String cameraId;
  final String name;
  final String? description;
  final String? location;
  final String? currentImageUrl;
  final DateTime? currentImageUpdatedAt;
  final TimelapseVideo? latestVideo;
  final int videoCount;

  const Camera({
    required this.id,
    required this.cameraId,
    required this.name,
    this.description,
    this.location,
    this.currentImageUrl,
    this.currentImageUpdatedAt,
    this.latestVideo,
    this.videoCount = 0,
  });

  /// Create a Camera from JSON data.
  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      id: json['id'] as int,
      cameraId: json['camera_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      currentImageUrl: json['current_image_url'] as String?,
      currentImageUpdatedAt: json['current_image_updated_at'] != null
          ? DateTime.parse(json['current_image_updated_at'] as String)
          : null,
      latestVideo: json['latest_video'] != null
          ? TimelapseVideo.fromJson(
              json['latest_video'] as Map<String, dynamic>,
            )
          : null,
      videoCount: json['video_count'] as int? ?? 0,
    );
  }

  /// Convert Camera to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'camera_id': cameraId,
    'name': name,
    'description': description,
    'location': location,
    'current_image_url': currentImageUrl,
    'current_image_updated_at': currentImageUpdatedAt?.toIso8601String(),
    'latest_video': latestVideo?.toJson(),
    'video_count': videoCount,
  };

  /// Create a copy with updated fields.
  Camera copyWith({
    int? id,
    String? cameraId,
    String? name,
    String? description,
    String? location,
    String? currentImageUrl,
    DateTime? currentImageUpdatedAt,
    TimelapseVideo? latestVideo,
    int? videoCount,
  }) {
    return Camera(
      id: id ?? this.id,
      cameraId: cameraId ?? this.cameraId,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      currentImageUrl: currentImageUrl ?? this.currentImageUrl,
      currentImageUpdatedAt:
          currentImageUpdatedAt ?? this.currentImageUpdatedAt,
      latestVideo: latestVideo ?? this.latestVideo,
      videoCount: videoCount ?? this.videoCount,
    );
  }

  /// Check if camera has a current image.
  bool get hasCurrentImage =>
      currentImageUrl != null && currentImageUrl!.isNotEmpty;

  /// Returns the current image URL with a cache-busting timestamp.
  ///
  /// This ensures that CachedNetworkImage fetches fresh images when
  /// the server image updates, instead of serving stale disk-cached versions.
  String? get currentImageUrlWithCacheBuster {
    if (currentImageUrl == null) return null;
    if (currentImageUpdatedAt == null) return currentImageUrl;

    final timestamp = currentImageUpdatedAt!.millisecondsSinceEpoch;
    final separator = currentImageUrl!.contains('?') ? '&' : '?';
    return '$currentImageUrl${separator}t=$timestamp';
  }

  /// Check if camera has any timelapse videos.
  bool get hasVideos => videoCount > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Camera &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cameraId == other.cameraId;

  @override
  int get hashCode => id.hashCode ^ cameraId.hashCode;

  @override
  String toString() => 'Camera(id: $id, cameraId: $cameraId, name: $name)';
}
