#!/usr/bin/env python3
"""Generate original Pocket Memory Pet brand assets without external images."""

from __future__ import annotations

import argparse
import shutil
import math
import struct
import zlib
from pathlib import Path


RGBA = tuple[int, int, int, int]

BRAND_DIR = Path("assets/images/brand")


def blend(base: RGBA, top: RGBA, alpha: float) -> RGBA:
    alpha = max(0.0, min(1.0, alpha * (top[3] / 255)))
    inv = 1.0 - alpha
    return (
        round(base[0] * inv + top[0] * alpha),
        round(base[1] * inv + top[1] * alpha),
        round(base[2] * inv + top[2] * alpha),
        255,
    )


def write_png(path: Path, width: int, height: int, pixels: list[RGBA]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        row_start = y * width
        for r, g, b, a in pixels[row_start : row_start + width]:
            raw.extend((r, g, b, a))

    def chunk(kind: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + kind
            + data
            + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
        )

    data = b"".join(
        [
            b"\x89PNG\r\n\x1a\n",
            chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)),
            chunk(b"IDAT", zlib.compress(bytes(raw), 9)),
            chunk(b"IEND", b""),
        ]
    )
    path.write_bytes(data)


def rounded_rect_alpha(x: float, y: float, left: float, top: float, right: float, bottom: float, radius: float) -> float:
    cx = min(max(x, left + radius), right - radius)
    cy = min(max(y, top + radius), bottom - radius)
    dx = x - cx
    dy = y - cy
    distance = math.sqrt(dx * dx + dy * dy)
    if left + radius <= x <= right - radius and top <= y <= bottom:
        return 1.0
    if top + radius <= y <= bottom - radius and left <= x <= right:
        return 1.0
    return max(0.0, min(1.0, radius + 0.003 - distance))


def star_alpha(x: float, y: float, cx: float, cy: float, outer: float, inner: float) -> float:
    angle = math.atan2(y - cy, x - cx)
    radius = math.hypot(x - cx, y - cy)
    point = (angle + math.pi / 2) / (math.pi * 2 / 5)
    local = abs((point - math.floor(point)) - 0.5) * 2
    limit = inner + (outer - inner) * local
    return 1.0 if radius <= limit else 0.0


def rect_alpha(x: float, y: float, left: float, top: float, right: float, bottom: float) -> float:
    return 1.0 if left <= x <= right and top <= y <= bottom else 0.0


def draw_icon(size: int) -> list[RGBA]:
    pixels: list[RGBA] = []
    for py in range(size):
        y = py / size
        for px in range(size):
            # Quantize to a soft pixel grid so the mark reads crisply at small sizes.
            x = (math.floor(px / size * 96) + 0.5) / 96
            y = (math.floor(py / size * 96) + 0.5) / 96
            color: RGBA = (255, 244, 236, 255)

            if y > 0.02:
                color = blend(color, (245, 175, 198, 255), 0.10)
            if x + y > 1.0:
                color = blend(color, (191, 232, 212, 255), 0.16)

            if rounded_rect_alpha(x, y, 0.18, 0.15, 0.84, 0.88, 0.12) > 0.5:
                color = (122, 78, 45, 255)
            if rounded_rect_alpha(x, y, 0.21, 0.18, 0.81, 0.85, 0.10) > 0.5:
                color = (245, 175, 198, 255)
            if rounded_rect_alpha(x, y, 0.26, 0.22, 0.76, 0.35, 0.05) > 0.5:
                color = (255, 224, 232, 255)

            if rounded_rect_alpha(x, y, 0.28, 0.34, 0.74, 0.67, 0.03) > 0.5:
                color = (50, 49, 43, 255)
            if rounded_rect_alpha(x, y, 0.31, 0.37, 0.71, 0.64, 0.02) > 0.5:
                color = (217, 208, 138, 255)

            if rounded_rect_alpha(x, y, 0.43, 0.45, 0.57, 0.57, 0.02) > 0.5:
                color = (50, 49, 43, 255)
            if rect_alpha(x, y, 0.39, 0.42, 0.46, 0.49) or rect_alpha(x, y, 0.54, 0.42, 0.61, 0.49):
                color = (50, 49, 43, 255)
            if rect_alpha(x, y, 0.46, 0.50, 0.48, 0.52) or rect_alpha(x, y, 0.52, 0.50, 0.54, 0.52):
                color = (217, 208, 138, 255)
            if rect_alpha(x, y, 0.48, 0.56, 0.53, 0.575):
                color = (217, 208, 138, 255)

            for cx, cy, radius in [(0.31, 0.28, 0.045), (0.69, 0.27, 0.035), (0.72, 0.73, 0.046)]:
                if star_alpha(x, y, cx, cy, radius, radius * 0.45):
                    color = (255, 244, 184, 255)

            for cx in (0.36, 0.5, 0.64):
                if rounded_rect_alpha(x, y, cx - 0.042, 0.74, cx + 0.042, 0.82, 0.04) > 0.5:
                    color = (167, 139, 216, 255)

            pixels.append(color)
    return pixels


