# TestFlight Preparation

## Local Repo Status

The native build workflow verifies that an iOS simulator build can be generated from this repo. TestFlight upload still requires Apple Developer Program access and signing.

The latest successful Native Build workflow uploads `ios-simulator-app-<run_number>` for simulator smoke testing and `ios-release-nocodesign-app-<run_number>` as a signing-independent release build gate. These artifacts are not TestFlight archives and cannot be uploaded to App Store Connect.

## Required External Setup

- Apple Developer Program membership.
- App Store Connect app record.
- Bundle ID: `com.wellnessmaker.pocketmemorypet`.
- Signing certificate.
- Provisioning profile.
- macOS machine with Xcode signed into the Apple Developer account.
- Apple Team ID:
- App Store Connect app record ID/SKU:
- Bundle ID status in Certificates, Identifiers & Profiles:
- Version/build number from `pubspec.yaml`:
- Archive owner:

## Archive Steps

1. Confirm `flutter analyze` and `flutter test` pass.
2. Run `bash tool/prepare_native_project.sh` if native folders are not present.
3. Open `ios/Runner.xcworkspace` in Xcode.
4. Select the Runner scheme.
5. Set signing team and provisioning profile.
6. Archive for Any iOS Device.
7. Upload through Organizer to App Store Connect.
8. Wait for TestFlight processing.
9. Add internal testers and run the manual QA matrix.

Before archiving, confirm the `version` line in `pubspec.yaml` has a monotonically increasing build number. For example, `0.1.0+2` must follow `0.1.0+1`.

## Simulator QA Before Signing

1. Open the latest successful Native Build workflow run.
2. Download `ios-simulator-app-<run_number>`.
3. Download `ios-qa-manifest-<run_number>` and copy the manifest values into `docs/qa/MANUAL_QA_LOG.md`.
4. Unzip `Pocket-Memory-Pet-simulator.app.zip` on a macOS machine with Xcode installed.
5. Boot the target simulator.
6. Install the app with `xcrun simctl install booted "Pocket Memory Pet.app"`.
7. Launch and record results in `docs/qa/MANUAL_QA_LOG.md`.

## Review Notes Draft

Pocket Memory Pet is a local-first pixel pet app. No account is required. Local notifications are optional and can be denied without blocking app use. The app contains no ads, purchases, chat, social features, or user-generated content in the MVP.

## Blockers Before External TestFlight

- Apple Developer account access.
- Hosted privacy policy URL.
- Final screenshots.
- Manual QA pass on at least one iOS simulator or device.
