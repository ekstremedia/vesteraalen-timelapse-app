# Flutter App Creation Guide: From Zero to App Stores

A comprehensive step-by-step guide for creating Flutter apps and publishing to Google Play Store and Apple App Store. This document is updated as we build the app.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Local Development Setup](#2-local-development-setup)
3. [Creating the Flutter Project](#3-creating-the-flutter-project)
4. [Project Configuration](#4-project-configuration)
5. [Firebase Setup](#5-firebase-setup)
6. [Android Configuration](#6-android-configuration)
7. [iOS Configuration](#7-ios-configuration)
8. [CI/CD Setup](#8-cicd-setup)
9. [Google Play Store Setup](#9-google-play-store-setup)
10. [Apple App Store Setup](#10-apple-app-store-setup)
11. [Release Checklist](#11-release-checklist)

---

## 1. Prerequisites

### Required Software

| Software | Version | Download |
|----------|---------|----------|
| Flutter SDK | 3.x+ | https://flutter.dev/docs/get-started/install |
| Android Studio | Latest | https://developer.android.com/studio |
| Xcode (Mac only) | Latest | App Store |
| VS Code or IntelliJ | Latest | Optional IDE |
| Git | Latest | https://git-scm.com |
| Firebase CLI | Latest | `npm install -g firebase-tools` |

### Required Accounts

| Account | Purpose | URL |
|---------|---------|-----|
| Google Developer | Play Store ($25 one-time) | https://play.google.com/console |
| Apple Developer | App Store ($99/year) | https://developer.apple.com |
| Firebase | Analytics, Distribution | https://console.firebase.google.com |
| GitHub | CI/CD, Source Control | https://github.com |

### Verify Installation

```bash
# Check Flutter
flutter doctor -v

# Should show:
# [✓] Flutter (Channel stable, 3.x.x)
# [✓] Android toolchain
# [✓] Xcode (Mac only)
# [✓] Chrome
# [✓] Android Studio
```

---

## 2. Local Development Setup

### Install Flutter SDK

```bash
# macOS (using Homebrew)
brew install flutter

# Or manually
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

### Configure Android Studio

1. Open Android Studio
2. **Plugins** → Install "Flutter" plugin
3. **Plugins** → Install "Dart" plugin
4. Restart Android Studio
5. **SDK Manager** → Install Android SDK (API 34+)
6. **AVD Manager** → Create Android Virtual Device

### Configure Xcode (Mac only)

```bash
# Install Xcode command line tools
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept

# Install CocoaPods
sudo gem install cocoapods
```

### Set Up Firebase CLI

```bash
# Install
npm install -g firebase-tools

# Login
firebase login

# Verify
firebase projects:list
```

---

## 3. Creating the Flutter Project

### Create New Project

```bash
# Navigate to projects directory
cd /www

# Create project with organization
flutter create --org no.ekstremedia vesteraalen_timelapse

# Or create in existing directory
cd vesteraalen_timelapse
flutter create --org no.ekstremedia .

# Verify
flutter run
```

### Project Naming Conventions

| Field | Format | Example |
|-------|--------|---------|
| Project name | lowercase_with_underscores | `vesteraalen_timelapse` |
| Organization | reverse domain | `no.ekstremedia` |
| Bundle ID (iOS) | org.name | `no.ekstremedia.timelapse` |
| Application ID (Android) | org.name | `no.ekstremedia.vesteraalen_timelapse` |

---

## 4. Project Configuration

### pubspec.yaml Setup

```yaml
name: vesteraalen_timelapse
description: "App description"
publish_to: 'none'
version: 1.0.0+1  # version+buildNumber

environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter
  # Add your dependencies here

flutter:
  uses-material-design: true
  assets:
    - .env
    - .env.example
```

### Environment Files

Create `.env.example` (committed):
```
API_BASE_URL=https://your-api.com
```

Create `.env` (gitignored):
```
API_BASE_URL=https://your-api.com
```

### .gitignore Additions

```gitignore
# Environment
.env

# Signing keys
*.keystore
*.jks
key.properties
android/app/*.jks

# iOS
ios/Runner/GoogleService-Info.plist

# Android
android/app/google-services.json

# Firebase configs in root
/GoogleService-Info.plist
/google-services.json
/*-firebase-adminsdk-*.json

# Secrets documentation
keys.md
```

### Pre-commit Hook (Auto-format)

Create `scripts/setup-hooks.sh`:
```bash
#!/bin/sh
HOOK_DIR=".git/hooks"

cat > "$HOOK_DIR/pre-commit" << 'EOF'
#!/bin/sh
echo "Running dart format..."
dart format .
git add -u
echo "Dart formatting complete."
EOF

chmod +x "$HOOK_DIR/pre-commit"
echo "Git hooks installed!"
```

Run after cloning:
```bash
chmod +x scripts/setup-hooks.sh
./scripts/setup-hooks.sh
```

---

## 5. Firebase Setup

### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Enter project name: `vesteraalen-timelapse`
4. Enable/disable Google Analytics (optional)
5. Click **"Create project"**

### Add Android App to Firebase

1. In Firebase Console, click **"Add app"** → Android
2. Enter package name: `no.ekstremedia.vesteraalen_timelapse`
3. Enter app nickname: `Vesterålen Android`
4. Get SHA-1 fingerprint:
   ```bash
   # Debug key
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android | grep SHA1

   # Release key (after creating it)
   keytool -list -v -keystore android/app/upload-keystore.jks -alias upload | grep SHA1
   ```
5. Download `google-services.json`
6. Place in `android/app/google-services.json`

### Add iOS App to Firebase

1. In Firebase Console, click **"Add app"** → iOS
2. Enter bundle ID: `no.ekstremedia.timelapse`
3. Enter app nickname: `Vesterålen iOS`
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/GoogleService-Info.plist`
6. Add to Xcode project (drag into Runner folder, check "Copy items")

### Set Up Firebase App Distribution

1. In Firebase Console → **App Distribution**
2. Click **"Get started"**
3. Create tester group (e.g., "testers")
4. Add tester email addresses

### Get Firebase Credentials for CI/CD

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project
3. **IAM & Admin** → **Service Accounts**
4. Create new service account or use existing Firebase Admin SDK one
5. **Keys** → **Add Key** → **Create new key** → JSON
6. Download and save securely (needed for GitHub Actions)

---

## 6. Android Configuration

### Create Upload Keystore (Required for Play Store)

```bash
cd android/app

# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# You'll be prompted for:
# - Keystore password
# - Key password
# - Name, organization, etc.

# IMPORTANT: Save passwords securely!
```

### Configure Signing in Gradle

Create `android/key.properties` (gitignored):
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ...
        }
    }
}
```

### Update Android App Name

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Vesterålen"
    ...>
```

### Configure Internet Permission

In `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET"/>
    ...
</manifest>
```

---

## 7. iOS Configuration

### Update iOS App Name

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Vesterålen</string>
```

### Configure Bundle ID

In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select **Runner** in project navigator
3. Select **Runner** target
4. **General** → Bundle Identifier: `no.ekstremedia.timelapse`

### Set Minimum iOS Version

Edit `ios/Podfile`:
```ruby
platform :ios, '15.0'  # Minimum iOS 15 for Firebase
```

### Configure App Transport Security (for HTTP)

If using non-HTTPS APIs, edit `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### iOS Code Signing for CI/CD (GitHub Actions)

#### Step 1: Create Apple Distribution Certificate

1. Open **Keychain Access** on your Mac
2. **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
3. Fill in:
   - Email: Your Apple ID email
   - Common Name: Your name
   - CA Email Address: Leave empty
   - Request is: Saved to disk
4. Save the `.certSigningRequest` file

5. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)
6. Click **+** → **Apple Distribution**
7. Upload the CSR file
8. Download the certificate (`.cer` file)
9. Double-click to install in Keychain

#### Step 2: Export Certificate as .p12

1. Open **Keychain Access**
2. Find your "Apple Distribution: Your Name" certificate
3. Right-click → **Export**
4. Save as `.p12` file
5. Set a password (remember this for CI/CD!)
6. Convert to base64:
   ```bash
   base64 -i certificate.p12 | pbcopy  # Copies to clipboard
   ```

#### Step 3: Create App ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. Click **+** → **App IDs** → **App**
3. Fill in:
   - Description: Your App Name
   - Bundle ID: Explicit → `no.ekstremedia.vesteraalenTimelapse`
4. Register

#### Step 4: Create Provisioning Profile

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list)
2. Click **+** → **App Store Connect**
3. Select your App ID
4. Select your Distribution Certificate
5. Name: `YourApp AppStore`
6. Download the `.mobileprovision` file
7. Convert to base64:
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```

#### Step 5: Create App Store Connect API Key

1. Go to [App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
2. Click **+** to generate new key
3. Name: `CI/CD Key`, Access: `App Manager`
4. **Download the .p8 file immediately** (only available once!)
5. Note the **Key ID** and **Issuer ID**

#### Step 6: Add GitHub Secrets

| Secret | Value |
|--------|-------|
| `IOS_CERTIFICATE_BASE64` | Base64 of .p12 file |
| `IOS_CERTIFICATE_PASSWORD` | Password used when exporting .p12 |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 of .mobileprovision file |
| `IOS_PROVISIONING_PROFILE_NAME` | Name of profile (e.g., `YourApp AppStore`) |
| `IOS_CODE_SIGN_IDENTITY` | `Apple Distribution: Your Name (TEAM_ID)` |
| `IOS_TEAM_ID` | Your 10-character Team ID |
| `APP_STORE_CONNECT_ISSUER_ID` | From API keys page |
| `APP_STORE_CONNECT_KEY_ID` | Key ID from API keys page |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Contents of .p8 file |

#### Step 7: Create ExportOptions.plist

Create `ios/ExportOptions.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>your.bundle.identifier</key>
        <string>Your Provisioning Profile Name</string>
    </dict>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

---

## 8. CI/CD Setup

### GitHub Actions: Flutter CI (Test & Analyze)

Create `.github/workflows/flutter.yml`:
```yaml
name: Flutter CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

# Cancel outdated runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # IMPORTANT: Specify exact version, avoid cache for consistency
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
          channel: 'stable'

      - run: flutter pub get
      - run: cp .env.example .env
      - run: flutter analyze
      - run: flutter test --coverage
      - run: dart format --output=none --set-exit-if-changed .
```

**Important CI Notes:**
- Always specify exact Flutter version (e.g., `3.38.5`)
- Use `cache: true` for Flutter to speed up builds
- Use `concurrency` to cancel outdated workflow runs
- Cache Gradle and Android SDK (CMake) to avoid slow reinstalls

### CI Caching for Faster Builds

Add these caching steps to avoid slow CMake/Gradle downloads:

```yaml
- name: Cache Gradle
  uses: actions/cache@v4
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: gradle-${{ runner.os }}-${{ hashFiles('**/*.gradle*', '**/gradle-wrapper.properties') }}
    restore-keys: |
      gradle-${{ runner.os }}-

- name: Cache Android SDK
  uses: actions/cache@v4
  with:
    path: |
      /usr/local/lib/android/sdk/cmake
      /usr/local/lib/android/sdk/ndk
    key: android-sdk-${{ runner.os }}-cmake-3.22.1
    restore-keys: |
      android-sdk-${{ runner.os }}-
```

### GitHub Actions: Android Deploy

Create `.github/workflows/android-deploy.yml`:
```yaml
name: Android Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.4'
          cache: true

      - name: Setup environment
        run: cp .env.example .env

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test
        continue-on-error: true

      - name: Increment build number
        id: version
        run: |
          CURRENT=$(grep "^version:" pubspec.yaml | sed 's/version: //')
          VERSION=$(echo "$CURRENT" | cut -d'+' -f1)
          BUILD=$(echo "$CURRENT" | cut -d'+' -f2)
          NEW_BUILD=$((BUILD + 1))
          NEW_VERSION="${VERSION}+${NEW_BUILD}"
          sed -i "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml
          echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT

      - name: Build APK
        run: flutter build apk --release

      - name: Upload to Firebase
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: testers
          file: build/app/outputs/flutter-apk/app-release.apk

      - name: Commit version bump
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add pubspec.yaml
          git commit -m "chore: bump version to ${{ steps.version.outputs.new_version }} [skip ci]" || true
          git push || true
```

### Required GitHub Secrets

Add these in **Settings** → **Secrets and variables** → **Actions**:

| Secret | Source |
|--------|--------|
| `API_BASE_URL` | Your API URL (e.g., `https://ekstremedia.no/api/app`) |
| `ANDROID_KEYSTORE_BASE64` | Run: `base64 -i android/app/upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Your keystore password |
| `ANDROID_KEY_PASSWORD` | Your key password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `FIREBASE_ANDROID_APP_ID` | Firebase Console → Project Settings → Your Apps → App ID (e.g., `1:123456789:android:abc123`) |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase Console → Project Settings → Service accounts → Generate new private key (paste entire JSON) |

### Firebase App Distribution Setup

1. Firebase Console → **Release & Monitor** → **App Distribution**
2. **Testers & Groups** tab → **Add group** → name it `testers`
3. Add your email address to the group
4. Trigger the workflow - you'll receive an email invite to test

### GitHub Actions: iOS Deploy to TestFlight

Create `.github/workflows/ios-deploy.yml`:
```yaml
name: iOS Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  deploy:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
          channel: 'stable'
          cache: true

      - run: flutter pub get

      - name: Create .env file
        run: |
          echo "API_BASE_URL=${{ secrets.API_BASE_URL }}" > .env

      - name: Install Apple Certificate
        uses: apple-actions/import-codesign-certs@v2
        with:
          p12-file-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          p12-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}

      - name: Install Provisioning Profile
        env:
          PROVISIONING_PROFILE_BASE64: ${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo -n "$PROVISIONING_PROFILE_BASE64" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

      - name: Increment build number
        run: |
          BUILD_NUMBER=${{ github.run_number }}
          sed -i '' "s/version: \(.*\)+.*/version: \1+$BUILD_NUMBER/" pubspec.yaml

      - name: Build iOS
        run: flutter build ios --release --no-codesign

      - name: Build Archive
        run: |
          cd ios
          xcodebuild -workspace Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -destination 'generic/platform=iOS' \
            -archivePath Runner.xcarchive \
            archive \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO

      - name: Export IPA
        run: |
          cd ios
          xcodebuild -exportArchive \
            -archivePath Runner.xcarchive \
            -exportPath export \
            -exportOptionsPlist ExportOptions.plist

      - name: Find IPA file
        id: find-ipa
        run: |
          IPA_PATH=$(find ios/export -name "*.ipa" -type f | head -1)
          echo "IPA_PATH=$IPA_PATH" >> $GITHUB_OUTPUT

      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: ${{ steps.find-ipa.outputs.IPA_PATH }}
          issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          api-private-key: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}
```

**Key Points:**
- Build WITHOUT code signing first (`CODE_SIGNING_REQUIRED=NO`)
- Sign during export using `ExportOptions.plist`
- Use `app-store` method (not `app-store-connect`) to avoid auth issues
- Find IPA dynamically (may not be named `Runner.ipa`)

### Xcode Cloud Setup (Alternative)

1. Open Xcode
2. **Product** → **Xcode Cloud** → **Create Workflow**
3. Select your app
4. Configure:
   - **Start Conditions:** Push to `main` branch
   - **Actions:** Archive, TestFlight (Internal Testing)
   - **Post-Actions:** Notify on completion
5. First build will prompt for Apple Developer credentials

---

## 9. Google Play Store Setup

### Create Developer Account

1. Go to [Google Play Console](https://play.google.com/console)
2. Pay $25 one-time registration fee
3. Complete account details

### Create App Listing

1. **All apps** → **Create app**
2. Fill in:
   - App name: `Vesterålen`
   - Default language: Norwegian (Bokmål)
   - App or game: App
   - Free or paid: Free
3. Accept policies

### Complete Store Listing

Required before first release:
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots (phone: 2+, tablet: optional)
- [ ] Privacy policy URL

### App Content Declaration

Complete these sections:
- [ ] Privacy policy
- [ ] Ads declaration
- [ ] App access (does app require login?)
- [ ] Content ratings questionnaire
- [ ] Target audience
- [ ] News apps declaration
- [ ] COVID-19 contact tracing

### Upload First Release

1. **Testing** → **Internal testing** → **Create new release**
2. Upload `.aab` file (App Bundle)
3. Add release notes
4. Save and publish
5. Wait for review (usually < 24 hours for internal)

### Promote to Production

1. Complete all store listing requirements
2. **Production** → **Create new release**
3. Select build from testing track
4. Submit for review (1-3 days)

---

## 10. Apple App Store Setup

### Create Developer Account

1. Go to [Apple Developer](https://developer.apple.com)
2. Enroll in Apple Developer Program ($99/year)
3. Wait for approval (can take 24-48 hours)

### Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
3. Fill in:
   - Platform: iOS
   - Name: `Vesterålen`
   - Primary language: Norwegian (Bokmål)
   - Bundle ID: Select from dropdown (must match Xcode)
   - SKU: `vesteraalen-timelapse`

### Complete App Information

Required before submission:
- [ ] App name and subtitle
- [ ] Privacy policy URL
- [ ] Category: Photo & Video
- [ ] Content rights
- [ ] Age rating questionnaire

### Prepare for Submission

- [ ] App icon (1024x1024 PNG, no transparency)
- [ ] Screenshots for each device size
- [ ] App preview videos (optional)
- [ ] Description
- [ ] Keywords
- [ ] Support URL
- [ ] Marketing URL (optional)

### Upload via Xcode Cloud

Builds appear in App Store Connect automatically:
1. Push to `main` → Xcode Cloud builds
2. Build appears in TestFlight
3. Test with internal testers
4. Submit for App Review when ready

### Submit for Review

1. Select build in App Store Connect
2. Fill in "What's New" section
3. Answer export compliance questions
4. Submit for review (1-3 days typically)

---

## 11. Release Checklist

### Before Every Release

- [ ] Update version in `pubspec.yaml`
- [ ] Run tests: `flutter test`
- [ ] Check analysis: `flutter analyze`
- [ ] Format code: `dart format .`
- [ ] Test on real devices
- [ ] Update release notes

### Android Release

- [ ] Build App Bundle: `flutter build appbundle --release`
- [ ] Upload to Play Console
- [ ] Test in Internal Testing
- [ ] Promote to Production

### iOS Release

- [ ] Push to `main` branch
- [ ] Verify Xcode Cloud build succeeds
- [ ] Test via TestFlight
- [ ] Submit for App Store review

### Post-Release

- [ ] Monitor crash reports (Firebase Crashlytics)
- [ ] Respond to user reviews
- [ ] Track analytics

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `flutter pub get` fails | Delete `pubspec.lock` and retry |
| Android build fails | Check Java version: `java -version` (need 17+) |
| iOS build fails | Run `cd ios && pod install --repo-update` |
| Signing issues (Android) | Verify `key.properties` paths |
| Signing issues (iOS) | Check certificates in Xcode → Signing & Capabilities |
| Firebase upload fails | Re-authenticate: `firebase login --reauth` |
| `intl` version conflict | Use `intl: any` - let Flutter resolve it |
| `withValues()` not defined | Use `withOpacity()` instead (older Flutter) |
| CI uses wrong Flutter version | Specify exact version + remove `cache: true` |
| Dart format fails in CI | Add pre-commit hook to auto-format |

### Useful Commands

```bash
# Clean build
flutter clean && flutter pub get

# Verbose build (for debugging)
flutter build apk --release -v

# Check connected devices
flutter devices

# Upgrade Flutter
flutter upgrade

# Verify Flutter installation
flutter doctor -v
```

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect)
- [GitHub Actions for Flutter](https://github.com/subosito/flutter-action)

---

*Last updated: 2026-01-01 (iOS deployment added)*
