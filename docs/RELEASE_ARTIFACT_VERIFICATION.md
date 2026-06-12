# Release Artifact Verification

## Purpose

Use this before manual QA or store upload rehearsal to prove that the downloaded GitHub Actions artifacts match their manifests.

## GitHub Workflow

Run the `Release Evidence` workflow manually after the latest `Flutter CI` and `Native Build` runs have succeeded for the target commit. The workflow uploads `release-evidence-<run_number>` with:

- `release_artifact_report.json`
- `release_artifact_report.txt`

## Local Command

```bash
python tool/verify_release_artifacts.py
```

Requirements:

- GitHub CLI installed and authenticated.
- Current checkout on the commit being verified.
- Latest successful `Flutter CI` and `Native Build` runs for that commit.

## What It Verifies

- `brand-assets-<run_number>` against `brand_asset_manifest.json`.
- `store-screenshot-drafts-<run_number>` against `store_screenshot_manifest.json`.
- `android-debug-apk-<run_number>` against `android-qa-manifest-<run_number>`.
- `android-release-aab-<run_number>` against `android-qa-manifest-<run_number>`.
- `android-emulator-smoke-<run_number>` reports `launch_result=passed`.
- `ios-simulator-app-<run_number>` against `ios-qa-manifest-<run_number>`.
- `ios-release-nocodesign-app-<run_number>` against `ios-qa-manifest-<run_number>`.
- `ios-simulator-smoke-<run_number>` reports `launch_result=passed`.

## Output

The script downloads artifacts under `build/release_artifacts/` and writes:

- `release_artifact_report.json`
- `release_artifact_report.txt`

These files are local release evidence and are not committed. In GitHub Actions, only the reports are uploaded as `release-evidence-<run_number>`.

## Remaining External Work

Passing this script does not replace manual QA, final screenshot review/export, or Apple Developer Program signing for TestFlight.
