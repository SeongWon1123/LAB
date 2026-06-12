# Brand Asset Plan

## Purpose

This document defines the generated brand and store listing art for Pocket Memory Pet. It keeps app-bundled source art separate from store-only upload assets.

## Generated Files

| File | Role | Requirement |
| --- | --- | --- |
| `assets/images/brand/app_icon_1024.png` | Native source icon | 1024 x 1024 PNG source art |
| `assets/images/brand/splash_1024.png` | Native source splash | 1024 x 1024 PNG source art |
| `store_assets/brand/play_icon_512.png` | Google Play store icon | 512 x 512, 32-bit PNG with alpha, max 1024KB |
| `store_assets/brand/feature_graphic_1024x500.png` | Google Play feature graphic | 1024 x 500, 24-bit PNG with no alpha |

## Workflow

Run:

```bash
python3 tool/generate_brand_assets.py --force
python3 tool/validate_brand_assets.py
python3 tool/generate_brand_asset_manifest.py
```

Flutter CI runs the same checks, uploads `brand-assets-<run_number>`, and includes:

- `brand_asset_manifest.json`
- `brand_asset_manifest.txt`
- `play_icon_512.png`
- `feature_graphic_1024x500.png`

## Store Review Notes

- The 1024 x 1024 source icon is not the Google Play upload icon.
- Store-only files remain under `store_assets/brand/` and are not listed in `pubspec.yaml`.
- Do not add ranking, price, sale, install, or call-to-action text to the feature graphic.
- Do not include third-party logos, trademarked characters, device imagery, or Google Play badges.
- Keep the primary feature graphic content centered to avoid cutoff zones.
- Perform final app icon review in platform masks before submission.

Google Play preview asset requirements are documented at `https://support.google.com/googleplay/android-developer/answer/9866151`. Google Play icon specifications are documented at `https://developer.android.com/distribute/google-play/resources/icon-design-specifications`.
