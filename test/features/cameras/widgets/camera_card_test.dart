import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vesteraalen_timelapse/features/cameras/models/camera.dart';
import 'package:vesteraalen_timelapse/features/cameras/widgets/camera_card.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [AppLocalizations.delegate],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('CameraCard', () {
    testWidgets('displays camera name', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera Name',
        videoCount: 10,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pumpAndSettle();

      expect(find.text('Test Camera Name'), findsOneWidget);
    });

    testWidgets('displays location when provided', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        location: 'Sortland, Vesterålen',
        videoCount: 5,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pumpAndSettle();

      expect(find.text('Sortland, Vesterålen'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('displays video count', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        videoCount: 42,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pumpAndSettle();

      expect(find.text('42 videos'), findsOneWidget);
      expect(find.byIcon(Icons.video_library_outlined), findsOneWidget);
    });

    testWidgets('displays singular video count', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        videoCount: 1,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pumpAndSettle();

      expect(find.text('1 video'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        currentImageUrl: null,
        videoCount: 0,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('does not show placeholder when image URL provided', (
      tester,
    ) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        currentImageUrl: 'https://example.com/image.jpg',
        videoCount: 0,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pump();

      // Placeholder icon should not be present when image URL is provided
      expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        videoCount: 0,
      );

      await tester.pumpWidget(
        createTestWidget(
          CameraCard(camera: camera, onTap: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('is a Card widget', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        videoCount: 0,
      );

      await tester.pumpWidget(createTestWidget(CameraCard(camera: camera)));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
