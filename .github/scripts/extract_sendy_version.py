#!/usr/bin/env python3
"""Extract and cross-check the latest Sendy version from the update page."""

from __future__ import annotations

import argparse
import re
import sys
from html.parser import HTMLParser
from pathlib import Path


VERSION_PATTERN = r"[0-9]+(?:\.[0-9]+)+"
DOWNLOAD_HEADING_PATTERN = re.compile(
    rf"^Download\s+latest\s+version\s*\(\s*v?({VERSION_PATTERN})\s*\)$",
    re.IGNORECASE,
)
CHANGELOG_VERSION_PATTERN = re.compile(rf"^v?({VERSION_PATTERN})$", re.IGNORECASE)


class SendyUpdatePageParser(HTMLParser):
    """Collect version signals from Sendy's dedicated update-page sections."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self._section: str | None = None
        self._section_div_depth = 0
        self._capture: str | None = None
        self._capture_text: list[str] = []
        self.download_headings: list[str] = []
        self.changelog_headings: list[str] = []

    def handle_starttag(
        self, tag: str, attrs: list[tuple[str, str | None]]
    ) -> None:
        attributes = dict(attrs)

        if tag == "div":
            element_id = attributes.get("id")
            if self._section is None and element_id == "download-latest-version":
                self._section = "download"
                self._section_div_depth = 1
            elif self._section is None and element_id == "latest-version-changelog":
                self._section = "changelog"
                self._section_div_depth = 1
            elif self._section is not None:
                self._section_div_depth += 1

        if self._section == "download" and tag == "h2":
            self._start_capture("download")
        elif self._section == "changelog" and tag == "h3":
            classes = set((attributes.get("class") or "").split())
            if {"version-num", "latest-changes"}.issubset(classes):
                self._start_capture("changelog")

    def handle_endtag(self, tag: str) -> None:
        if tag == "h2" and self._capture == "download":
            self._finish_capture(self.download_headings)
        elif tag == "h3" and self._capture == "changelog":
            self._finish_capture(self.changelog_headings)

        if tag == "div" and self._section is not None:
            self._section_div_depth -= 1
            if self._section_div_depth == 0:
                self._section = None

    def handle_data(self, data: str) -> None:
        if self._capture is not None:
            self._capture_text.append(data)

    def _start_capture(self, capture: str) -> None:
        self._capture = capture
        self._capture_text = []

    def _finish_capture(self, destination: list[str]) -> None:
        destination.append(" ".join("".join(self._capture_text).split()))
        self._capture = None
        self._capture_text = []


def extract_latest_version(html: str) -> str:
    parser = SendyUpdatePageParser()
    parser.feed(html)
    parser.close()

    download_versions = [
        match.group(1)
        for heading in parser.download_headings
        if (match := DOWNLOAD_HEADING_PATTERN.fullmatch(heading))
    ]
    changelog_versions = [
        match.group(1)
        for heading in parser.changelog_headings
        if (match := CHANGELOG_VERSION_PATTERN.fullmatch(heading))
    ]

    if len(download_versions) != 1:
        raise ValueError(
            "expected exactly one valid version in #download-latest-version, "
            f"found {len(download_versions)}"
        )
    if not changelog_versions:
        raise ValueError(
            "expected a valid version heading in #latest-version-changelog"
        )

    download_version = download_versions[0]
    changelog_version = changelog_versions[0]
    if download_version != changelog_version:
        raise ValueError(
            "Sendy update page version signals disagree: "
            f"download={download_version}, changelog={changelog_version}"
        )

    return download_version


def main() -> int:
    argument_parser = argparse.ArgumentParser(
        description="Extract the latest Sendy version from update-page HTML."
    )
    argument_parser.add_argument(
        "html_file",
        nargs="?",
        type=Path,
        help="HTML file to parse; reads standard input when omitted",
    )
    args = argument_parser.parse_args()

    try:
        html = (
            args.html_file.read_text(encoding="utf-8")
            if args.html_file
            else sys.stdin.read()
        )
        print(extract_latest_version(html))
    except (OSError, UnicodeError, ValueError) as error:
        print(f"Could not determine the latest Sendy version: {error}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
