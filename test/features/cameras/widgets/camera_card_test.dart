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

    testWidgets('calls onTimelapsePressed when button tapped', (tester) async {
      bool tapped = false;
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        videoCount: 0,
      );

      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            height: 400,
            width: 300,
            child: CameraCard(
              camera: camera,
              onTimelapsePressed: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('See timelapse'));
      expect(tapped, isTrue);
    });

    testWidgets('displays See timelapse button', (tester) async {
      final camera = Camera(
        id: 1,
        cameraId: 'test_camera',
        name: 'Test Camera',
        videoCount: 0,
      );

      await tester.pumpWidget(
        createTestWidget(
          SizedBox(height: 400, width: 300, child: CameraCard(camera: camera)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('See timelapse'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
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
