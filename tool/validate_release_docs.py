#!/usr/bin/env python3
"""Validate release-facing docs for artifact drift and IP-safe copy."""

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

RELEASE_DOCS = [
    Path("README.md"),
    Path("docs/STORE_RELEASE_CHECKLIST.md"),
    Path("docs/TEST_PLAN.md"),
    Path("docs/PRIVACY_POLICY_DRAFT.md"),
    Path("docs/qa/MANUAL_QA_LOG.md"),
    Path("docs/store/APP_PRIVACY_DRAFT.md"),
    Path("docs/store/DATA_SAFETY_DRAFT.md"),
    Path("docs/store/SCREENSHOT_CAPTURE_PLAN.md"),
    Path("docs/store/STORE_METADATA.md"),
    Path("docs/store/TESTFLIGHT_PREP.md"),
]

BANNED_MARKETING_TERMS = [
    "bandai",
    "gotchi",
    "original tamagotchi",
    "tama pet",
    "tamagotchi",
]

REQUIRED_RELEASE_REFERENCES = [
    "android-debug-apk-<run_number>",
    "android-release-aab-<run_number>",
    "android-qa-manifest-<run_number>",
    "ios-simulator-app-<run_number>",
    "ios-release-nocodesign-app-<run_number>",
    "ios-qa-manifest-<run_number>",
    "store-screenshot-drafts-<run_number>",
]


def read(relative_path: Path) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def main() -> int:
    errors: list[str] = []
    combined_docs = "\n".join(read(path) for path in RELEASE_DOCS)
    combined_lower = combined_docs.lower()

    for term in BANNED_MARKETING_TERMS:
        if term in combined_lower:
            errors.append(f"Release docs contain banned brand-adjacent term: {term}")

    if "simctl install booted runner.app" in combined_lower:
        errors.append('iOS simulator install docs still point at "Runner.app".')

    if "Runner-simulator.app.zip" in combined_docs:
        errors.append("Release docs still point at stale Runner-simulator.app.zip.")
    if "Runner-release-nocodesign.app.zip" in combined_docs:
        errors.append("Release docs still point at stale Runner-release-nocodesign.app.zip.")

    if 'simctl install booted "pocket memory pet.app"' not in combined_lower:
        errors.append('iOS simulator install docs must quote "Pocket Memory Pet.app".')

    for reference in REQUIRED_RELEASE_REFERENCES:
        if reference not in combined_docs:
            errors.append(f"Missing release artifact reference: {reference}")

    workflow = read(Path(".github/workflows/native-build.yml"))
    if "Runner-simulator.app.zip" in workflow:
        errors.append("Native workflow must not use stale Runner-simulator.app.zip.")
    if "Runner-release-nocodesign.app.zip" in workflow:
        errors.append("Native workflow must not use stale Runner-release-nocodesign.app.zip.")
    if "Pocket-Memory-Pet-simulator.app.zip" not in workflow:
        errors.append("Native workflow must upload Pocket-Memory-Pet-simulator.app.zip.")
    if "Pocket-Memory-Pet-release-nocodesign.app.zip" not in workflow:
        errors.append("Native workflow must upload Pocket-Memory-Pet-release-nocodesign.app.zip.")

    if errors:
        print("Release document validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Release document validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
