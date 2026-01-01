import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vesteraalen_timelapse/core/providers/theme_provider.dart';
import 'package:vesteraalen_timelapse/core/providers/locale_provider.dart';
import 'package:vesteraalen_timelapse/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings page for theme and language selection.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(context, l10n.appearance),
          _buildThemeTile(context, ref, l10n, themeMode),
          const Divider(),

          // Language Section
          _buildLanguageTile(context, ref, l10n, locale),
          const Divider(),

          // About Section
          _buildSectionHeader(context, l10n.about),
          _buildMadeByTile(context, l10n),
          _buildCameraHardwareTile(context, l10n),
          _buildOpenSourceTile(context, l10n),
          const Divider(),
          _buildVersionTile(context, l10n),
          _buildWebsiteTile(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeMode themeMode,
  ) {
    return ListTile(
      leading: Icon(
        themeMode == ThemeMode.dark
            ? Icons.dark_mode
            : themeMode == ThemeMode.light
            ? Icons.light_mode
            : Icons.brightness_auto,
      ),
      title: Text(l10n.theme),
      subtitle: Text(_getThemeLabel(l10n, themeMode)),
      onTap: () => _showThemeDialog(context, ref, l10n, themeMode),
    );
  }

  String _getThemeLabel(AppLocalizations l10n, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeMode currentMode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              ref,
              l10n.themeSystem,
              ThemeMode.system,
              currentMode,
              Icons.brightness_auto,
            ),
            _buildThemeOption(
              context,
              ref,
              l10n.themeLight,
              ThemeMode.light,
              currentMode,
              Icons.light_mode,
            ),
            _buildThemeOption(
              context,
              ref,
              l10n.themeDark,
              ThemeMode.dark,
              currentMode,
              Icons.dark_mode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    ThemeMode mode,
    ThemeMode currentMode,
    IconData icon,
  ) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale locale,
  ) {
    final localeNotifier = ref.read(localeProvider.notifier);
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(localeNotifier.getLocaleName(locale, l10n)),
      onTap: () => _showLanguageDialog(context, ref, l10n, locale),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale currentLocale,
  ) {
    final localeNotifier = ref.read(localeProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocalizations.supportedLocales.map((locale) {
            final isSelected =
                locale.languageCode == currentLocale.languageCode;
            return ListTile(
              title: Text(
                localeNotifier.getLocaleName(locale, l10n),
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMadeByTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(l10n.madeBy),
      subtitle: Text(l10n.madeByName),
      trailing: const Icon(Icons.email_outlined, size: 18),
      onTap: () => _launchUrl('mailto:terjen@gmail.com'),
    );
  }

  Widget _buildCameraHardwareTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.camera_alt_outlined),
      title: Text(l10n.cameraHardware),
      subtitle: Text(l10n.cameraHardwareDesc),
    );
  }

  Widget _buildOpenSourceTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.code),
      title: Text(l10n.openSource),
      subtitle: Text(l10n.openSourceDesc),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => _launchUrl('https://github.com/ekstremedia/raspilapse'),
    );
  }

  Widget _buildVersionTile(BuildContext context, AppLocalizations l10n) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '...';
        final buildNumber = snapshot.data?.buildNumber ?? '';
        final versionText = buildNumber.isNotEmpty
            ? '$version ($buildNumber)'
            : version;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.version),
          subtitle: Text(versionText),
        );
      },
    );
  }

  Widget _buildWebsiteTile(BuildContext context, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.open_in_new),
      title: Text(l10n.website),
      subtitle: const Text('ekstremedia.no'),
      onTap: () => _launchUrl('https://ekstremedia.no'),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
