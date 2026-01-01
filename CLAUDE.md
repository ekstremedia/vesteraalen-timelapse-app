# Vesterålen Timelapse App - Claude Memory & Guidelines

## Project Overview

**Vesterålen Timelapse** is a Flutter mobile app displaying live camera images and timelapse videos from Northern Norway (ekstremedia.no).

- **App Name:** Vesterålen Timelapse
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
- Location: `/www/Vesterålen_timelapse/logs/YYYY-MM-DD.md`
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

### iOS (GitHub Actions)

**Trigger:** Push to `main` branch

```bash
git push origin main
# → Builds iOS app (no codesign)
# → Archives and exports IPA with signing
# → Uploads to TestFlight
```

**Workflow:** `.github/workflows/ios-deploy.yml`
**Signing Config:** `ios/ExportOptions.plist`

**Required Secrets:**
- `IOS_CERTIFICATE_BASE64` - Distribution certificate
- `IOS_CERTIFICATE_PASSWORD` - Certificate password
- `IOS_PROVISIONING_PROFILE_BASE64` - App Store profile
- `APP_STORE_CONNECT_ISSUER_ID` - API authentication
- `APP_STORE_CONNECT_KEY_ID` - API authentication
- `APP_STORE_CONNECT_PRIVATE_KEY` - .p8 file contents

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
| iOS provisioning profile applies to Pods | Use `CODE_SIGNING_REQUIRED=NO` during archive, sign during export |
| iOS base64 decode fails | Use `echo -n` with env variable, not direct secret interpolation |
| iOS export requires account auth | Use `app-store` method, not `app-store-connect` |
| IPA not found at expected path | Find IPA dynamically with `find` command |

---

## Feature Status

| Feature | Status | Notes |
|---------|--------|-------|
| Camera list (home) | ✅ Done | Grid of camera thumbnails |
| Camera detail | ✅ Done | Timelapse viewer + images |
| Date navigation | ✅ Done | Previous/next/today/picker |
| YouTube player | ✅ Done | Embedded timelapse playback |
| Dark/light theme | ✅ Done | Matches website |
| Localization (nb/nn/en) | ✅ Done | 3 languages |
| Settings page | ✅ Done | Theme + language + about section |
| CI/CD Android | ✅ Done | GitHub Actions + Firebase App Distribution |
| CI/CD iOS | 🔄 In Progress | GitHub Actions + TestFlight (upload pending) |
| Google Play Store | 🔲 Pending | Internal testing track |
| Apple App Store | 🔄 In Progress | App created, TestFlight pending |

---

## Recent Changes

### 2026-01-01
- Set up Firebase project (Android + iOS apps)
- Created Android signing keystore
- Configured GitHub secrets for CI/CD
- Fixed Flutter/Dart version compatibility (3.38.5)
- Fixed intl package conflicts
- Added pre-commit hook for auto-formatting
- Updated all workflows with concurrency settings
- **Enhanced YouTube player**: Replaced thumbnail-with-link with embedded `YoutubePlayer`
  - Created `_EmbeddedYoutubePlayer` StatefulWidget with proper lifecycle management
  - Full playback controls within the app
  - Option to open in external YouTube app
- Updated `youtube_player_flutter` to ^9.1.3, `flutter_dotenv` to ^6.0.0
- **Dark theme redesign**: Updated to match website purple/navy aesthetic
  - Primary color changed from teal to purple (`#9D4EDD`)
  - Background changed to navy (`#0D0D1A`)
  - Cards use purple-tinted surfaces
  - Added accent colors for green (online status) and secondary purple
- **Default to dark mode**: New users now start in dark mode
- **UI/UX improvements**:
  - Reduced FilledButton border radius (6px instead of ~20px)
  - Added "today's timelapse not ready" info message with "See yesterday's video" button
  - Changed fullscreen image backgrounds to match theme
  - Polling interval changed from 30s to 60s
- **Settings page enhancements**:
  - Added "Made by Terje Nesthus" with email link (terjen@gmail.com)
  - Added "Camera Hardware" info (Raspberry Pi + Camera Module 3)
  - Added "Open Source" link to github.com/ekstremedia/raspilapse
  - Version now shows dynamic version + build number via `package_info_plus`
- **Test coverage**: Increased from 43 to 88 tests
  - New localization tests (all 3 languages)
  - New cache service tests
  - Additional theme color tests
- **iOS App Store Setup**:
  - Created Apple Distribution certificate via Keychain Access
  - Created App ID: `no.ekstremedia.vesteraalenTimelapse`
  - Created App Store provisioning profile: `Vesteraalen Timelapse AppStore`
  - Team ID: `5Q78RA8DA4`
  - Created app in App Store Connect
  - Generated App Store Connect API key for CI/CD
  - Configured GitHub Actions workflow for iOS deployment
  - Created `ios/ExportOptions.plist` for code signing
  - Added all iOS-related secrets to GitHub

### 2025-12-31
- Created Flutter project with `flutter create --org no.ekstremedia`
- Implemented all core features (cameras, timelapse, settings)
- Created 42 Flutter tests, 13 Laravel tests
- Set up CI/CD workflows
- Created documentation
