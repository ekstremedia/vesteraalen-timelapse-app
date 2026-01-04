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

### Git Commit/Push Policy - CRITICAL
**NEVER COMMIT OR PUSH UNLESS THE USER EXPLICITLY TELLS YOU TO.**

This is a hard rule with no exceptions:
- Do NOT commit changes automatically
- Do NOT push after committing
- Do NOT commit/push "for testing"
- Do NOT commit/push as part of a workflow
- ONLY commit when the user explicitly says "commit"
- ONLY push when the user explicitly says "push"
- When in doubt, ASK before committing or pushing

Make changes to files, but wait for explicit permission to commit and push.

### Code Quality Check - REQUIRED
**After making any Dart/Flutter code changes, ALWAYS run `flutter analyze` before summarizing.**

- If there are warnings or errors, fix them immediately
- Only report changes as "ready" when analyze passes with no issues
- This catches lint issues that `dart format` doesn't fix

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
│   ├── constants/app_constants.dart    # Centralized constants (spacing, dimensions, etc.)
│   ├── theme/app_theme.dart            # Dark/light theme
│   ├── providers/
│   │   ├── theme_provider.dart         # Theme state
│   │   ├── locale_provider.dart        # Locale state
│   │   ├── websocket_provider.dart     # WebSocket connection state
│   │   └── shared_preferences_provider.dart
│   ├── services/
│   │   ├── api_client.dart             # Dio HTTP client
│   │   ├── cache_service.dart          # In-memory cache
│   │   └── websocket_service.dart      # Laravel Reverb WebSocket client
│   └── widgets/
│       └── image_preload_mixin.dart    # Seamless image preloading mixin
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

### WebSocket (Laravel Reverb)

```dart
// WebSocket connects to Reverb server using Pusher protocol
// Subscribes to 'cameras' channel for real-time image updates

// Event received from Laravel:
// Channel: cameras
// Event: .image.updated
// Payload: {camera_id, camera_name, image_url, updated_at}
```

**Environment Variables:**
```bash
WEBSOCKET_ENABLED=true
REVERB_HOST=nesthus.no
REVERB_PORT=8080
REVERB_SCHEME=https
REVERB_APP_KEY=your-app-key
```

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

### iOS (Xcode Cloud - Recommended)

**Trigger:** Push to `main` branch (automatic)

```bash
git push origin main
# → Xcode Cloud clones repo
# → Runs ios/ci_scripts/ci_post_clone.sh (installs Flutter)
# → Builds and archives iOS app
# → Uploads to TestFlight automatically
```

**Why Xcode Cloud over GitHub Actions:**
- **Free:** 25 compute hours/month included
- **Cost:** GitHub macOS runners cost $0.062/min (10x more than Linux)
- **Signing:** Apple handles code signing automatically

**Setup:** See `FLUTTER_APP_HOWTO.md` → "Xcode Cloud Setup"

**Key Files:**
- `ios/ci_scripts/ci_post_clone.sh` - Installs Flutter, builds iOS
- `ios/ExportOptions.plist` - Signing configuration

**Environment Variables (set in App Store Connect → Xcode Cloud):**
- `API_BASE_URL` - API endpoint
- `REVERB_APP_KEY` - WebSocket key (if using)

**Manual Build:** App Store Connect → Xcode Cloud → Start Build

### iOS (GitHub Actions - Legacy/Disabled)

The GitHub Actions iOS workflow has been disabled (renamed to `.disabled`) to save costs. Reference file: `.github/workflows/ios-deploy.yml.disabled`

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
| Settings page | ✅ Done | Theme + language + about + WebSocket status |
| WebSocket real-time updates | ✅ Done | Laravel Reverb integration |
| Silent image refresh | ✅ Done | No loading indicators on background refresh |
| Slitscan images | ✅ Done | Shows slitscan alongside keogram |
| CI/CD Android | ✅ Done | GitHub Actions + Firebase App Distribution |
| CI/CD iOS | ✅ Done | Xcode Cloud + App Store Connect (free) |
| Google Play Store | ⏳ Waiting | ID verification pending |
| Apple App Store | ✅ Submitted | Version 1.7.0 submitted for review |

---

## Recent Changes

### 2026-01-04
- **Slitscan image support**: Added `slitscanUrl` field to TimelapseVideo model
- **Compact camera card layout**: Redesigned to fit 2 cards on phone screen
  - Camera name/info and button now in single row
  - Reduced grid padding and spacing
  - Adjusted aspect ratios for different screen sizes
- **Xcode Cloud migration**: Moved iOS builds from GitHub Actions to Xcode Cloud
  - Created `ios/ci_scripts/ci_post_clone.sh` for Flutter setup
  - Disabled GitHub Actions iOS workflow (saves ~$11/month in macOS runner costs)
  - Changed distribution from TestFlight to App Store Connect (enables App Store submission)
- **Version alignment**: Bumped to 1.7.0 to align Android and iOS build numbers
- **Apple App Store**: Submitted version 1.7.0 for review
  - Screenshots captured on iPhone 17 Pro Max (1284x2778) and iPad Pro 13" (2048x2732)
  - App icon (1024x1024) bundled in binary via flutter_launcher_icons
- **Google Play Store**: Started setup process, ID verification pending

### 2026-01-02 (continued)
- **Comprehensive code cleanup and optimization**:
  - Created `lib/core/constants/app_constants.dart` with centralized constants:
    - `AppSpacing`: xs, sm, md, lg, xl, xxl spacing values
    - `AppDimensions`: icon sizes, breakpoints, border radii
    - `ApiEndpoints`: API path templates
    - `CacheKeys`: Cache key patterns
    - `AppDurations`: Timeouts and animation durations
    - `AppStatusColors`: Status indicator colors
  - Created `lib/core/widgets/image_preload_mixin.dart` for seamless image transitions
  - Merged duplicate navigation methods in `date_navigation.dart`
  - Consolidated date formatting to use `toApiFormat()` extension consistently
  - Added dartdoc comments to all public classes and complex methods
  - Updated all UI files to use centralized constants instead of magic numbers
  - Added API response validation before type casting
- **Image update timestamp**: Shows relative time since last image update on camera cards
- **Green flash animation**: Clock icon flashes green when camera image updates
- **Seamless image transitions**: Preloads new images before displaying (no flickering)
- **Default language**: Set Nynorsk (nn) as default language
- **Minimum iOS version**: Set to iOS 15.0
- Version bumped to 1.5.0

### 2026-01-02
- **WebSocket real-time updates**: Integrated with Laravel Reverb
  - Created `WebSocketService` using Pusher protocol
  - Subscribes to `cameras` channel for `.image.updated` events
  - Auto-reconnect with exponential backoff
  - Ping/pong keepalive
- **App lifecycle management**: Added `WidgetsBindingObserver`
  - Reconnects WebSocket on app resume
  - Stops polling on app pause
  - Silent data refresh on foreground
- **Silent image updates**: No loading indicators during background refresh
  - Zero fade duration for instant image transitions
  - Empty placeholder instead of spinner
- **WebSocket status in Settings**: Shows connection state with colored indicator
- **CI/CD fixes**:
  - Fixed Android deploy to trigger on push to main (was only on tags)
  - Added WebSocket environment variables to both workflows
  - Added `REVERB_APP_KEY` secret
- **iOS encryption exemption**: Added `ITSAppUsesNonExemptEncryption` to Info.plist
- Version bumped to 1.3.0

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
