# Manual QA Log

Manual QA must be run on real devices or simulators before store submission. Do not mark this complete from CI alone.

## Build Under Test

- Commit: `d0d56f2a9a862e97c1c99ba2d9c25ee90620521e`
- Date: `2026-06-13 KST` (`2026-06-12T16:02:11Z` evidence generation)
- Tester: To be assigned
- Android debug APK artifact: `android-debug-apk-31`
- Android release AAB artifact: `android-release-aab-31`
- Android emulator smoke artifact: `android-emulator-smoke-31`
- iOS simulator app artifact: `ios-simulator-app-31`
- iOS simulator smoke artifact: `ios-simulator-smoke-31`
- iOS no-codesign release artifact: `ios-release-nocodesign-app-31`
- Brand asset artifact: `brand-assets-34`
- Draft store screenshot artifact: `store-screenshot-drafts-34`
- Release evidence artifact: `release-evidence-3`
- QA manifest artifacts: `android-qa-manifest-31`, `ios-qa-manifest-31`
- Release artifact verification report: `release_artifact_report.txt`

## Automated Evidence Snapshot

This section records CI evidence only. It does not replace the manual device matrix or scenarios below.
This snapshot is pinned to the build candidate above. Do not refresh it for documentation-only commits unless the QA build artifacts change.

| Evidence | Result |
| --- | --- |
| Flutter CI run 34 | Passed: `https://github.com/SeongWon1123/LAB/actions/runs/27426253499` |
| Native Build run 31 | Passed: `https://github.com/SeongWon1123/LAB/actions/runs/27426253540` |
| Release Evidence run 3 | Passed: `https://github.com/SeongWon1123/LAB/actions/runs/27427368298` |
| Android emulator launch | `passed` with package `com.wellnessmaker.pocketmemorypet` |
| iOS simulator launch | `passed` |
| Brand assets verified | `4` files |
| Draft store screenshots verified | `14` files |
| Privacy URL | HTTP 200 at `https://seongwon1123.github.io/LAB/privacy/` on `2026-06-13 KST` |
| Support URL | HTTP 200 at `https://seongwon1123.github.io/LAB/support/` on `2026-06-13 KST` |

| Artifact | SHA-256 |
| --- | --- |
| Android debug APK | `2afcbaa0fc37845fd641792e0db8d10632e0e1734cd648eb2742e65efee9615b` |
| Android release AAB | `13b9afac9fe6b5f078a5f7ff7a6959d2565c421dcfc1fbc4b2537e6ffb592fdc` |
| Android emulator smoke screenshot | `421ff90875312f0ae34d5264f101eb0d2b3a68345ae14ba6e8e4c010a3af5ce7` |
| iOS simulator app zip | `78d740c4c555cef80a98f1050daf74b4b5df33280c7de48bb4ccbdfa36f8d19c` |
| iOS release no-codesign zip | `e7fb4cdcad480832b6b7cd41ebb4525b22aaed93d71acdb062bc6e1433c5dca0` |

Use the latest successful Native Build workflow run for installable artifacts and the latest successful Flutter CI workflow run for `brand-assets-<run_number>`. Paste the native manifest values plus `brand_asset_manifest.json` or `brand_asset_manifest.txt` values, file sizes, and SHA-256 checksums into this section before QA starts. Android and iOS smoke artifacts prove CI install/launch only, the iOS simulator app artifact is for simulator QA only, and the no-codesign release artifact is a build gate only; TestFlight still requires a signed archive from an Apple Developer account.

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
