#!/usr/bin/env python3
"""Generate a manifest for validated CI draft store screenshots."""

from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
from pathlib import Path

from validate_store_screenshots import ROOT, SCREENS, SCREENSHOT_DIR, TARGETS, png_size


MANIFEST_JSON = SCREENSHOT_DIR / "store_screenshot_manifest.json"
MANIFEST_TXT = SCREENSHOT_DIR / "store_screenshot_manifest.txt"


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


def expected_files() -> list[Path]:
    files: list[Path] = []
    for target in TARGETS:
        target_dir = SCREENSHOT_DIR / target
        for screen in SCREENS:
            path = target_dir / screen
            if not path.is_file():
                raise FileNotFoundError(f"Missing validated screenshot: {path.relative_to(ROOT)}")
            files.append(path)
    return files


def build_manifest(files: list[Path]) -> dict[str, object]:
    repository = github_env("GITHUB_REPOSITORY") or "SeongWon1123/LAB"
    run_number = github_env("GITHUB_RUN_NUMBER")
    run_id = github_env("GITHUB_RUN_ID")
    artifact_name = f"store-screenshot-drafts-{run_number}" if run_number else "store-screenshot-drafts-<run_number>"

    screenshots: list[dict[str, object]] = []
    for path in files:
        width, height = png_size(path)
        artifact_path = path.relative_to(SCREENSHOT_DIR).as_posix()
        screenshots.append(
            {
                "artifact_path": artifact_path,
                "repo_path": path.relative_to(ROOT).as_posix(),
                "target": path.parent.name,
                "screen": path.stem,
                "width": width,
                "height": height,
                "device_pixel_ratio": 1,
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
        "screenshot_count": len(screenshots),
        "targets": {name: {"width": size[0], "height": size[1]} for name, size in TARGETS.items()},
        "screenshots": screenshots,
    }


def write_manifest(manifest: dict[str, object]) -> None:
    MANIFEST_JSON.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")

    screenshots = manifest["screenshots"]
    assert isinstance(screenshots, list)
    lines = [
        "Pocket Memory Pet draft store screenshot manifest",
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
        f"screenshot_count={manifest['screenshot_count']}",
        "",
    ]
    for item in screenshots:
        assert isinstance(item, dict)
        lines.append(
            "{artifact_path} {width}x{height} dpr={device_pixel_ratio} "
            "{size_bytes} bytes sha256={sha256}".format(**item)
        )
    MANIFEST_TXT.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    manifest = build_manifest(expected_files())
    write_manifest(manifest)
    print(f"Wrote {MANIFEST_JSON.relative_to(ROOT)}.")
    print(f"Wrote {MANIFEST_TXT.relative_to(ROOT)}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
