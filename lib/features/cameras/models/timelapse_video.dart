import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';

/// Timelapse video model representing a day's timelapse.
///
/// Maps to the PiTimelapseVideo model in the Laravel backend.
/// Contains video URLs, thumbnails, and daily summary images (keogram, etc.).
class TimelapseVideo {
  final int id;
  final String? cameraId;
  final DateTime date;
  final String? title;
  final String? youtubeId;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? daytimeUrl;
  final String? nightUrl;
  final String? keogramUrl;

  const TimelapseVideo({
    required this.id,
    this.cameraId,
    required this.date,
    this.title,
    this.youtubeId,
    this.videoUrl,
    this.thumbnailUrl,
    this.daytimeUrl,
    this.nightUrl,
    this.keogramUrl,
  });

  /// Create a TimelapseVideo from JSON data.
  factory TimelapseVideo.fromJson(Map<String, dynamic> json) {
    return TimelapseVideo(
      id: json['id'] as int,
      cameraId: json['camera_id'] as String?,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String?,
      youtubeId: json['youtube_id'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      daytimeUrl: json['daytime_url'] as String?,
      nightUrl: json['night_url'] as String?,
      keogramUrl: json['keogram_url'] as String?,
    );
  }

  /// Converts this video to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'camera_id': cameraId,
    'date': date.toApiFormat(),
    'title': title,
    'youtube_id': youtubeId,
    'video_url': videoUrl,
    'thumbnail_url': thumbnailUrl,
    'daytime_url': daytimeUrl,
    'night_url': nightUrl,
    'keogram_url': keogramUrl,
  };

  /// Create a copy with updated fields.
  TimelapseVideo copyWith({
    int? id,
    String? cameraId,
    DateTime? date,
    String? title,
    String? youtubeId,
    String? videoUrl,
    String? thumbnailUrl,
    String? daytimeUrl,
    String? nightUrl,
    String? keogramUrl,
  }) {
    return TimelapseVideo(
      id: id ?? this.id,
      cameraId: cameraId ?? this.cameraId,
      date: date ?? this.date,
      title: title ?? this.title,
      youtubeId: youtubeId ?? this.youtubeId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      daytimeUrl: daytimeUrl ?? this.daytimeUrl,
      nightUrl: nightUrl ?? this.nightUrl,
      keogramUrl: keogramUrl ?? this.keogramUrl,
    );
  }

  /// Check if video has YouTube embed.
  bool get hasYouTube => youtubeId != null && youtubeId!.isNotEmpty;

  /// Check if video has direct video file.
  bool get hasDirectVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// Check if has any playable video.
  bool get hasVideo => hasYouTube || hasDirectVideo;

  /// Check if has daytime image.
  bool get hasDaytimeImage => daytimeUrl != null && daytimeUrl!.isNotEmpty;

  /// Check if has night/evening image.
  bool get hasNightImage => nightUrl != null && nightUrl!.isNotEmpty;

  /// Check if has keogram image.
  bool get hasKeogram => keogramUrl != null && keogramUrl!.isNotEmpty;

  /// Check if has any daily images.
  bool get hasImages => hasDaytimeImage || hasNightImage || hasKeogram;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelapseVideo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cameraId == other.cameraId &&
          date == other.date;

  @override
  int get hashCode => id.hashCode ^ cameraId.hashCode ^ date.hashCode;

  @override
  String toString() =>
      'TimelapseVideo(id: $id, cameraId: $cameraId, date: ${date.toApiFormat()})';
}

/// Response model for timelapse detail API.
class TimelapseDetail {
  final CameraInfo camera;
  final DateTime currentDate;
  final bool isToday;
  final CurrentImage? currentImage;
  final TimelapseVideo? video;
  final TimelapseNavigation navigation;

  const TimelapseDetail({
    required this.camera,
    required this.currentDate,
    required this.isToday,
    this.currentImage,
    this.video,
    required this.navigation,
  });

  factory TimelapseDetail.fromJson(Map<String, dynamic> json) {
    return TimelapseDetail(
      camera: CameraInfo.fromJson(json['camera'] as Map<String, dynamic>),
      currentDate: DateTime.parse(json['current_date'] as String),
      isToday: json['is_today'] as bool? ?? false,
      currentImage: json['current_image'] != null
          ? CurrentImage.fromJson(json['current_image'] as Map<String, dynamic>)
          : null,
      video: json['video'] != null
          ? TimelapseVideo.fromJson(json['video'] as Map<String, dynamic>)
          : null,
      navigation: TimelapseNavigation.fromJson(
        json['navigation'] as Map<String, dynamic>,
      ),
    );
  }
}

/// Minimal camera info returned with timelapse detail.
class CameraInfo {
  final int id;
  final String cameraId;
  final String name;
  final String? location;

  const CameraInfo({
    required this.id,
    required this.cameraId,
    required this.name,
    this.location,
  });

  factory CameraInfo.fromJson(Map<String, dynamic> json) {
    return CameraInfo(
      id: json['id'] as int,
      cameraId: json['camera_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String?,
    );
  }
}

/// Current camera image info.
class CurrentImage {
  final String url;
  final DateTime updatedAt;

  const CurrentImage({required this.url, required this.updatedAt});

  factory CurrentImage.fromJson(Map<String, dynamic> json) {
    return CurrentImage(
      url: json['url'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// Navigation info for moving between timelapse dates.
class TimelapseNavigation {
  final DateTime? previousDate;
  final DateTime? nextDate;
  final bool hasPrevious;
  final bool hasNext;

  const TimelapseNavigation({
    this.previousDate,
    this.nextDate,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory TimelapseNavigation.fromJson(Map<String, dynamic> json) {
    return TimelapseNavigation(
      previousDate: json['previous_date'] != null
          ? DateTime.parse(json['previous_date'] as String)
          : null,
      nextDate: json['next_date'] != null
          ? DateTime.parse(json['next_date'] as String)
          : null,
      hasPrevious: json['has_previous'] as bool? ?? false,
      hasNext: json['has_next'] as bool? ?? false,
    );
  }
}
