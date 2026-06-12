# Pocket Memory Pet

Pocket Memory Pet is an original, local-first retro pixel pet app for iOS and Android. It focuses on a warm desk-toy feeling, a soft LCD-style screen, three-button care, offline growth, local diary entries, and no backend in the MVP.

## MVP Scope

- Onboarding with pet naming
- Hatch flow
- Home screen with an original rounded pocket-toy shell
- LCD-style pixel pet display
- Three-button navigation and selection
- Meal, snack, play, clean, sleep, and wake care actions
- Jump Star Flame mini-game with pet-care rewards
- Original short beep effects and haptic feedback
- Generated original app icon, splash, Play icon, and feature graphic assets
- UTC-based elapsed-time simulation capped at 48 offline hours
- Growth stages and automatic diary entries
- Hive CE local persistence through repository interfaces
- Local notification permission flow and inexact reminder scheduling
- Flutter tests for model, time, care, repository, notification policy, and UI behavior

## Out Of Scope For MVP

No server, Firebase, login, ads, in-app purchases, social features, ranking, chat, AR, random draws, UGC, or community features.

## Requirements

- Flutter SDK with Dart
- Android Studio or Xcode for device builds
- Android SDK target that satisfies current Google Play requirements

This machine currently does not have `flutter` or `dart` on `PATH`, so local analyze/test/build commands could not be executed here.

## Run

```bash
flutter pub get
flutter run
```

If native platform folders are missing because this repository was scaffolded without a local Flutter SDK, generate them once:

```bash
bash tool/prepare_native_project.sh
```

The script runs `flutter create`, then applies the required Android package name and iOS bundle ID.

## Verify

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

The repository also includes a native build workflow that generates Android/iOS platform folders in CI and verifies:

- Android debug APK
- Android release AAB
- Android emulator install/launch smoke
- iOS simulator build
- iOS release build without code signing
- Android/iOS QA manifest artifacts

The Flutter CI workflow verifies `flutter analyze`, `flutter test`, CI-generated brand assets uploaded as `brand-assets-<run_number>`, and CI-generated draft store screenshots uploaded as `store-screenshot-drafts-<run_number>`. The brand artifact includes `brand_asset_manifest.json` and `brand_asset_manifest.txt` for `play_icon_512.png`, `feature_graphic_1024x500.png`, and native source art. The screenshot artifact includes `store_screenshot_manifest.json` and `store_screenshot_manifest.txt` with file sizes and SHA-256 checksums.

Before manual QA, run the `Release Evidence` workflow or run `python tool/verify_release_artifacts.py` from an authenticated GitHub CLI session. It downloads the latest successful Flutter CI and Native Build artifacts for the current commit, verifies manifest SHA-256 values, and writes `release_artifact_report.json` plus `release_artifact_report.txt` under `build/release_artifacts/`. The workflow uploads these reports as `release-evidence-<run_number>`.

For iOS:

```bash
flutter run -d ios
flutter build ios --simulator --no-codesign
flutter build ios --release --no-codesign
```

The no-codesign iOS release build is a signing-independent gate only. TestFlight still requires Apple Developer Program signing and App Store Connect upload.

## Package IDs

- Android package name target: `com.wellnessmaker.pocketmemorypet`
- iOS bundle ID target: `com.wellnessmaker.pocketmemorypet`

## Store Support

- Privacy policy: `https://seongwon1123.github.io/LAB/privacy/`
- Support page: `https://seongwon1123.github.io/LAB/support/`

## Legal Position

Pocket Memory Pet is an original retro digital pet app. It is not affiliated with, endorsed by, or sponsored by any existing toy or game brand. All characters, sounds, interface elements, and visual assets are original or must be used under appropriate licenses.
