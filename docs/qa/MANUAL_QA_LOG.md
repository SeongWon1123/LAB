# Manual QA Log

Manual QA must be run on real devices or simulators before store submission. Do not mark this complete from CI alone.

## Build Under Test

- Commit:
- Date:
- Tester:
- Android debug APK artifact: `android-debug-apk-<run_number>`
- Android release AAB artifact: `android-release-aab-<run_number>`
- iOS simulator app artifact: `ios-simulator-app-<run_number>`
- iOS simulator smoke artifact: `ios-simulator-smoke-<run_number>`
- iOS no-codesign release artifact: `ios-release-nocodesign-app-<run_number>`
- Brand asset artifact: `brand-assets-<run_number>`
- Release evidence artifact: `release-evidence-<run_number>`
- QA manifest artifacts: `android-qa-manifest-<run_number>`, `ios-qa-manifest-<run_number>`
- Release artifact verification report: `release_artifact_report.txt`

Use the latest successful Native Build workflow run for installable artifacts and the latest successful Flutter CI workflow run for `brand-assets-<run_number>`. Paste the native manifest values plus `brand_asset_manifest.json` or `brand_asset_manifest.txt` values, file sizes, and SHA-256 checksums into this section before QA starts. The iOS simulator app artifact is for simulator QA only, the smoke artifact proves CI install/launch only, and the no-codesign release artifact is a build gate only; TestFlight still requires a signed archive from an Apple Developer account.

Preferred pre-QA command:

```bash
python tool/verify_release_artifacts.py
```

This writes `release_artifact_report.json` and `release_artifact_report.txt` under `build/release_artifacts/` and verifies the downloaded artifact checksums before manual testing starts. The same check can be run from GitHub Actions with the `Release Evidence` workflow, which uploads `release-evidence-<run_number>`.

## Install Commands

- Android debug APK: `adb install -r app-debug.apk`
- iOS simulator app:
  - `unzip Pocket-Memory-Pet-simulator.app.zip`
  - `xcrun simctl boot <device-id>`
  - `xcrun simctl install booted "Pocket Memory Pet.app"`
  - `xcrun simctl launch booted com.wellnessmaker.pocketmemorypet`

## Device Matrix

| Platform | Device | OS Version | Evidence | Result | Notes |
| --- | --- | --- | --- | --- | --- |
| Android | Small 360x800 class |  | Screenshot or screen recording | Not run |  |
| Android | Large phone |  | Screenshot or screen recording | Not run |  |
| Android | Samsung physical device |  | Screenshot or screen recording | Not run |  |
| iOS | iPhone SE class |  | Screenshot or screen recording | Not run |  |
| iOS | iPhone 15/16 class |  | Screenshot or screen recording | Not run |  |

## Scenarios

| Scenario | Expected Result | Evidence | Result | Notes |
| --- | --- | --- | --- | --- |
| First install opens onboarding | Onboarding screen appears without crash or overflow. | Screenshot | Not run |  |
| Empty pet name is blocked | Continue action shows validation and stays on onboarding. | Screenshot | Not run |  |
| Pet name saves and hatch flow starts | Entering `Cloudy` opens hatch screen and then home. | Screen recording | Not run |  |
| Home screen has no overflow | LCD pet, stat text, and three buttons fit on target screen. | Screenshot | Not run |  |
| Meal/snack/clean/sleep actions update state | Selected care action changes the visible pet state or stats. | Screen recording | Not run |  |
| Jump Star win/loss returns to pet reward flow | Mini-game completes and returns without crash; diary/state updates. | Screen recording | Not run |  |
| Diary entries appear after care and growth | Diary shows recent care or growth entries in reverse chronology. | Screenshot | Not run |  |
| App restart preserves state | Closing and reopening keeps pet name, stage, stats, settings, and diary. | Screen recording | Not run |  |
| One-hour elapsed-time simulation updates state | After time advance/reopen, elapsed care simulation is visible. | Notes plus screenshot | Not run |  |
| Two-day offline cap does not punish beyond 48 hours | Long offline interval is capped and pet remains recoverable. | Notes plus screenshot | Not run |  |
| Notification permission denial keeps app usable | Denying permission keeps settings usable and does not block care flow. | Screen recording | Not run |  |
| Notification permission approval schedules reminders | Approval enables reminders and settings reflects enabled state. | Screenshot | Not run |  |
| Sound toggle disables effects | Sound disabled state persists and no care/play effects are heard. | Tester note | Not run |  |
| Reset local pet data works | Reset clears pet state and returns to first-run flow. | Screen recording | Not run |  |

## Release Decision

- Ready for closed testing: No
- Blocking issues:
- Follow-up issues:
