import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vesteraalen_timelapse/core/constants/app_constants.dart';
import 'package:vesteraalen_timelapse/core/providers/locale_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/date_picker_provider.dart';
import 'package:vesteraalen_timelapse/features/cameras/providers/timelapse_provider.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

/// Navigation bar for selecting timelapse dates.
///
/// Provides previous/next day navigation, date picker access, and today button.
/// Automatically disables navigation buttons when at date boundaries.
class DateNavigationBar extends ConsumerWidget {
  const DateNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final timelapseState = ref.watch(timelapseProvider);
    final navigation = timelapseState.detail?.navigation;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousDay,
            onPressed: navigation?.hasPrevious == true
                ? () => _navigateToDate(ref, navigation!.previousDate!)
                : null,
          ),

          // Date display with picker
          Expanded(
            child: InkWell(
              onTap: () => _showDatePicker(context, ref, selectedDate),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateLabel(context, selectedDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatFullDate(context, selectedDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextDay,
            onPressed: navigation?.hasNext == true
                ? () => _navigateToDate(ref, navigation!.nextDate!)
                : null,
          ),

          // Today button
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: l10n.goToToday,
            onPressed: selectedDate.isToday ? null : () => _goToToday(ref),
          ),
        ],
      ),
    );
  }

  /// Formats a date as a short, context-aware label.
  ///
  /// Returns "Today" or "Yesterday" for those dates, day name for dates
  /// within the past week, or abbreviated month/day for older dates.
  String _formatDateLabel(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    if (date.isToday) return l10n.today;
    if (date.isYesterday) return l10n.yesterday;

    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference < 7) {
      final locale = LocaleUtils.getIntlLocale(context);
      return DateFormat('EEEE', locale).format(date);
    }

    return DateFormat.MMMd(LocaleUtils.getIntlLocale(context)).format(date);
  }

  /// Formats a date as a full, locale-aware string (e.g., "January 1, 2026").
  String _formatFullDate(BuildContext context, DateTime date) {
    final locale = LocaleUtils.getIntlLocale(context);
    return DateFormat.yMMMMd(locale).format(date);
  }

  /// Navigates to the specified date.
  void _navigateToDate(WidgetRef ref, DateTime date) {
    ref.read(selectedDateProvider.notifier).state = date;
  }

  /// Navigates to today's date.
  void _goToToday(WidgetRef ref) {
    ref.read(selectedDateProvider.notifier).state = DateTime.now().dateOnly;
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final l10n = AppLocalizations.of(context);
    final availableDates = ref.read(availableDatesProvider);

    final firstDate = availableDates.maybeWhen(
      data: (dates) => dates.isNotEmpty ? dates.last : DateTime(2020),
      orElse: () => DateTime(2020),
    );

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: firstDate,
      lastDate: DateTime.now(),
      helpText: l10n.selectDate,
      selectableDayPredicate: (date) {
        return availableDates.maybeWhen(
          data: (dates) {
            // Allow today even if not in available dates
            if (date.isToday) return true;

            return dates.any(
              (d) =>
                  d.year == date.year &&
                  d.month == date.month &&
                  d.day == date.day,
            );
          },
          orElse: () => true,
        );
      },
    );

    if (picked != null) {
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }
}
