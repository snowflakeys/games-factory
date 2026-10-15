#!/usr/bin/env python3
"""Install the pinned Roblox tools inside this repository (Python 3.11+ only)."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import stat
import sys
import tempfile
import time
from typing import Sequence
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen
import zipfile


REPO_ROOT = Path(__file__).resolve().parents[1]
TOOL_NAMES = ("rojo", "selene", "stylua", "lune")
MAX_DOWNLOAD_BYTES = 256 * 1024 * 1024


class BootstrapError(RuntimeError):
    """An actionable toolchain setup error."""


def platform_key() -> str:
    """Return the supported release-asset platform, rejecting other machines."""
    system = platform.system().lower()
    machine = platform.machine().lower()
    if system not in {"windows", "linux"} or machine not in {"amd64", "x86_64"}:
        raise BootstrapError(
            f"Unsupported platform: {system}/{machine}. "
            "Pinned tools support Windows x86_64 and Linux x86_64."
        )
    return f"{system}-x86_64"


def file_sha256(path: Path) -> str:
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def _read_manifest(repo_root: Path) -> dict:
    path = repo_root / "toolchain.lock.json"
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        raise BootstrapError(f"Cannot read {path}: {exc}") from exc
    if not isinstance(manifest, dict) or manifest.get("schema_version") != 1:
        raise BootstrapError("toolchain.lock.json must use schema_version 1.")
    if not isinstance(manifest.get("tools"), dict):
        raise BootstrapError("toolchain.lock.json is missing its tools mapping.")
    return manifest


def _asset_for(manifest: dict, name: str, target: str) -> tuple[dict, dict]:
    tool = manifest["tools"].get(name)
    if not isinstance(tool, dict) or not isinstance(tool.get("assets"), dict):
        raise BootstrapError(f"Missing tool pin: {name}.")
    asset = tool["assets"].get(target)
    if not isinstance(asset, dict):
        raise BootstrapError(f"Missing {target} asset for {name}.")
    digest = asset.get("sha256")
    if not isinstance(digest, str) or not re.fullmatch(r"[0-9a-f]{64}", digest):
        raise BootstrapError(f"Missing or invalid SHA-256 digest for {name}/{target}.")
    expected_binary = name + (".exe" if target.startswith("windows-") else "")
    if asset.get("binary") != expected_binary:
        raise BootstrapError(f"Expected binary {expected_binary!r} for {name}/{target}.")
    repository = tool.get("repository", "")
    version = tool.get("version")
    if not isinstance(repository, str) or not re.fullmatch(r"[\w.-]+/[\w.-]+", repository):
        raise BootstrapError(f"Invalid official repository pin for {name}.")
    if not isinstance(version, str) or not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
        raise BootstrapError(f"Invalid version pin for {name}.")
    url = asset.get("url")
    if not isinstance(url, str):
        raise BootstrapError(f"Missing download URL for {name}/{target}.")
    release_url = tool.get("release_url")
    if not isinstance(release_url, str):
        raise BootstrapError(f"Missing official release URL for {name}.")
    release = urlparse(release_url)
    tag = release.path.rsplit("/", 1)[-1]
    if (
        release.scheme != "https"
        or release.netloc != "github.com"
        or release.path != f"/{repository}/releases/tag/{tag}"
        or tag not in {version, f"v{version}"}
        or release.query
        or release.fragment
    ):
        raise BootstrapError(f"Invalid official release URL for {name}.")
    parsed = urlparse(url)
    prefix = f"/{repository}/releases/download/{tag}/"
    if (
        parsed.scheme != "https"
        or parsed.netloc != "github.com"
        or not parsed.path.startswith(prefix)
        or "/" in parsed.path[len(prefix) :]
        or not parsed.path.endswith(".zip")
        or parsed.query
        or parsed.fragment
    ):
        raise BootstrapError(f"Invalid pinned GitHub release URL for {name}/{target}.")
    return tool, asset


def _pin_key(tool: dict, asset: dict, target: str) -> str:
    payload = {
        "version": tool["version"],
        "repository": tool["repository"],
        "platform": target,
        **asset,
    }
    return hashlib.sha256(json.dumps(payload, sort_keys=True).encode()).hexdigest()


def _load_installed(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if data.get("schema_version") == 1 and isinstance(data.get("tools"), dict):
            return data
    except (OSError, ValueError, AttributeError):
        pass
    return {"schema_version": 1, "tools": {}}


def _atomic_json(path: Path, value: dict) -> None:
    temporary: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w", encoding="utf-8", dir=path.parent, suffix=".tmp", delete=False
        ) as output:
            temporary = Path(output.name)
            json.dump(value, output, indent=2, sort_keys=True)
            output.write("\n")
        os.replace(temporary, path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def _download_archive(asset: dict, directory: Path) -> Path:
    archive = directory / f"{asset['sha256']}.zip"
    if archive.is_file() and file_sha256(archive) == asset["sha256"]:
        return archive
    directory.mkdir(parents=True, exist_ok=True)
    for attempt in range(3):
        try:
            return _fetch_archive(asset, directory, archive)
        except (HTTPError, URLError, TimeoutError, ConnectionError) as exc:
            transient = not isinstance(exc, HTTPError) or exc.code in {408, 429, 500, 502, 503, 504}
            if not transient or attempt == 2:
                raise
            print(f"Download interrupted; retrying ({attempt + 1}/2): {exc}", flush=True)
            time.sleep(attempt + 1)
    raise BootstrapError("Download attempts exhausted.")


def _fetch_archive(asset: dict, directory: Path, archive: Path) -> Path:
    temporary: Path | None = None
    try:
        request = Request(asset["url"], headers={"User-Agent": "Game-Factory-bootstrap/1"})
        with urlopen(request, timeout=60) as response:
            if urlparse(response.url).scheme != "https":
                raise BootstrapError("Refusing a download redirected outside HTTPS.")
            with tempfile.NamedTemporaryFile(dir=directory, suffix=".part", delete=False) as output:
                temporary = Path(output.name)
                total = 0
                digest = hashlib.sha256()
                while chunk := response.read(1024 * 1024):
                    total += len(chunk)
                    if total > MAX_DOWNLOAD_BYTES:
                        raise BootstrapError("Tool archive exceeds the 256 MiB size limit.")
                    digest.update(chunk)
                    output.write(chunk)
        if digest.hexdigest() != asset["sha256"]:
            raise BootstrapError(f"SHA-256 mismatch for {asset['url']}; no binary installed.")
        os.replace(temporary, archive)
        return archive
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def _install_binary(archive: Path, binary_name: str, destination: Path) -> str:
    temporary: Path | None = None
    try:
        with zipfile.ZipFile(archive) as source:
            matches = [entry for entry in source.infolist() if entry.filename == binary_name]
            if len(matches) != 1:
                raise BootstrapError(f"Archive must contain exactly one root-level {binary_name}.")
            entry = matches[0]
            if (
                entry.is_dir()
                or stat.S_ISLNK(entry.external_attr >> 16)
                or entry.file_size > MAX_DOWNLOAD_BYTES
                or entry.flag_bits & 1
            ):
                raise BootstrapError(f"Invalid binary entry in archive: {binary_name}.")
            # Open only the exact expected member. Never extract arbitrary paths.
            with source.open(entry) as binary:
                with tempfile.NamedTemporaryFile(
                    dir=destination.parent, suffix=".tmp", delete=False
                ) as output:
                    temporary = Path(output.name)
                    shutil.copyfileobj(binary, output, length=1024 * 1024)
        temporary.chmod(0o755)
        digest = file_sha256(temporary)
        os.replace(temporary, destination)
        return digest
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def ensure_tools(
    repo_root: Path | None = None,
    tool_names: Sequence[str] | None = None,
    force: bool = False,
) -> dict[str, Path]:
    """Verify/install tools and return absolute paths; never change the global PATH."""
    if sys.version_info < (3, 11):
        raise BootstrapError("Python 3.11 or newer is required.")
    root = Path(repo_root or REPO_ROOT).resolve()
    target = platform_key()
    names = tuple(dict.fromkeys(TOOL_NAMES if tool_names is None else tool_names))
    unknown = set(names) - set(TOOL_NAMES)
    if unknown:
        raise BootstrapError(f"Unknown tools: {', '.join(sorted(unknown))}.")
    manifest = _read_manifest(root)
    # Validate every selected pin before downloading or installing anything.
    pins = {name: _asset_for(manifest, name, target) for name in names}
    tools_directory = root / ".tools"
    binary_directory = tools_directory / "bin"
    binary_directory.mkdir(parents=True, exist_ok=True)
    installed_path = tools_directory / "installed.json"
    installed = _load_installed(installed_path)
    paths: dict[str, Path] = {}
    for name, (tool, asset) in pins.items():
        destination = binary_directory / asset["binary"]
        key = _pin_key(tool, asset, target)
        record = installed["tools"].get(name, {})
        if (
            not force
            and isinstance(record, dict)
            and record.get("pin_key") == key
            and destination.is_file()
            and file_sha256(destination) == record.get("binary_sha256")
        ):
            if os.name != "nt" and not os.access(destination, os.X_OK):
                destination.chmod(0o755)
            print(f"Verified {name} {tool['version']}", flush=True)
        else:
            print(f"Installing {name} {tool['version']} ({target})...", flush=True)
            archive = _download_archive(asset, root / "work" / "tool-downloads")
            binary_digest = _install_binary(archive, asset["binary"], destination)
            installed["tools"][name] = {
                "version": tool["version"],
                "platform": target,
                "pin_key": key,
                "binary_sha256": binary_digest,
            }
            _atomic_json(installed_path, installed)
        paths[name] = destination
    return paths


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tools", nargs="*", metavar="TOOL", help=f"default: {', '.join(TOOL_NAMES)}")
    parser.add_argument("--force", action="store_true", help="reinstall from verified archives")
    args = parser.parse_args(argv)
    try:
        ensure_tools(tool_names=args.tools or None, force=args.force)
    except (BootstrapError, OSError, ValueError, zipfile.BadZipFile) as exc:
        print(f"Bootstrap failed: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
