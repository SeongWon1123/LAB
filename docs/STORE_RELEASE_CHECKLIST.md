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
- Use `docs/store/SCREENSHOT_CAPTURE_PLAN.md` before final screenshot capture.

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
Use the latest successful Native Build workflow artifacts for installable QA builds:

- `android-debug-apk-<run_number>` for Android device smoke testing.
- `android-release-aab-<run_number>` for Play Console upload rehearsal.
- `ios-simulator-app-<run_number>` for iOS simulator smoke testing.
- `ios-release-nocodesign-app-<run_number>` for signing-independent iOS release build verification.
- `android-qa-manifest-<run_number>` and `ios-qa-manifest-<run_number>` for commit/run traceability.
