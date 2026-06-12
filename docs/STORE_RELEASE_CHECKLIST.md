# Store Release Checklist

## Android

- Package name: `com.wellnessmaker.pocketmemorypet`.
- Target current Google Play SDK requirements.
- Build internal debug APK.
- Build release AAB for store submission.
- Run `bash tool/prepare_native_project.sh` before native builds if platform folders have not been generated locally.
- Prepare icon, feature graphic, screenshots, privacy policy URL, data safety, content rating, target age, and test access notes.

## iOS

- Bundle ID: `com.wellnessmaker.pocketmemorypet`.
- Display name: `Pocket Memory Pet`.
- Portrait orientation.
- Run `bash tool/prepare_native_project.sh` before iOS simulator/archive checks if platform folders have not been generated locally.
- App Privacy answers.
- TestFlight archive.
- App Store screenshots and review notes.

## Store Copy

Use only original app positioning and the legal disclaimer from README.
