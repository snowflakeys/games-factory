"""Offline integrity and extraction checks for the portable tool bootstrap."""

from contextlib import redirect_stdout
import hashlib
import io
import json
from pathlib import Path
import stat
import tempfile
import unittest
from unittest.mock import patch
import zipfile

from scripts import bootstrap


class DownloadResponse(io.BytesIO):
    url = "https://github.com/rojo-rbx/rojo/releases/download/v1.2.3/rojo.zip"


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        work = bootstrap.REPO_ROOT / "work"
        work.mkdir(exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(dir=work, prefix="bootstrap-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        # Every test must explicitly provide a fake response to use the downloader.
        network = patch.object(bootstrap, "urlopen", side_effect=AssertionError("Unexpected network access"))
        self.network = network.start()
        self.addCleanup(network.stop)
        output = redirect_stdout(io.StringIO())
        output.__enter__()
        self.addCleanup(output.__exit__, None, None, None)

    @staticmethod
    def asset(content=b"verified download"):
        return {
            "url": DownloadResponse.url,
            "sha256": hashlib.sha256(content).hexdigest(),
            "binary": "rojo",
        }

    def manifest(self, content=b"verified download"):
        return {
            "schema_version": 1,
            "tools": {
                "rojo": {
                    "version": "1.2.3",
                    "repository": "rojo-rbx/rojo",
                    "release_url": "https://github.com/rojo-rbx/rojo/releases/tag/v1.2.3",
                    "assets": {"linux-x86_64": self.asset(content)},
                },
            },
        }

    def make_archive(self, members):
        path = self.root / "fixture.zip"
        with zipfile.ZipFile(path, "w") as archive:
            for name, content in members:
                archive.writestr(name, content)
        return path

    def make_cached_install(self):
        binary = b"fixture executable, never run"
        archive = self.make_archive([("rojo", binary)])
        manifest = self.manifest(archive.read_bytes())
        (self.root / "toolchain.lock.json").write_text(json.dumps(manifest), encoding="utf-8")
        cache = self.root / "work" / "tool-downloads"
        cache.mkdir(parents=True)
        asset = manifest["tools"]["rojo"]["assets"]["linux-x86_64"]
        (cache / f"{asset['sha256']}.zip").write_bytes(archive.read_bytes())
        return binary

    def test_missing_or_malformed_digest_is_rejected(self):
        for value in (None, "", "a" * 63, "g" * 64, "sha256:" + "a" * 64):
            with self.subTest(digest=value):
                manifest = self.manifest()
                asset = manifest["tools"]["rojo"]["assets"]["linux-x86_64"]
                if value is None:
                    del asset["sha256"]
                else:
                    asset["sha256"] = value
                with self.assertRaisesRegex(bootstrap.BootstrapError, "SHA-256 digest"):
                    bootstrap._asset_for(manifest, "rojo", "linux-x86_64")

    def test_supported_platforms_are_normalized(self):
        for system, machine, expected in (
            ("Windows", "AMD64", "windows-x86_64"),
            ("Linux", "x86_64", "linux-x86_64"),
        ):
            with self.subTest(system=system, machine=machine):
                with patch.object(bootstrap.platform, "system", return_value=system):
                    with patch.object(bootstrap.platform, "machine", return_value=machine):
                        self.assertEqual(bootstrap.platform_key(), expected)

    def test_unsupported_os_or_architecture_is_rejected(self):
        for system, machine in (("Darwin", "x86_64"), ("Linux", "aarch64"), ("Windows", "ARM64")):
            with self.subTest(system=system, machine=machine):
                with patch.object(bootstrap.platform, "system", return_value=system):
                    with patch.object(bootstrap.platform, "machine", return_value=machine):
                        with self.assertRaisesRegex(bootstrap.BootstrapError, "Unsupported platform"):
                            bootstrap.platform_key()

    def test_only_expected_root_member_is_extracted(self):
        escaped = self.root.parent / f"{self.root.name}-escaped"
        self.addCleanup(escaped.unlink, missing_ok=True)
        archive = self.make_archive([
            (f"../{escaped.name}", b"must not extract"),
            ("other/readme.txt", b"must not extract"),
            ("rojo", b"expected binary"),
        ])
        destination = self.root / "rojo"
        digest = bootstrap._install_binary(archive, "rojo", destination)
        self.assertEqual(destination.read_bytes(), b"expected binary")
        self.assertEqual(digest, hashlib.sha256(b"expected binary").hexdigest())
        self.assertFalse(escaped.exists())
        self.assertFalse((self.root / "other").exists())

    def test_nested_or_traversal_binary_member_is_rejected(self):
        for member in ("nested/rojo", "../rojo"):
            with self.subTest(member=member):
                archive = self.make_archive([(member, b"must not extract")])
                destination = self.root / "rojo"
                with self.assertRaisesRegex(bootstrap.BootstrapError, "root-level rojo"):
                    bootstrap._install_binary(archive, "rojo", destination)
                self.assertFalse(destination.exists())

    def test_symlink_executable_is_rejected_without_replacing_existing_file(self):
        link = zipfile.ZipInfo("rojo")
        link.create_system = 3
        link.external_attr = (stat.S_IFLNK | 0o777) << 16
        archive = self.make_archive([(link, b"../../unexpected-target")])
        destination = self.root / "rojo"
        destination.write_bytes(b"existing binary")
        with self.assertRaisesRegex(bootstrap.BootstrapError, "Invalid binary entry"):
            bootstrap._install_binary(archive, "rojo", destination)
        self.assertEqual(destination.read_bytes(), b"existing binary")

    def test_valid_cached_archive_needs_no_download(self):
        content = b"verified download"
        asset = self.asset(content)
        cached = self.root / f"{asset['sha256']}.zip"
        cached.write_bytes(content)
        with patch.object(bootstrap, "_fetch_archive", side_effect=AssertionError("Cache was ignored")):
            self.assertEqual(bootstrap._download_archive(asset, self.root), cached)
        self.network.assert_not_called()

    def test_corrupt_cached_archive_is_replaced_by_verified_download(self):
        content = b"verified download"
        asset = self.asset(content)
        cached = self.root / f"{asset['sha256']}.zip"
        cached.write_bytes(b"corrupted cached bytes")
        with patch.object(bootstrap, "urlopen", return_value=DownloadResponse(content)) as request:
            result = bootstrap._download_archive(asset, self.root)
        request.assert_called_once()
        self.assertEqual(result, cached)
        self.assertEqual(cached.read_bytes(), content)
        self.assertEqual(list(self.root.glob("*.part")), [])

    def test_download_digest_mismatch_installs_nothing_and_cleans_temporary_file(self):
        with patch.object(bootstrap, "urlopen", return_value=DownloadResponse(b"incorrect bytes")):
            with self.assertRaisesRegex(bootstrap.BootstrapError, "SHA-256 mismatch"):
                bootstrap._download_archive(self.asset(), self.root)
        self.assertEqual(list(self.root.iterdir()), [])

    def test_unchanged_install_is_idempotent_and_does_not_download(self):
        expected = self.make_cached_install()
        with patch.object(bootstrap, "platform_key", return_value="linux-x86_64"):
            first = bootstrap.ensure_tools(self.root, ["rojo"])
            record = (self.root / ".tools" / "installed.json").read_bytes()
            with patch.object(bootstrap, "_download_archive", side_effect=AssertionError("Unexpected download")):
                with patch.object(bootstrap, "_install_binary", side_effect=AssertionError("Unexpected install")):
                    second = bootstrap.ensure_tools(self.root, ["rojo"])
        self.assertEqual(first, second)
        self.assertEqual(second["rojo"].read_bytes(), expected)
        self.assertEqual((self.root / ".tools" / "installed.json").read_bytes(), record)

    def test_tampered_installed_binary_is_detected_and_repaired(self):
        expected = self.make_cached_install()
        with patch.object(bootstrap, "platform_key", return_value="linux-x86_64"):
            path = bootstrap.ensure_tools(self.root, ["rojo"])["rojo"]
            path.write_bytes(b"tampered executable")
            with patch.object(bootstrap, "_install_binary", wraps=bootstrap._install_binary) as install:
                repaired = bootstrap.ensure_tools(self.root, ["rojo"])["rojo"]
        install.assert_called_once()
        self.assertEqual(repaired.read_bytes(), expected)
        self.network.assert_not_called()


if __name__ == "__main__":
    unittest.main()
