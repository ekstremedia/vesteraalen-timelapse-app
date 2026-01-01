import 'package:flutter_test/flutter_test.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';

void main() {
  group('Camera', () {
    test('fromJson creates a valid Camera', () {
      final json = {
        'id': 1,
        'camera_id': 'test_camera',
        'name': 'Test Camera',
        'description': 'A test camera',
        'location': 'Sortland',
        'current_image_url': 'https://example.com/image.jpg',
        'current_image_updated_at': '2025-12-31T10:30:00Z',
        'video_count': 42,
        'latest_video': null,
      };

      final camera = Camera.fromJson(json);

      expect(camera.id, 1);
      expect(camera.cameraId, 'test_camera');
      expect(camera.name, 'Test Camera');
      expect(camera.description, 'A test camera');
      expect(camera.location, 'Sortland');
      expect(camera.currentImageUrl, 'https://example.com/image.jpg');
      expect(camera.currentImageUpdatedAt, isNotNull);
      expect(camera.videoCount, 42);
      expect(camera.latestVideo, isNull);
    });

    test('fromJson handles nullable fields', () {
      final json = {
        'id': 1,
        'camera_id': 'test_camera',
        'name': 'Test Camera',
        'description': null,
        'location': null,
        'current_image_url': null,
        'current_image_updated_at': null,
        'video_count': null,
        'latest_video': null,
      };

      final camera = Camera.fromJson(json);

      expect(camera.description, isNull);
      expect(camera.location, isNull);
      expect(camera.currentImageUrl, isNull);
      expect(camera.currentImageUpdatedAt, isNull);
      expect(camera.videoCount, 0);
    });

    test('fromJson parses nested latest_video', () {
      final json = {
        'id': 1,
        'camera_id': 'test_camera',
        'name': 'Test Camera',
        'video_count': 1,
        'latest_video': {
          'id': 100,
          'camera_id': 'test_camera',
          'date': '2025-12-30',
          'youtube_id': 'abc123',
          'daytime_url': 'https://example.com/daytime.jpg',
          'night_url': 'https://example.com/night.jpg',
        },
      };

      final camera = Camera.fromJson(json);

      expect(camera.latestVideo, isNotNull);
      expect(camera.latestVideo!.id, 100);
      expect(camera.latestVideo!.youtubeId, 'abc123');
    });

    test('toJson produces valid JSON', () {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        description: 'A test camera',
        location: 'Sortland',
        videoCount: 10,
      );

      final json = camera.toJson();

      expect(json['id'], 1);
      expect(json['camera_id'], 'test_camera');
      expect(json['name'], 'Test Camera');
      expect(json['description'], 'A test camera');
      expect(json['location'], 'Sortland');
      expect(json['video_count'], 10);
    });

    test('copyWith creates a modified copy', () {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Original Name',
        videoCount: 5,
      );

      final updated = camera.copyWith(name: 'Updated Name', videoCount: 10);

      expect(updated.id, 1);
      expect(updated.cameraId, 'test_camera');
      expect(updated.name, 'Updated Name');
      expect(updated.videoCount, 10);

      // Original should be unchanged
      expect(camera.name, 'Original Name');
      expect(camera.videoCount, 5);
    });

    test('hasCurrentImage returns correct value', () {
      final cameraWithImage = Camera(
        id: 1,
        cameraId: 'test',
        name: 'Test',
        currentImageUrl: 'https://example.com/image.jpg',
      );

      final cameraWithoutImage = Camera(
        id: 2,
        cameraId: 'test2',
        name: 'Test 2',
        currentImageUrl: null,
      );

      final cameraWithEmptyImage = Camera(
        id: 3,
        cameraId: 'test3',
        name: 'Test 3',
        currentImageUrl: '',
      );

      expect(cameraWithImage.hasCurrentImage, true);
      expect(cameraWithoutImage.hasCurrentImage, false);
      expect(cameraWithEmptyImage.hasCurrentImage, false);
    });

    test('hasVideos returns correct value', () {
      final cameraWithVideos = Camera(
        id: 1,
        cameraId: 'test',
        name: 'Test',
        videoCount: 5,
      );

      final cameraWithoutVideos = Camera(
        id: 2,
        cameraId: 'test2',
        name: 'Test 2',
        videoCount: 0,
      );

      expect(cameraWithVideos.hasVideos, true);
      expect(cameraWithoutVideos.hasVideos, false);
    });

    test('equality comparison works correctly', () {
      final camera1 = Camera(id: 1, cameraId: 'test', name: 'Test');
      final camera2 = Camera(id: 1, cameraId: 'test', name: 'Different Name');
      final camera3 = Camera(id: 2, cameraId: 'test2', name: 'Test');

      expect(camera1, equals(camera2)); // Same id and cameraId
      expect(camera1, isNot(equals(camera3))); // Different id and cameraId
    });
  });
}
