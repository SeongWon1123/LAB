# TestFlight Preparation

## Local Repo Status

The native build workflow verifies that an iOS simulator build can be generated from this repo. TestFlight upload still requires Apple Developer Program access and signing.

## Required External Setup

- Apple Developer Program membership.
- App Store Connect app record.
- Bundle ID: `com.wellnessmaker.pocketmemorypet`.
- Signing certificate.
- Provisioning profile.
- macOS machine with Xcode signed into the Apple Developer account.

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

## Review Notes Draft

Pocket Memory Pet is a local-first pixel pet app. No account is required. Local notifications are optional and can be denied without blocking app use. The app contains no ads, purchases, chat, social features, or user-generated content in the MVP.

## Blockers Before External TestFlight

- Apple Developer account access.
- Hosted privacy policy URL.
- Final screenshots.
- Manual QA pass on at least one iOS simulator or device.
