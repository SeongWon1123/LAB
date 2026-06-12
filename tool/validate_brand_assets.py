#!/usr/bin/env python3
"""Validate generated Pocket Memory Pet brand and store listing assets."""

from __future__ import annotations

import struct
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class BrandAssetSpec:
    path: Path
    role: str
    width: int
    height: int
    png_bit_depth: int
    png_color_type: int
    requires_srgb: bool = True
    max_size_bytes: int | None = None


BRAND_ASSETS = [
    BrandAssetSpec(
        path=Path("assets/images/brand/app_icon_1024.png"),
        role="native_app_icon_source",
        width=1024,
        height=1024,
        png_bit_depth=8,
        png_color_type=2,
    ),
    BrandAssetSpec(
        path=Path("assets/images/brand/splash_1024.png"),
        role="native_splash_source",
        width=1024,
        height=1024,
        png_bit_depth=8,
        png_color_type=2,
    ),
    BrandAssetSpec(
        path=Path("store_assets/brand/play_icon_512.png"),
        role="google_play_store_icon",
        width=512,
        height=512,
        png_bit_depth=8,
        png_color_type=6,
        max_size_bytes=1024 * 1024,
    ),
    BrandAssetSpec(
        path=Path("store_assets/brand/feature_graphic_1024x500.png"),
        role="google_play_feature_graphic",
        width=1024,
        height=500,
        png_bit_depth=8,
        png_color_type=2,
    ),
]


def has_alpha_channel(color_type: int) -> bool:
    return color_type in {4, 6}


def png_info(path: Path) -> dict[str, int | bool]:
    with path.open("rb") as fh:
        data = fh.read()
    if len(data) < 33 or not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not a PNG")

    offset = 8
    width = height = bit_depth = color_type = compression = png_filter = interlace = None
    has_srgb_chunk = False
    found_ihdr = False
    found_iend = False
    while offset + 8 <= len(data):
        chunk_length = struct.unpack(">I", data[offset : offset + 4])[0]
        chunk_type = data[offset + 4 : offset + 8]
        chunk_start = offset + 8
        chunk_end = chunk_start + chunk_length
        if chunk_end + 4 > len(data):
            raise ValueError("truncated PNG chunk")
        chunk_data = data[chunk_start:chunk_end]

        if chunk_type == b"IHDR":
            if found_ihdr or chunk_length != 13:
                raise ValueError("invalid IHDR")
            found_ihdr = True
            width, height, bit_depth, color_type, compression, png_filter, interlace = struct.unpack(
                ">IIBBBBB", chunk_data
            )
        elif chunk_type == b"sRGB":
            has_srgb_chunk = True
        elif chunk_type == b"IEND":
            found_iend = True
            break

        offset = chunk_end + 4

    if not found_ihdr:
        raise ValueError("missing IHDR")
    if not found_iend:
        raise ValueError("missing IEND")
    assert width is not None
    assert height is not None
    assert bit_depth is not None
    assert color_type is not None
    assert compression is not None
    assert png_filter is not None
    assert interlace is not None
    if compression != 0 or png_filter != 0 or interlace not in {0, 1}:
        raise ValueError("unsupported PNG header values")

    return {
        "width": width,
        "height": height,
        "png_bit_depth": bit_depth,
        "png_color_type": color_type,
        "has_alpha_channel": has_alpha_channel(color_type),
        "has_srgb_chunk": has_srgb_chunk,
    }


def validate_asset(spec: BrandAssetSpec) -> list[str]:
    errors: list[str] = []
    path = ROOT / spec.path
    if not path.is_file():
        return [f"Missing brand asset: {spec.path.as_posix()}"]

    try:
        info = png_info(path)
    except ValueError as error:
        return [f"Invalid PNG {spec.path.as_posix()}: {error}"]

    expected = {
        "width": spec.width,
        "height": spec.height,
        "png_bit_depth": spec.png_bit_depth,
        "png_color_type": spec.png_color_type,
    }
    for key, expected_value in expected.items():
        if info[key] != expected_value:
            errors.append(
                f"Wrong {key} for {spec.path.as_posix()}: {info[key]}, expected {expected_value}"
            )
    if spec.requires_srgb and not info["has_srgb_chunk"]:
        errors.append(f"Missing sRGB PNG chunk: {spec.path.as_posix()}")

    size_bytes = path.stat().st_size
    if size_bytes <= 0:
        errors.append(f"Empty brand asset: {spec.path.as_posix()}")
    if spec.max_size_bytes is not None and size_bytes > spec.max_size_bytes:
        errors.append(
            f"{spec.path.as_posix()} is {size_bytes} bytes, expected at most {spec.max_size_bytes}"
        )

    return errors


def main() -> int:
    errors: list[str] = []
    for spec in BRAND_ASSETS:
        errors.extend(validate_asset(spec))

    if errors:
        print("Brand asset validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Brand asset validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
