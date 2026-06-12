# Store Release Checklist

## Android

- Package name: `com.wellnessmaker.pocketmemorypet`.
- Target current Google Play SDK requirements.
- Build internal debug APK.
- Build release AAB for store submission.
- Run `bash tool/prepare_native_project.sh` before native builds if platform folders have not been generated locally.
- Prepare icon, feature graphic, screenshots, privacy policy URL, data safety, content rating, target age, and test access notes.
- Use `docs/store/STORE_METADATA.md` for copy.
- Use `docs/store/DATA_SAFETY_DRAFT.md` for the Data safety form.
- Use `docs/store/BRAND_ASSET_PLAN.md` for icon and feature graphic requirements.
- Use `docs/store/SCREENSHOT_CAPTURE_PLAN.md` before final screenshot capture.
- Use `brand_asset_manifest.json` from the latest `brand-assets-<run_number>` artifact to verify `play_icon_512.png`, `feature_graphic_1024x500.png`, source asset sizes, and SHA-256 checksums.
- Use `store_screenshot_manifest.json` from the latest `store-screenshot-drafts-<run_number>` artifact to verify draft screenshot file names, sizes, and SHA-256 checksums.

## iOS

- Bundle ID: `com.wellnessmaker.pocketmemorypet`.
- Display name: `Pocket Memory Pet`.
- Portrait orientation.
- Run `bash tool/prepare_native_project.sh` before iOS simulator/archive checks if platform folders have not been generated locally.
- App Privacy answers.
- TestFlight archive.
- App Store screenshots and review notes.
- Use `docs/store/APP_PRIVACY_DRAFT.md` for App Privacy answers.
- Use `docs/store/TESTFLIGHT_PREP.md` for external signing and upload steps.

## Store Copy

Use only original app positioning and the legal disclaimer from README.

## Store URLs

- Privacy policy URL: `https://seongwon1123.github.io/LAB/privacy/`.
- Support URL: `https://seongwon1123.github.io/LAB/support/`.

## Manual QA

Record release QA in `docs/qa/MANUAL_QA_LOG.md`.
Run the `Release Evidence` workflow or `python tool/verify_release_artifacts.py` before manual QA to download the latest successful Flutter CI and Native Build artifacts for the current commit and verify `release_artifact_report.json` plus `release_artifact_report.txt`.
Use the latest successful Native Build workflow artifacts for installable QA builds:

- `release-evidence-<run_number>` for the pre-QA artifact verification report.
- `android-debug-apk-<run_number>` for Android device smoke testing.
- `android-release-aab-<run_number>` for Play Console upload rehearsal.
- `android-emulator-smoke-<run_number>` for CI install/launch smoke evidence.
- `brand-assets-<run_number>` for Play icon, feature graphic, source brand art, and `brand_asset_manifest.txt`.
- `ios-simulator-app-<run_number>` for iOS simulator smoke testing.
- `ios-simulator-smoke-<run_number>` for CI install/launch smoke evidence.
- `ios-release-nocodesign-app-<run_number>` for signing-independent iOS release build verification.
- `android-qa-manifest-<run_number>` and `ios-qa-manifest-<run_number>` for commit/run traceability.

The QA manifests include file sizes and SHA-256 checksums for native build artifacts. Use these values to verify downloaded files before manual QA or store upload rehearsal.
