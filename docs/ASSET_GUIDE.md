# Asset Guide

## Current State

The MVP currently uses code-drawn placeholder visuals, original generated WAV effects, original generated brand source PNGs, and original generated store listing PNGs.

## Rules

- All pet sprites must be original.
- All UI icons must be original, open-source with compatible license, or hand-drawn in code.
- All sounds must be original or commercially licensed.
- Record every external asset in `LICENSES.md`.

## Needed Assets

- Pixel pet sprites for growth stages.
- Tiny status icons.
- Final store screenshots from simulator/device captures.
- Final platform-mask review for store icons.

## Generated Brand Assets

- `assets/images/brand/app_icon_1024.png`: 1024 x 1024 source icon for native icon generation.
- `assets/images/brand/splash_1024.png`: 1024 x 1024 source splash art.
- `store_assets/brand/play_icon_512.png`: 512 x 512 Google Play store icon.
- `store_assets/brand/feature_graphic_1024x500.png`: 1024 x 500 Google Play feature graphic.

Run `python3 tool/generate_brand_assets.py --force`, then `python3 tool/validate_brand_assets.py` and `python3 tool/generate_brand_asset_manifest.py` to refresh and verify the files. CI uploads them as `brand-assets-<run_number>` with `brand_asset_manifest.json` and `brand_asset_manifest.txt`.

Store-only files live under `store_assets/brand/` so they are not bundled into the app through `pubspec.yaml`.
