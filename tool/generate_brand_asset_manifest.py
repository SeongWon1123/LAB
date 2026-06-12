#!/usr/bin/env python3
"""Generate a manifest for validated Pocket Memory Pet brand assets."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
from pathlib import Path

from validate_brand_assets import BRAND_ASSETS, ROOT, png_info


MANIFEST_DIR = ROOT / "build" / "brand_assets"
MANIFEST_JSON = MANIFEST_DIR / "brand_asset_manifest.json"
MANIFEST_TXT = MANIFEST_DIR / "brand_asset_manifest.txt"


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def github_env(name: str) -> str:
    return os.environ.get(name, "")


def run_url(repository: str, run_id: str) -> str:
    if not repository or not run_id:
        return ""
    return f"https://github.com/{repository}/actions/runs/{run_id}"


def build_manifest() -> dict[str, object]:
    repository = github_env("GITHUB_REPOSITORY") or "SeongWon1123/LAB"
    run_number = github_env("GITHUB_RUN_NUMBER")
    run_id = github_env("GITHUB_RUN_ID")
    artifact_name = f"brand-assets-{run_number}" if run_number else "brand-assets-<run_number>"

    assets: list[dict[str, object]] = []
    for spec in BRAND_ASSETS:
        path = ROOT / spec.path
        if not path.is_file():
            raise FileNotFoundError(f"Missing validated brand asset: {spec.path.as_posix()}")
        info = png_info(path)
        assets.append(
            {
                "artifact_path": spec.path.as_posix(),
                "repo_path": spec.path.as_posix(),
                "role": spec.role,
                "width": info["width"],
                "height": info["height"],
                "format": "png",
                "png_bit_depth": info["png_bit_depth"],
                "png_color_type": info["png_color_type"],
                "has_alpha_channel": info["has_alpha_channel"],
                "has_srgb_chunk": info["has_srgb_chunk"],
                "size_bytes": path.stat().st_size,
                "sha256": sha256(path),
            }
        )

    return {
        "schema_version": 1,
        "app": "Pocket Memory Pet",
        "artifact_name": artifact_name,
        "repository": repository,
        "workflow": github_env("GITHUB_WORKFLOW") or "Flutter CI",
        "run_id": run_id,
        "run_number": run_number,
        "run_attempt": github_env("GITHUB_RUN_ATTEMPT"),
        "run_url": run_url(repository, run_id),
        "event_name": github_env("GITHUB_EVENT_NAME"),
        "commit": github_env("GITHUB_SHA"),
        "ref": github_env("GITHUB_REF"),
        "ref_name": github_env("GITHUB_REF_NAME"),
        "generated_utc": dt.datetime.now(dt.timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z"),
        "asset_count": len(assets),
        "assets": assets,
    }


def write_manifest(manifest: dict[str, object]) -> None:
    MANIFEST_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST_JSON.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    assets = manifest["assets"]
    assert isinstance(assets, list)
    lines = [
        "Pocket Memory Pet brand asset manifest",
        f"schema_version={manifest['schema_version']}",
        f"app={manifest['app']}",
        f"artifact_name={manifest['artifact_name']}",
        f"repository={manifest['repository']}",
        f"workflow={manifest['workflow']}",
        f"run_number={manifest['run_number']}",
        f"run_id={manifest['run_id']}",
        f"run_attempt={manifest['run_attempt']}",
        f"run_url={manifest['run_url']}",
        f"commit={manifest['commit']}",
        f"ref={manifest['ref']}",
        f"ref_name={manifest['ref_name']}",
        f"generated_utc={manifest['generated_utc']}",
        f"asset_count={manifest['asset_count']}",
        "",
    ]
    for item in assets:
        assert isinstance(item, dict)
        lines.append(
            "{artifact_path} role={role} {width}x{height} bit_depth={png_bit_depth} "
            "color_type={png_color_type} alpha={has_alpha_channel} "
            "srgb={has_srgb_chunk} {size_bytes} bytes sha256={sha256}".format(**item)
        )
    MANIFEST_TXT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    manifest = build_manifest()
    write_manifest(manifest)
    print(f"Wrote {MANIFEST_JSON.relative_to(ROOT)}.")
    print(f"Wrote {MANIFEST_TXT.relative_to(ROOT)}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
