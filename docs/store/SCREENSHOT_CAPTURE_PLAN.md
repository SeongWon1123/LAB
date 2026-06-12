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

CI generates 1x draft widget screenshots through `tool/store_screenshot_test.dart` and uploads them as a `store-screenshot-drafts-*` artifact from the Flutter CI workflow.

Final screenshots still require simulator/device review, platform-specific framing, and visual QA before store submission.
