# Next Steps for Vesterålen Timelapse App

## Current Status (2026-01-01)

### Completed ✅

- [x] Flutter project created and configured
- [x] All core features implemented (cameras, timelapse, settings)
- [x] 42 Flutter tests passing
- [x] 13 Laravel tests passing
- [x] Firebase project created
- [x] Android signing key created
- [x] GitHub secrets configured
- [x] CI/CD workflows with caching
- [x] Pre-commit hook for auto-formatting
- [x] Firebase App Distribution configured
- [x] First APK build successful

### Remaining 🔲

- [ ] Add yourself to Firebase testers group
- [ ] Test app via Firebase App Distribution
- [ ] Set up iOS signing (certificates, provisioning profiles)
- [ ] Configure Xcode Cloud or GitHub Actions for iOS
- [ ] Submit to Google Play Store (internal testing)
- [ ] Submit to Apple App Store (TestFlight)

---

## Next: Firebase App Distribution Testing

1. Go to Firebase Console: https://console.firebase.google.com
2. Select **Vesterålen Timelapse** project
3. **Release & Monitor** → **App Distribution**
4. **Testers & Groups** tab
5. **Add group** → name it `testers`
6. Add your email address
7. Re-run the workflow: https://github.com/ekstremedia/vesteraalen-timelapse-app/actions/workflows/android-deploy.yml
8. Check your email for the invite, or open **App Tester** app

---

## Trigger a New Release

```bash
# Manual trigger via GitHub Actions UI
# Or create a tag:
git tag v1.0.1
git push origin v1.0.1
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

# Format code (auto-runs on commit via pre-commit hook)
dart format .

# Build release APK
flutter build apk --release

# Setup git hooks on new clone
./scripts/setup-hooks.sh
```

---

## GitHub Secrets Reference

| Secret Name | Description |
|-------------|-------------|
| `API_BASE_URL` | Backend API URL |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded upload-keystore.jks |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `FIREBASE_ANDROID_APP_ID` | Firebase App ID (e.g., `1:123456789:android:abc123`) |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON |

---

## Project URLs

| Resource | URL |
|----------|-----|
| GitHub Repo | https://github.com/ekstremedia/vesteraalen-timelapse-app |
| GitHub Actions | https://github.com/ekstremedia/vesteraalen-timelapse-app/actions |
| Firebase Console | https://console.firebase.google.com |
| API Endpoint | https://ekstremedia.no/api/app |

---

## iOS Setup (Future)

When ready for iOS:

1. Create Apple Developer account ($99/year)
2. Create App ID in Apple Developer Portal
3. Create Distribution Certificate
4. Create Provisioning Profile
5. Configure Xcode Cloud or add iOS secrets to GitHub
6. Enable iOS workflow trigger in `.github/workflows/ios-deploy.yml`

---

*Last updated: 2026-01-01*
