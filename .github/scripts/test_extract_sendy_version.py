#!/usr/bin/env python3
"""Tests for the Sendy update-page version parser."""

from __future__ import annotations

import unittest

from extract_sendy_version import extract_latest_version


def update_page(download_version: str, changelog_version: str) -> str:
    return f"""
        <html>
          <body>
            <div id="download-latest-version">
              <h2>Download latest version (<span>v{download_version}</span>)</h2>
              <p>Download Sendy using your license key.</p>
            </div>
            <div id="latest-version-changelog">
              <div class="accordion-body">
                <h3 class="version-num latest-changes">{changelog_version}</h3>
                <h3 class="version-num">6.0.0</h3>
              </div>
            </div>
          </body>
        </html>
    """


class ExtractLatestVersionTest(unittest.TestCase):
    def test_extracts_supported_dotted_versions(self) -> None:
        for version in ("7.1", "7.1.1", "6.0.7.2"):
            with self.subTest(version=version):
                self.assertEqual(version, extract_latest_version(update_page(version, version)))

    def test_rejects_disagreeing_version_signals(self) -> None:
        with self.assertRaisesRegex(ValueError, "version signals disagree"):
            extract_latest_version(update_page("7.1.1", "7.1"))

    def test_rejects_missing_download_section(self) -> None:
        with self.assertRaisesRegex(ValueError, "#download-latest-version"):
            extract_latest_version(
                '<div id="latest-version-changelog">'
                '<h3 class="version-num latest-changes">7.1.1</h3></div>'
            )

    def test_rejects_missing_changelog_section(self) -> None:
        with self.assertRaisesRegex(ValueError, "#latest-version-changelog"):
            extract_latest_version(
                '<div id="download-latest-version">'
                "<h2>Download latest version (v7.1.1)</h2></div>"
            )

    def test_rejects_non_numeric_versions(self) -> None:
        with self.assertRaisesRegex(ValueError, "#download-latest-version"):
            extract_latest_version(update_page("latest", "latest"))


if __name__ == "__main__":
    unittest.main()
