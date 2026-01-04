import 'package:flutter_test/flutter_test.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/timelapse_video.dart';

void main() {
  group('TimelapseVideo', () {
    test('fromJson creates a valid TimelapseVideo', () {
      final json = {
        'id': 100,
        'camera_id': 'test_camera',
        'date': '2025-12-30',
        'title': 'Test Timelapse',
        'youtube_id': 'abc123',
        'video_url': 'https://example.com/video.mp4',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'daytime_url': 'https://example.com/daytime.jpg',
        'night_url': 'https://example.com/night.jpg',
        'keogram_url': 'https://example.com/keogram.jpg',
        'slitscan_url': 'https://example.com/slitscan.jpg',
      };

      final video = TimelapseVideo.fromJson(json);

      expect(video.id, 100);
      expect(video.cameraId, 'test_camera');
      expect(video.date.year, 2025);
      expect(video.date.month, 12);
      expect(video.date.day, 30);
      expect(video.title, 'Test Timelapse');
      expect(video.youtubeId, 'abc123');
      expect(video.videoUrl, 'https://example.com/video.mp4');
      expect(video.daytimeUrl, 'https://example.com/daytime.jpg');
      expect(video.nightUrl, 'https://example.com/night.jpg');
      expect(video.keogramUrl, 'https://example.com/keogram.jpg');
      expect(video.slitscanUrl, 'https://example.com/slitscan.jpg');
    });

    test('fromJson handles nullable fields', () {
      final json = {
        'id': 100,
        'camera_id': 'test_camera',
        'date': '2025-12-30',
        'title': null,
        'youtube_id': null,
        'video_url': null,
        'daytime_url': null,
        'night_url': null,
        'keogram_url': null,
        'slitscan_url': null,
      };

      final video = TimelapseVideo.fromJson(json);

      expect(video.title, isNull);
      expect(video.youtubeId, isNull);
      expect(video.videoUrl, isNull);
      expect(video.slitscanUrl, isNull);
    });

    test('toJson produces valid JSON', () {
      final video = TimelapseVideo(
        id: 100,
        cameraId: 'test_camera',
        date: DateTime(2025, 12, 30),
        title: 'Test Timelapse',
        youtubeId: 'abc123',
      );

      final json = video.toJson();

      expect(json['id'], 100);
      expect(json['camera_id'], 'test_camera');
      expect(json['date'], '2025-12-30');
      expect(json['title'], 'Test Timelapse');
      expect(json['youtube_id'], 'abc123');
    });

    test('hasYouTube returns correct value', () {
      final videoWithYouTube = TimelapseVideo(
        id: 1,
        cameraId: 'test',
        date: DateTime.now(),
        youtubeId: 'abc123',
      );

      final videoWithoutYouTube = TimelapseVideo(
        id: 2,
        cameraId: 'test',
        date: DateTime.now(),
        youtubeId: null,
      );

      final videoWithEmptyYouTube = TimelapseVideo(
        id: 3,
        cameraId: 'test',
        date: DateTime.now(),
        youtubeId: '',
      );

      expect(videoWithYouTube.hasYouTube, true);
      expect(videoWithoutYouTube.hasYouTube, false);
      expect(videoWithEmptyYouTube.hasYouTube, false);
    });

    test('hasDirectVideo returns correct value', () {
      final videoWithUrl = TimelapseVideo(
        id: 1,
        cameraId: 'test',
        date: DateTime.now(),
        videoUrl: 'https://example.com/video.mp4',
      );

      final videoWithoutUrl = TimelapseVideo(
        id: 2,
        cameraId: 'test',
        date: DateTime.now(),
        videoUrl: null,
      );

      expect(videoWithUrl.hasDirectVideo, true);
      expect(videoWithoutUrl.hasDirectVideo, false);
    });

    test('hasVideo returns true if has YouTube or direct video', () {
      final videoWithYouTube = TimelapseVideo(
        id: 1,
        cameraId: 'test',
        date: DateTime.now(),
        youtubeId: 'abc123',
      );

      final videoWithUrl = TimelapseVideo(
        id: 2,
        cameraId: 'test',
        date: DateTime.now(),
        videoUrl: 'https://example.com/video.mp4',
      );

      final videoWithBoth = TimelapseVideo(
        id: 3,
        cameraId: 'test',
        date: DateTime.now(),
        youtubeId: 'abc123',
        videoUrl: 'https://example.com/video.mp4',
      );

      final videoWithNeither = TimelapseVideo(
        id: 4,
        cameraId: 'test',
        date: DateTime.now(),
      );

      expect(videoWithYouTube.hasVideo, true);
      expect(videoWithUrl.hasVideo, true);
      expect(videoWithBoth.hasVideo, true);
      expect(videoWithNeither.hasVideo, false);
    });

    test('hasImages returns true if has any image', () {
      final videoWithDaytime = TimelapseVideo(
        id: 1,
        cameraId: 'test',
        date: DateTime.now(),
        daytimeUrl: 'https://example.com/daytime.jpg',
      );

      final videoWithNight = TimelapseVideo(
        id: 2,
        cameraId: 'test',
        date: DateTime.now(),
        nightUrl: 'https://example.com/night.jpg',
      );

      final videoWithKeogram = TimelapseVideo(
        id: 3,
        cameraId: 'test',
        date: DateTime.now(),
        keogramUrl: 'https://example.com/keogram.jpg',
      );

      final videoWithSlitscan = TimelapseVideo(
        id: 4,
        cameraId: 'test',
        date: DateTime.now(),
        slitscanUrl: 'https://example.com/slitscan.jpg',
      );

      final videoWithNoImages = TimelapseVideo(
        id: 5,
        cameraId: 'test',
        date: DateTime.now(),
      );

      expect(videoWithDaytime.hasImages, true);
      expect(videoWithNight.hasImages, true);
      expect(videoWithKeogram.hasImages, true);
      expect(videoWithSlitscan.hasImages, true);
      expect(videoWithNoImages.hasImages, false);
    });

    test('hasSlitscan returns correct value', () {
      final videoWithSlitscan = TimelapseVideo(
        id: 1,
        cameraId: 'test',
        date: DateTime.now(),
        slitscanUrl: 'https://example.com/slitscan.jpg',
      );

      final videoWithoutSlitscan = TimelapseVideo(
        id: 2,
        cameraId: 'test',
        date: DateTime.now(),
        slitscanUrl: null,
      );

      final videoWithEmptySlitscan = TimelapseVideo(
        id: 3,
        cameraId: 'test',
        date: DateTime.now(),
        slitscanUrl: '',
      );

      expect(videoWithSlitscan.hasSlitscan, true);
      expect(videoWithoutSlitscan.hasSlitscan, false);
      expect(videoWithEmptySlitscan.hasSlitscan, false);
    });

    test('copyWith creates a modified copy', () {
      final video = TimelapseVideo(
        id: 100,
        cameraId: 'test_camera',
        date: DateTime(2025, 12, 30),
        title: 'Original Title',
      );

      final updated = video.copyWith(
        title: 'Updated Title',
        youtubeId: 'new_id',
      );

      expect(updated.id, 100);
      expect(updated.cameraId, 'test_camera');
      expect(updated.title, 'Updated Title');
      expect(updated.youtubeId, 'new_id');

      // Original should be unchanged
      expect(video.title, 'Original Title');
      expect(video.youtubeId, isNull);
    });
  });

  group('TimelapseDetail', () {
    test('fromJson creates a valid TimelapseDetail', () {
      final json = {
        'camera': {
          'id': 1,
          'camera_id': 'test_camera',
          'name': 'Test Camera',
          'location': 'Sortland',
        },
        'current_date': '2025-12-30',
        'is_today': false,
        'current_image': null,
        'video': {
          'id': 100,
          'camera_id': 'test_camera',
          'date': '2025-12-30',
          'title': 'Test Timelapse',
          'youtube_id': 'abc123',
        },
        'navigation': {
          'previous_date': '2025-12-29',
          'next_date': null,
          'has_previous': true,
          'has_next': false,
        },
      };

      final detail = TimelapseDetail.fromJson(json);

      expect(detail.camera.cameraId, 'test_camera');
      expect(detail.camera.name, 'Test Camera');
      expect(detail.currentDate.day, 30);
      expect(detail.isToday, false);
      expect(detail.currentImage, isNull);
      expect(detail.video, isNotNull);
      expect(detail.video!.youtubeId, 'abc123');
      expect(detail.navigation.hasPrevious, true);
      expect(detail.navigation.hasNext, false);
      expect(detail.navigation.previousDate!.day, 29);
    });

    test('fromJson handles current_image', () {
      final json = {
        'camera': {'id': 1, 'camera_id': 'test_camera', 'name': 'Test Camera'},
        'current_date': '2025-12-31',
        'is_today': true,
        'current_image': {
          'url': 'https://example.com/current.jpg',
          'updated_at': '2025-12-31T10:30:00Z',
        },
        'video': null,
        'navigation': {
          'previous_date': null,
          'next_date': null,
          'has_previous': false,
          'has_next': false,
        },
      };

      final detail = TimelapseDetail.fromJson(json);

      expect(detail.isToday, true);
      expect(detail.currentImage, isNotNull);
      expect(detail.currentImage!.url, 'https://example.com/current.jpg');
      expect(detail.video, isNull);
    });
  });

  group('TimelapseNavigation', () {
    test('fromJson creates valid navigation', () {
      final json = {
        'previous_date': '2025-12-29',
        'next_date': '2025-12-31',
        'has_previous': true,
        'has_next': true,
      };

      final nav = TimelapseNavigation.fromJson(json);

      expect(nav.previousDate!.day, 29);
      expect(nav.nextDate!.day, 31);
      expect(nav.hasPrevious, true);
      expect(nav.hasNext, true);
    });

    test('fromJson handles null dates', () {
      final json = {
        'previous_date': null,
        'next_date': null,
        'has_previous': false,
        'has_next': false,
      };

      final nav = TimelapseNavigation.fromJson(json);

      expect(nav.previousDate, isNull);
      expect(nav.nextDate, isNull);
      expect(nav.hasPrevious, false);
      expect(nav.hasNext, false);
    });
  });
}
