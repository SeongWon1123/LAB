# Test Plan

## Unit Tests

- PetState creation and clamping.
- Meal, snack, play, clean, sleep, and wake changes.
- Elapsed-time calculation.
- 48-hour offline cap.
- Growth stages.
- Care mistakes.
- Diary generation.
- In-memory repository persistence.
- Hive repository save, load, and reset.
- Jump Star win/loss rules.
- Notification quiet hours and reminder planning.

## Widget Tests

- Home screen renders.
- Three-button navigation changes selected menu.
- Center action button triggers care action.
- Status gauges are visible.
- Diary list is visible.
- Onboarding blocks empty pet names.
- Settings shows notification explanation before permission.
- Settings schedules reminders after permission is granted.

## Manual QA

Use `docs/qa/MANUAL_QA_LOG.md` as the release QA record.

- Android 360x800 class: install `android-debug-apk-<run_number>` and capture all overflow-sensitive screens.
- Android large screen: install `android-debug-apk-<run_number>` and verify layout density, touch targets, and persistence.
- Samsung physical device: verify notification permission behavior and audio toggle behavior.
- iPhone SE class simulator/device: install `ios-simulator-app-<run_number>` on simulator or a signed device build and verify small-screen fit.
- iPhone 15/16 class simulator/device: verify normal-size iOS layout, app restart, and storage persistence.
- First install, name entry, hatch, care actions, Jump Star, diary, restart after one hour, restart after two days, notification denied/approved, sound toggle, and data reset must each include screenshot, screen recording, or tester notes as evidence.
