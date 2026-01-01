import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    group('English (en)', () {
      late AppLocalizations l10n;

      setUp(() {
        l10n = AppLocalizations(const Locale('en'));
      });

      test('appTitle returns correct value', () {
        expect(l10n.appTitle, 'Vesterålen Timelapse');
      });

      test('cameras returns correct value', () {
        expect(l10n.cameras, 'Cameras');
      });

      test('settings returns correct value', () {
        expect(l10n.settings, 'Settings');
      });

      test('today returns correct value', () {
        expect(l10n.today, 'Today');
      });

      test('yesterday returns correct value', () {
        expect(l10n.yesterday, 'Yesterday');
      });

      test('seeYesterdaysVideo returns correct value', () {
        expect(l10n.seeYesterdaysVideo, "See yesterday's video");
      });

      test('todayTimelapseNotReady returns correct value', () {
        expect(l10n.todayTimelapseNotReady, contains('not ready yet'));
      });

      test('videoCount returns singular for 1', () {
        expect(l10n.videoCount(1), '1 video');
      });

      test('videoCount returns plural for multiple', () {
        expect(l10n.videoCount(5), '5 videos');
      });

      test('madeByName returns correct value', () {
        expect(l10n.madeByName, 'Terje Nesthus');
      });

      test('openSource returns correct value', () {
        expect(l10n.openSource, 'Open Source');
      });
    });

    group('Norwegian Bokmål (nb)', () {
      late AppLocalizations l10n;

      setUp(() {
        l10n = AppLocalizations(const Locale('nb'));
      });

      test('cameras returns correct value', () {
        expect(l10n.cameras, 'Kameraer');
      });

      test('settings returns correct value', () {
        expect(l10n.settings, 'Innstillinger');
      });

      test('today returns correct value', () {
        expect(l10n.today, 'I dag');
      });

      test('yesterday returns correct value', () {
        expect(l10n.yesterday, 'I går');
      });

      test('seeYesterdaysVideo returns correct value', () {
        expect(l10n.seeYesterdaysVideo, 'Se gårsdagens video');
      });

      test('openSource returns correct value', () {
        expect(l10n.openSource, 'Åpen kildekode');
      });
    });

    group('Norwegian Nynorsk (nn)', () {
      late AppLocalizations l10n;

      setUp(() {
        l10n = AppLocalizations(const Locale('nn'));
      });

      test('cameras returns correct value', () {
        expect(l10n.cameras, 'Kamera');
      });

      test('settings returns correct value', () {
        expect(l10n.settings, 'Innstillingar');
      });

      test('seeYesterdaysVideo returns correct value', () {
        expect(l10n.seeYesterdaysVideo, 'Sjå gårsdagens video');
      });

      test('openSource returns correct value', () {
        expect(l10n.openSource, 'Open kjeldekode');
      });
    });

    group('formatRelativeTime', () {
      late AppLocalizations l10n;

      setUp(() {
        l10n = AppLocalizations(const Locale('en'));
      });

      test('returns just now for recent times', () {
        final recent = DateTime.now().subtract(const Duration(seconds: 30));
        expect(l10n.formatRelativeTime(recent), 'just now');
      });

      test('returns minutes ago for times within an hour', () {
        final tenMinutesAgo = DateTime.now().subtract(
          const Duration(minutes: 10),
        );
        expect(l10n.formatRelativeTime(tenMinutesAgo), '10 min ago');
      });

      test('returns hours ago for times within a day', () {
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        expect(l10n.formatRelativeTime(twoHoursAgo), '2 h ago');
      });
    });

    group('supportedLocales', () {
      test('contains English', () {
        expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      });

      test('contains Norwegian Bokmål', () {
        expect(AppLocalizations.supportedLocales, contains(const Locale('nb')));
      });

      test('contains Norwegian Nynorsk', () {
        expect(AppLocalizations.supportedLocales, contains(const Locale('nn')));
      });

      test('has exactly 3 supported locales', () {
        expect(AppLocalizations.supportedLocales.length, 3);
      });
    });
  });
}
