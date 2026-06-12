#!/usr/bin/env python3
"""Validate the static store-support site before Pages deployment."""

from __future__ import annotations

import re
from html.parser import HTMLParser
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "site"
PAGES_BASE_URL = "https://seongwon1123.github.io/LAB"

REQUIRED_FILES = [
    Path("index.html"),
    Path("privacy/index.html"),
    Path("support/index.html"),
    Path("styles.css"),
]

BANNED_TERMS = [
    "bandai",
    "gotchi",
    "original tamagotchi",
    "tama pet",
    "tamagotchi",
]


class LinkParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag != "a":
            return
        for key, value in attrs:
            if key == "href" and value:
                self.links.append(value)


def read(relative_path: Path) -> str:
    return (SITE / relative_path).read_text(encoding="utf-8")


def main() -> int:
    errors: list[str] = []

    for relative_path in REQUIRED_FILES:
        path = SITE / relative_path
        if not path.is_file():
            errors.append(f"Missing site file: {relative_path}")

    if errors:
        print("Static site validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    site_text = "\n".join(read(path) for path in REQUIRED_FILES)
    site_lower = site_text.lower()
    normalized_site_text = re.sub(r"\s+", " ", site_text)

    for term in BANNED_TERMS:
        if term in site_lower:
            errors.append(f"Static site contains banned brand-adjacent term: {term}")

    for token in ["TODO", "TBD", "lorem ipsum"]:
        if token.lower() in site_lower:
            errors.append(f"Static site contains placeholder token: {token}")

    required_phrases = [
        "Pocket Memory Pet",
        "Privacy Policy",
        "Effective date: June 12, 2026",
        "does not require an account",
        "does not send pet data to a server",
        "Support",
        "https://github.com/SeongWon1123/LAB/issues",
    ]
    for phrase in required_phrases:
        if phrase not in normalized_site_text:
            errors.append(f"Missing static site phrase: {phrase}")

    for html_file in [Path("index.html"), Path("privacy/index.html"), Path("support/index.html")]:
        parser = LinkParser()
        parser.feed(read(html_file))
        if not parser.links:
            errors.append(f"{html_file} has no links.")
        for link in parser.links:
            if link.startswith(("http://", "https://")) and not link.startswith(
                ("https://github.com/SeongWon1123/LAB", PAGES_BASE_URL)
            ):
                errors.append(f"{html_file} links to an unexpected external URL: {link}")

    if errors:
        print("Static site validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Static site validation passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
