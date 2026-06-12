#!/usr/bin/env python3
"""Validate CI-generated draft store screenshot files."""

from __future__ import annotations

import struct
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCREENSHOT_DIR = ROOT / "build" / "store_screenshots"

SCREENS = [
    "01_onboarding.png",
    "02_hatch.png",
    "03_home.png",
    "04_status.png",
    "05_jump_star.png",
    "06_diary.png",
    "07_settings.png",
]

TARGETS = {
    "android_phone": (360, 800),
    "ios_6_7": (430, 932),
}


def png_size(path: Path) -> tuple[int, int]:
    with path.open("rb") as fh:
        header = fh.read(24)
    if len(header) != 24 or not header.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not a PNG")
    width, height = struct.unpack(">II", header[16:24])
    return width, height


def main() -> int:
    errors: list[str] = []

    for folder, expected_size in TARGETS.items():
        target_dir = SCREENSHOT_DIR / folder
        if not target_dir.is_dir():
            errors.append(f"Missing screenshot directory: {target_dir}")
            continue

        expected_files = {target_dir / screen for screen in SCREENS}
        actual_files = set(target_dir.glob("*.png"))

        missing = sorted(expected_files - actual_files)
        extra = sorted(actual_files - expected_files)
        for path in missing:
            errors.append(f"Missing screenshot: {path.relative_to(ROOT)}")
        for path in extra:
            errors.append(f"Unexpected screenshot: {path.relative_to(ROOT)}")

        for path in sorted(expected_files & actual_files):
            try:
                actual_size = png_size(path)
            except ValueError as error:
                errors.append(f"Invalid PNG {path.relative_to(ROOT)}: {error}")
                continue
            if actual_size != expected_size:
                errors.append(
                    f"Wrong size for {path.relative_to(ROOT)}: "
                    f"{actual_size[0]}x{actual_size[1]}, expected {expected_size[0]}x{expected_size[1]}"
                )

    if errors:
        print("Store screenshot validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Store screenshot validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
