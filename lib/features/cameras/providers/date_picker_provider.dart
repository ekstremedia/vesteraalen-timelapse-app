import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the currently selected date.
/// Defaults to yesterday (latest completed timelapse).
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  // Default to yesterday since today's timelapse may not be complete
  return DateTime(now.year, now.month, now.day - 1);
});

/// Provider for the date picker visibility state.
final datePickerVisibleProvider = StateProvider<bool>((ref) => false);

/// Extension methods for date operations.
extension DateTimeExtensions on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this date is in the future.
  bool get isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDate = DateTime(year, month, day);
    return thisDate.isAfter(today);
  }

  /// Returns a date-only DateTime (no time component).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Formats date as YYYY-MM-DD for API calls.
  String toApiFormat() {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }
}
