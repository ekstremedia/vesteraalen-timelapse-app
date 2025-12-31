# Vesteraalen Timelapse App - Claude Memory & Guidelines

## Project Overview

**Vesteraalen Timelapse** is a Flutter mobile app displaying live camera images and timelapse videos from Northern Norway (ekstremedia.no).

- **App Name:** Vesteraalen Timelapse
- **Bundle ID:** no.ekstremedia.timelapse
- **Backend:** Laravel 12 at `/www/nesthus_2026/`
- **Distribution:** Firebase App Distribution + Google Play + App Store

## Documentation

| Document | Purpose |
|----------|---------|
| **`FLUTTER_APP_HOWTO.md`** | Step-by-step guide for creating Flutter apps (Firebase, stores, CI/CD) |
| **`logs/YYYY-MM-DD.md`** | Daily development logs |
| **`~/.claude/plans/*.md`** | Feature implementation plans |

---

## Memory Rules

### Daily Development Logs
**IMPORTANT**: Create a new log file for every development day:
- Location: `/www/vesteraalen_timelapse/logs/YYYY-MM-DD.md`
- Content: Features implemented, bugs fixed, architecture decisions

### FLUTTER_APP_HOWTO.md Maintenance
**IMPORTANT**: When setting up Firebase, app stores, or CI/CD:
1. Document every step in `FLUTTER_APP_HOWTO.md`
2. Include screenshots paths if relevant
3. Note any gotchas or issues encountered

---

## Quick References

### Running the App

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run with specific device
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

### Building

```bash
# Android debug APK
flutter build apk --debug

# Android release APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

### Testing

```bash
flutter test              # Run all tests
flutter analyze           # Code quality check
dart format .             # Format code
```

---

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── core/
│   ├── config/env_config.dart          # Environment configuration
│   ├── theme/app_theme.dart            # Dark/light theme
│   ├── providers/
│   │   ├── theme_provider.dart         # Theme state
│   │   ├── locale_provider.dart        # Locale state
│   │   └── shared_preferences_provider.dart
│   ├── services/
│   │   ├── api_client.dart             # Dio HTTP client
│   │   └── cache_service.dart          # In-memory cache
│   └── widgets/                        # Shared widgets
├── features/
│   ├── cameras/
│   │   ├── models/
│   │   │   ├── camera.dart             # Camera data model
│   │   │   └── timelapse_video.dart    # Video data model
│   │   ├── providers/
│   │   │   ├── cameras_provider.dart   # Cameras list + polling
│   │   │   ├── selected_camera_provider.dart
│   │   │   ├── timelapse_provider.dart
│   │   │   └── date_picker_provider.dart
│   │   ├── services/camera_service.dart
│   │   ├── pages/
│   │   │   ├── cameras_list_page.dart  # Home page
│   │   │   └── camera_detail_page.dart # Timelapse viewer
│   │   └── widgets/
│   └── settings/
│       ├── pages/settings_page.dart
│       └── providers/settings_provider.dart
└── l10n/app_localizations.dart         # nb/nn/en translations
```

---

## Code Patterns

### State Management (Riverpod)

```dart
// NotifierProvider pattern
final camerasProvider = NotifierProvider<CamerasNotifier, CamerasState>(
  CamerasNotifier.new,
);

class CamerasNotifier extends Notifier<CamerasState> {
  @override
  CamerasState build() {
    // Initial state + setup
    return const CamerasState(isLoading: true);
  }

  Future<void> loadCameras() async {
    // Business logic
  }
}
```

### Theming

```dart
// Dark/light theme following website aesthetic
return MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ref.watch(themeModeProvider),
);
```

### Localization (nb/nn/en)

```dart
// Usage in widgets
final l10n = AppLocalizations.of(context);
Text(l10n.cameras);

// Date formatting with locale
DateFormat.yMMMd(LocaleUtils.getIntlLocale(context)).format(date);
```

### Caching

| Data | TTL | Reason |
|------|-----|--------|
| Cameras list | 30s | Current images update frequently |
| Today's timelapse | 30s | May still be processing |
| Historical timelapse | 5 min | Won't change |
| Available dates | 1 hour | Changes once daily |

---

## Backend API (Laravel)

### Endpoints

```
GET /api/app/cameras           # List cameras with current images
GET /api/app/timelapse/{id}/dates  # Available dates for camera
GET /api/app/timelapse/{id}/{date} # Timelapse detail
```

### Controllers Location

- `/www/nesthus_2026/app/Http/Controllers/Api/AppCamerasController.php`
- `/www/nesthus_2026/app/Http/Controllers/Api/AppTimelapseController.php`

---

## CI/CD

### Android (GitHub Actions)

**Trigger:** Push to `main` branch

```bash
git push origin main
# → Builds APK
# → Auto-increments version
# → Uploads to Firebase App Distribution
```

**Workflow:** `.github/workflows/android-deploy.yml`

### iOS (Xcode Cloud)

**Trigger:** Push to `main` branch

```bash
git push origin main
# → Xcode Cloud builds IPA
# → Uploads to TestFlight
```

**Scripts:** `ios/ci_scripts/ci_post_clone.sh`, `ci_pre_xcodebuild.sh`

### Version Management

```yaml
# pubspec.yaml
version: 1.0.0+1
#        ─┬──  ─┬
#         │     └─ Build number (auto-incremented by CI)
#         └─────── Version name (manually updated)
```

---

## Environment Configuration

| File | Purpose | Committed |
|------|---------|-----------|
| `.env` | Local development | No (gitignored) |
| `.env.example` | Template | Yes |
| `.env.production` | Production values | Yes |

---

## Common Issues

| Issue | Solution |
|-------|----------|
| Images not loading | Check API_BASE_URL in .env |
| Build fails on CI | Ensure .env.example exists |
| iOS build fails | Run `flutter precache --ios` before `pod install` |
| Android signing mismatch | Uninstall app before installing from Firebase |

---

## Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| Camera list (home) | 🔲 Pending | Grid of camera thumbnails |
| Camera detail | 🔲 Pending | Timelapse viewer + images |
| Date navigation | 🔲 Pending | Previous/next/today/picker |
| YouTube player | 🔲 Pending | Embedded timelapse playback |
| Dark/light theme | 🔲 Pending | Matches website |
| Localization (nb/nn/en) | 🔲 Pending | 3 languages |
| Settings page | 🔲 Pending | Theme + language selection |
| CI/CD Android | 🔲 Pending | GitHub Actions |
| CI/CD iOS | 🔲 Pending | Xcode Cloud |

---

## Recent Changes

### 2025-12-31
- Created Flutter project with `flutter create --org no.ekstremedia`
- Configured pubspec.yaml with dependencies
- Set up project directory structure
- Created CLAUDE.md documentation
- Created FLUTTER_APP_HOWTO.md guide
- Created initial development log
