import 'package:flutter_test/flutter_test.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';

void main() {
  group('DateTimeExtensions', () {
    test('isToday returns true for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(today.isToday, isTrue);
    });

    test('isToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, isFalse);
    });

    test('isYesterday returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      expect(yesterdayDate.isYesterday, isTrue);
    });

    test('isYesterday returns false for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(today.isYesterday, isFalse);
    });

    test('isFuture returns true for tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(tomorrow.isFuture, isTrue);
    });

    test('isFuture returns false for today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(today.isFuture, isFalse);
    });

    test('isFuture returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isFuture, isFalse);
    });

    test('dateOnly removes time component', () {
      final withTime = DateTime(2025, 12, 31, 14, 30, 45);
      final dateOnly = withTime.dateOnly;

      expect(dateOnly.year, 2025);
      expect(dateOnly.month, 12);
      expect(dateOnly.day, 31);
      expect(dateOnly.hour, 0);
      expect(dateOnly.minute, 0);
      expect(dateOnly.second, 0);
    });

    test('toApiFormat formats correctly', () {
      final date = DateTime(2025, 1, 5);
      expect(date.toApiFormat(), '2025-01-05');
    });

    test('toApiFormat pads single digits', () {
      final date = DateTime(2025, 3, 9);
      expect(date.toApiFormat(), '2025-03-09');
    });

    test('toApiFormat handles December', () {
      final date = DateTime(2025, 12, 31);
      expect(date.toApiFormat(), '2025-12-31');
    });
  });
}
