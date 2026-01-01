# Next Steps for Vesterålen Timelapse App

## Current Status (2025-12-31)

- **Flutter Tests:** 42 passing
- **Laravel Tests:** 13 passing (run with `docker compose exec ekstremedia php artisan test`)
- **Flutter Analyze:** No issues
- **CI/CD Workflows:** Created and ready

---

## Step 1: Set up Firebase Project

1. Go to https://console.firebase.google.com
2. Create new project called "Vesterålen Timelapse"
3. Add Android app:
   - Package name: `no.ekstremedia.vesteraalen_timelapse`
   - Download `google-services.json`
   - Place in `android/app/google-services.json`
4. Add iOS app:
   - Bundle ID: `no.ekstremedia.timelapse`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`
5. Enable Firebase App Distribution in the console

---

## Step 2: Create Android Signing Key

```bash
cd /www/vesteraalen_timelapse/android/app

keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Remember the passwords you set!

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## Step 3: Configure GitHub Secrets

Go to your GitHub repo → Settings → Secrets and variables → Actions

**Required Secrets:**

| Secret Name | Value |
|-------------|-------|
| `API_BASE_URL` | `https://ekstremedia.no/api/app` (or your API URL) |
| `FIREBASE_APP_ID_ANDROID` | From Firebase Console → Project Settings → Your apps |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase Console → Project Settings → Service accounts → Generate new private key (paste entire JSON) |
| `ANDROID_KEYSTORE_BASE64` | Run: `base64 -w 0 android/app/upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Your keystore password |
| `ANDROID_KEY_PASSWORD` | Your key password |
| `ANDROID_KEY_ALIAS` | `upload` |

**For iOS (later):**
- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_CODE_SIGN_IDENTITY`
- `IOS_PROVISIONING_PROFILE_NAME`
- `IOS_TEAM_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

---

## Step 4: Test on Physical Device

```bash
cd /www/vesteraalen_timelapse

# List connected devices
flutter devices

# Run on connected device
flutter run

# Or build APK and install manually
flutter build apk --debug
# APK will be at: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Step 5: Create First Release

```bash
cd /www/vesteraalen_timelapse

# Initialize git if not done
git init
git add .
git commit -m "Initial commit: Vesterålen Flutter app"

# Add remote (replace with your repo URL)
git remote add origin git@github.com:YOUR_USERNAME/vesteraalen_timelapse.git
git push -u origin main

# Create release tag (triggers deployment workflows)
git tag v1.0.0
git push origin v1.0.0
```

---

## Quick Commands Reference

```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Run app
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Run Laravel backend tests
docker compose exec ekstremedia php artisan test
```

---

## Project Locations

| What | Path |
|------|------|
| Flutter App | `/www/vesteraalen_timelapse/` |
| Laravel Backend | `/www/nesthus_2026/` |
| API Routes | `/www/nesthus_2026/routes/api.php` |
| App Logo | `/www/vesteraalen_timelapse/images/logo.svg` |
| Dev Log | `/www/vesteraalen_timelapse/logs/2025-12-31.md` |

---

## Files Created

### Flutter App Structure
```
lib/
├── main.dart
├── core/
│   ├── config/env_config.dart
│   ├── theme/app_theme.dart
│   ├── providers/theme_provider.dart, locale_provider.dart
│   └── services/api_client.dart, cache_service.dart
├── features/
│   ├── cameras/
│   │   ├── models/camera.dart, timelapse_video.dart
│   │   ├── providers/cameras_provider.dart, selected_camera_provider.dart,
│   │   │            timelapse_provider.dart, date_picker_provider.dart
│   │   ├── services/camera_service.dart
│   │   ├── pages/cameras_list_page.dart, camera_detail_page.dart
│   │   └── widgets/camera_card.dart, date_navigation.dart
│   └── settings/pages/settings_page.dart
└── l10n/app_localizations.dart

.github/workflows/
├── flutter.yml          # CI: analyze, test, build
├── android-deploy.yml   # Deploy to Firebase App Distribution
└── ios-deploy.yml       # Deploy to TestFlight
```

### Laravel API Endpoints
- `GET /api/app/cameras` - List all cameras
- `GET /api/app/timelapse/{cameraId}/dates` - Available dates for camera
- `GET /api/app/timelapse/{cameraId}/{date?}` - Timelapse detail
