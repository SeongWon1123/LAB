#!/usr/bin/env python3
"""Download and verify release evidence artifacts from GitHub Actions."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import subprocess
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REPO = "SeongWon1123/LAB"
RUN_FIELDS = "databaseId,number,headSha,conclusion,status,url,workflowName,createdAt"


def run_command(args: list[str], *, cwd: Path = ROOT) -> str:
    result = subprocess.run(args, cwd=cwd, check=True, capture_output=True, text=True)
    return result.stdout


def current_commit() -> str:
    return run_command(["git", "rev-parse", "HEAD"]).strip()


def short_commit(commit: str) -> str:
    return commit[:12]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_key_value_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def latest_successful_run(repo: str, branch: str, workflow_name: str, commit: str, limit: int) -> dict[str, Any]:
    output = run_command(
        [
            "gh",
            "run",
            "list",
            "--repo",
            repo,
            "--branch",
            branch,
            "--json",
            RUN_FIELDS,
            "--limit",
            str(limit),
        ]
    )
    runs = json.loads(output)
    for run in runs:
        if (
            run.get("workflowName") == workflow_name
            and run.get("status") == "completed"
            and run.get("conclusion") == "success"
            and run.get("headSha") == commit
        ):
            return run
    raise RuntimeError(f"No successful {workflow_name} run found for commit {short_commit(commit)} on {branch}.")


def download_artifact(repo: str, run_id: int, artifact_name: str, output_dir: Path) -> Path:
    artifact_dir = output_dir / artifact_name
    if any(artifact_dir.rglob("*")):
        return artifact_dir
    artifact_dir.mkdir(parents=True, exist_ok=True)
    run_command(
        [
            "gh",
            "run",
            "download",
            str(run_id),
            "--repo",
            repo,
            "--name",
            artifact_name,
            "--dir",
            str(artifact_dir),
        ]
    )
    return artifact_dir


def find_unique(root: Path, filename: str) -> Path:
    matches = [path for path in root.rglob(filename) if path.is_file()]
    if not matches:
        raise FileNotFoundError(f"Could not find {filename} under {root}.")
    if len(matches) > 1:
        names = ", ".join(path.relative_to(root).as_posix() for path in matches[:5])
        raise RuntimeError(f"Expected one {filename} under {root}, found {len(matches)}: {names}")
    return matches[0]


def candidate_paths(root: Path, manifest_dir: Path, item: dict[str, Any]) -> list[Path]:
    paths: list[Path] = []
    for key in ("artifact_path", "repo_path"):
        value = item.get(key)
        if isinstance(value, str) and value:
            paths.append(root / value)
            paths.append(manifest_dir / value)
    return paths


def find_manifest_item_file(root: Path, manifest_path: Path, item: dict[str, Any]) -> Path:
    for path in candidate_paths(root, manifest_path.parent, item):
        if path.is_file():
            return path
    artifact_path = item.get("artifact_path") or item.get("repo_path")
    if isinstance(artifact_path, str) and artifact_path:
        return find_unique(root, Path(artifact_path).name)
    raise FileNotFoundError(f"Manifest item has no artifact_path or repo_path: {item}")


def verify_json_manifest_artifact(
    artifact_dir: Path,
    manifest_filename: str,
    items_key: str,
) -> dict[str, Any]:
    manifest_path = find_unique(artifact_dir, manifest_filename)
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    items = manifest.get(items_key)
    if not isinstance(items, list):
        raise RuntimeError(f"{manifest_filename} missing list field {items_key}.")

    checks: list[dict[str, Any]] = []
    for item in items:
        if not isinstance(item, dict):
            raise RuntimeError(f"{manifest_filename} contains a non-object item.")
        path = find_manifest_item_file(artifact_dir, manifest_path, item)
        expected_sha = item.get("sha256")
        expected_size = item.get("size_bytes")
        actual_sha = sha256(path)
        actual_size = path.stat().st_size
        if expected_sha != actual_sha:
            raise RuntimeError(f"{path} SHA-256 mismatch: {actual_sha} != {expected_sha}")
        if expected_size != actual_size:
            raise RuntimeError(f"{path} size mismatch: {actual_size} != {expected_size}")
        checks.append(
            {
                "path": path.relative_to(artifact_dir).as_posix(),
                "size_bytes": actual_size,
                "sha256": actual_sha,
            }
        )

    return {
        "manifest": manifest_path.relative_to(artifact_dir).as_posix(),
        "artifact_name": manifest.get("artifact_name"),
        "count": len(checks),
        "checks": checks,
    }


def find_artifact_file(artifact_dir: Path, expected_name: str) -> Path:
    path = artifact_dir / expected_name
    if path.is_file():
        return path
    return find_unique(artifact_dir, expected_name)


def verify_native_file(
    manifest: dict[str, str],
    artifact_dir: Path,
    expected_name_key: str,
    expected_size_key: str,
    expected_sha_key: str,
) -> dict[str, Any]:
    filename = Path(manifest[expected_name_key]).name
    path = find_artifact_file(artifact_dir, filename)
    actual_size = path.stat().st_size
    actual_sha = sha256(path)
    expected_size = int(manifest[expected_size_key])
    expected_sha = manifest[expected_sha_key]
    if actual_size != expected_size:
        raise RuntimeError(f"{filename} size mismatch: {actual_size} != {expected_size}")
    if actual_sha != expected_sha:
        raise RuntimeError(f"{filename} SHA-256 mismatch: {actual_sha} != {expected_sha}")
    return {
        "path": path.relative_to(artifact_dir).as_posix(),
        "size_bytes": actual_size,
        "sha256": actual_sha,
    }


def verify_android(native_artifacts: dict[str, Path]) -> dict[str, Any]:
    manifest_path = find_unique(native_artifacts["android_manifest"], "android-manifest.txt")
    manifest = parse_key_value_file(manifest_path)
    return {
        "manifest": manifest_path.relative_to(native_artifacts["android_manifest"]).as_posix(),
        "run_number": manifest.get("run_number"),
        "commit": manifest.get("commit"),
        "debug_apk": verify_native_file(
            manifest,
            native_artifacts["android_debug"],
            "debug_apk_path",
            "debug_apk_size_bytes",
            "debug_apk_sha256",
        ),
        "release_aab": verify_native_file(
            manifest,
            native_artifacts["android_release"],
            "release_aab_path",
            "release_aab_size_bytes",
            "release_aab_sha256",
        ),
    }


def verify_ios(native_artifacts: dict[str, Path]) -> dict[str, Any]:
    manifest_path = find_unique(native_artifacts["ios_manifest"], "ios-manifest.txt")
    manifest = parse_key_value_file(manifest_path)
    smoke_path = find_unique(native_artifacts["ios_smoke"], "ios-simulator-smoke.txt")
    smoke = parse_key_value_file(smoke_path)
    launch_result = manifest.get("simulator_launch_result") or smoke.get("launch_result")
    if launch_result != "passed":
        raise RuntimeError(f"iOS simulator smoke launch did not pass: {launch_result}")

    return {
        "manifest": manifest_path.relative_to(native_artifacts["ios_manifest"]).as_posix(),
        "smoke_log": smoke_path.relative_to(native_artifacts["ios_smoke"]).as_posix(),
        "run_number": manifest.get("run_number"),
        "commit": manifest.get("commit"),
        "simulator_launch_result": launch_result,
        "simulator_app": verify_native_file(
            manifest,
            native_artifacts["ios_simulator"],
            "simulator_zip",
            "simulator_zip_size_bytes",
            "simulator_zip_sha256",
        ),
        "release_nocodesign_app": verify_native_file(
            manifest,
            native_artifacts["ios_release"],
            "release_nocodesign_zip",
            "release_nocodesign_zip_size_bytes",
            "release_nocodesign_zip_sha256",
        ),
    }


def write_report(report: dict[str, Any], output_dir: Path) -> None:
    report_json = output_dir / "release_artifact_report.json"
    report_txt = output_dir / "release_artifact_report.txt"
    report_json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    lines = [
        "Pocket Memory Pet release artifact verification",
        f"repository={report['repository']}",
        f"commit={report['commit']}",
        f"generated_utc={report['generated_utc']}",
        f"flutter_ci_run={report['runs']['flutter_ci']['number']} {report['runs']['flutter_ci']['url']}",
        f"native_build_run={report['runs']['native_build']['number']} {report['runs']['native_build']['url']}",
        "",
        f"brand_assets_verified={report['flutter_artifacts']['brand_assets']['count']}",
        f"store_screenshots_verified={report['flutter_artifacts']['store_screenshots']['count']}",
        f"android_debug_apk_sha256={report['native_artifacts']['android']['debug_apk']['sha256']}",
        f"android_release_aab_sha256={report['native_artifacts']['android']['release_aab']['sha256']}",
        f"ios_simulator_app_sha256={report['native_artifacts']['ios']['simulator_app']['sha256']}",
        f"ios_release_nocodesign_sha256={report['native_artifacts']['ios']['release_nocodesign_app']['sha256']}",
        f"ios_simulator_launch_result={report['native_artifacts']['ios']['simulator_launch_result']}",
        "",
        "External blockers still requiring human/device/account work:",
    ]
    for blocker in report["external_blockers"]:
        lines.append(f"- {blocker}")
    report_txt.write_text("\n".join(lines) + "\n", encoding="utf-8")


def build_report(repo: str, branch: str, output_root: Path, limit: int) -> dict[str, Any]:
    commit = current_commit()
    flutter_run = latest_successful_run(repo, branch, "Flutter CI", commit, limit)
    native_run = latest_successful_run(repo, branch, "Native Build", commit, limit)

    output_root = output_root if output_root.is_absolute() else ROOT / output_root
    output_dir = output_root / f"{short_commit(commit)}-flutter{flutter_run['number']}-native{native_run['number']}"
    output_dir.mkdir(parents=True, exist_ok=True)

    flutter_number = str(flutter_run["number"])
    native_number = str(native_run["number"])

    brand_dir = download_artifact(repo, flutter_run["databaseId"], f"brand-assets-{flutter_number}", output_dir)
    screenshots_dir = download_artifact(
        repo,
        flutter_run["databaseId"],
        f"store-screenshot-drafts-{flutter_number}",
        output_dir,
    )

    native_artifacts = {
        "android_debug": download_artifact(repo, native_run["databaseId"], f"android-debug-apk-{native_number}", output_dir),
        "android_release": download_artifact(repo, native_run["databaseId"], f"android-release-aab-{native_number}", output_dir),
        "android_manifest": download_artifact(repo, native_run["databaseId"], f"android-qa-manifest-{native_number}", output_dir),
        "ios_simulator": download_artifact(repo, native_run["databaseId"], f"ios-simulator-app-{native_number}", output_dir),
        "ios_smoke": download_artifact(repo, native_run["databaseId"], f"ios-simulator-smoke-{native_number}", output_dir),
        "ios_release": download_artifact(
            repo,
            native_run["databaseId"],
            f"ios-release-nocodesign-app-{native_number}",
            output_dir,
        ),
        "ios_manifest": download_artifact(repo, native_run["databaseId"], f"ios-qa-manifest-{native_number}", output_dir),
    }

    report = {
        "schema_version": 1,
        "app": "Pocket Memory Pet",
        "repository": repo,
        "branch": branch,
        "commit": commit,
        "generated_utc": dt.datetime.now(dt.timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z"),
        "output_dir": output_dir.relative_to(ROOT).as_posix(),
        "runs": {
            "flutter_ci": flutter_run,
            "native_build": native_run,
        },
        "flutter_artifacts": {
            "brand_assets": verify_json_manifest_artifact(brand_dir, "brand_asset_manifest.json", "assets"),
            "store_screenshots": verify_json_manifest_artifact(
                screenshots_dir,
                "store_screenshot_manifest.json",
                "screenshots",
            ),
        },
        "native_artifacts": {
            "android": verify_android(native_artifacts),
            "ios": verify_ios(native_artifacts),
        },
        "external_blockers": [
            "Manual device/simulator QA must be recorded in docs/qa/MANUAL_QA_LOG.md.",
            "Final store screenshots still require simulator/device review and final export.",
            "TestFlight upload requires Apple Developer Program signing and App Store Connect access.",
        ],
    }
    write_report(report, output_dir)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", default=DEFAULT_REPO)
    parser.add_argument("--branch", default="main")
    parser.add_argument("--limit", type=int, default=30)
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "build" / "release_artifacts",
        help="Directory for downloaded artifacts and verification reports.",
    )
    args = parser.parse_args()

    report = build_report(args.repo, args.branch, args.output, args.limit)
    output_dir = ROOT / report["output_dir"]
    print(f"Verified release artifacts for {short_commit(report['commit'])}.")
    print(f"Flutter CI run: {report['runs']['flutter_ci']['number']}")
    print(f"Native Build run: {report['runs']['native_build']['number']}")
    print(f"Wrote {output_dir / 'release_artifact_report.json'}")
    print(f"Wrote {output_dir / 'release_artifact_report.txt'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