def draw_splash(size: int) -> list[RGBA]:
    pixels = draw_icon(size)
    overlay: RGBA = (255, 244, 236, 255)
    return [blend(pixel, overlay, 0.18) for pixel in pixels]


def generate_source_assets() -> None:
    icon = BRAND_DIR / "app_icon_1024.png"
    splash = BRAND_DIR / "splash_1024.png"
    if not icon.exists():
        write_png(icon, 1024, 1024, draw_icon(1024))
    if not splash.exists():
        write_png(splash, 1024, 1024, draw_splash(1024))


def generate_android_icons() -> None:
    densities = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    base = Path("android/app/src/main/res")
    if not base.exists():
        return

    for folder, size in densities.items():
        write_png(base / folder / "ic_launcher.png", size, size, draw_icon(size))

    values = base / "values"
    values.mkdir(parents=True, exist_ok=True)
    (values / "colors.xml").write_text(
        """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#FFF4EC</color>
</resources>
""",
        encoding="utf-8",
    )


def generate_ios_icons() -> None:
    app_icon_dir = Path("ios/Runner/Assets.xcassets/AppIcon.appiconset")
    if not app_icon_dir.exists():
        return

    entries = [
        ("Icon-App-20x20@1x.png", 20, "20x20", "1x", "iphone"),
        ("Icon-App-20x20@2x.png", 40, "20x20", "2x", "iphone"),
        ("Icon-App-20x20@3x.png", 60, "20x20", "3x", "iphone"),
        ("Icon-App-29x29@1x.png", 29, "29x29", "1x", "iphone"),
        ("Icon-App-29x29@2x.png", 58, "29x29", "2x", "iphone"),
        ("Icon-App-29x29@3x.png", 87, "29x29", "3x", "iphone"),
        ("Icon-App-40x40@1x.png", 40, "40x40", "1x", "iphone"),
        ("Icon-App-40x40@2x.png", 80, "40x40", "2x", "iphone"),
        ("Icon-App-40x40@3x.png", 120, "40x40", "3x", "iphone"),
        ("Icon-App-60x60@2x.png", 120, "60x60", "2x", "iphone"),
        ("Icon-App-60x60@3x.png", 180, "60x60", "3x", "iphone"),
        ("Icon-App-76x76@1x.png", 76, "76x76", "1x", "ipad"),
        ("Icon-App-76x76@2x.png", 152, "76x76", "2x", "ipad"),
        ("Icon-App-83.5x83.5@2x.png", 167, "83.5x83.5", "2x", "ipad"),
        ("Icon-App-1024x1024@1x.png", 1024, "1024x1024", "1x", "ios-marketing"),
    ]

    source_icon = BRAND_DIR / "app_icon_1024.png"
    for filename, pixel_size, _, _, _ in entries:
        target = app_icon_dir / filename
        if pixel_size == 1024 and source_icon.exists():
            shutil.copyfile(source_icon, target)
        else:
            write_png(target, pixel_size, pixel_size, draw_icon(pixel_size))

    images = [
        {
            "filename": filename,
            "idiom": idiom,
            "scale": scale,
            "size": point_size,
        }
        for filename, _, point_size, scale, idiom in entries
    ]
    contents = {
        "images": images,
        "info": {"author": "xcode", "version": 1},
    }
    import json

    (app_icon_dir / "Contents.json").write_text(
        json.dumps(contents, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--native", action="store_true", help="Also generate Android/iOS launcher icons when folders exist.")
    args = parser.parse_args()

    generate_source_assets()
    if args.native:
        generate_android_icons()
        generate_ios_icons()


if __name__ == "__main__":
    main()
