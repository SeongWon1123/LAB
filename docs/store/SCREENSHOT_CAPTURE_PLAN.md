# Screenshot Capture Plan

## Purpose

This document defines the screenshot set to capture after the app is run on simulator or device. It is not a substitute for final store screenshots.

## Required Screens

Capture these app states:

- Onboarding with pet name field.
- Hatch screen before entering home.
- Home screen with the LCD pet and three-button shell.
- Status screen with gauges.
- Jump Star mini-game.
- Diary screen with entries.
- Settings screen showing local reminders and sound.

## Android Sizes

- Phone portrait, 1080 x 1920 or higher.
- Small-device QA crop target: 360 x 800.
- Optional tablet portrait if tablet support is kept enabled.

## iOS Sizes

- 6.7-inch iPhone portrait.
- 6.5-inch iPhone portrait if required by App Store Connect.
- 5.5-inch iPhone portrait if required by App Store Connect.

## Capture Rules

- Use original UI only.
- Do not include third-party brand names or comparison phrases.
- Do not show debug banners.
- Use a pet name that is safe for store review, such as `Cloudy`.
- Keep notification permission dialogs out of marketing screenshots unless the store specifically needs permission-flow evidence.

## Status

CI generates 1x draft widget screenshots through `flutter test --update-goldens tool/store_screenshot_test.dart`, validates the expected PNG names and dimensions with `python3 tool/validate_store_screenshots.py`, writes `store_screenshot_manifest.json` and `store_screenshot_manifest.txt` with artifact-root paths, file sizes, and SHA-256 checksums, and uploads everything as a `store-screenshot-drafts-*` artifact from the Flutter CI workflow.

`store_screenshot_manifest.json` is the authoritative machine-readable manifest. `store_screenshot_manifest.txt` is a human-readable companion for quick QA review.

Final screenshots still require simulator/device review, platform-specific framing, and visual QA before store submission.

## Approval Matrix

| File | Source | Required State | Visual QA | Final Export | Notes |
| --- | --- | --- | --- | --- | --- |
| `01_onboarding.png` | CI draft plus simulator/device capture | Pet name field visible with safe sample name | Not run | Not exported | Use real onboarding UI in final capture. |
| `02_hatch.png` | CI draft plus simulator/device capture | Named pet ready to hatch | Not run | Not exported | Confirm no debug banner. |
| `03_home.png` | CI draft plus simulator/device capture | LCD pet, stats, and three-button shell visible | Not run | Not exported | Must fit on smallest target. |
| `04_status.png` | CI draft plus simulator/device capture | Gauges readable | Not run | Not exported | Check text contrast. |
| `05_jump_star.png` | CI draft plus simulator/device capture | Mini-game active and readable | Not run | Not exported | Prefer deterministic mid-game state. |
| `06_diary.png` | CI draft plus simulator/device capture | Multiple diary entries visible | Not run | Not exported | Avoid personal data. |
| `07_settings.png` | CI draft plus simulator/device capture | Reminder and sound settings visible | Not run | Not exported | Avoid permission dialogs unless required. |
