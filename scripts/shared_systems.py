"""Install and verify explicit, versioned copies of pure Luau systems."""

import argparse
import hashlib
import json
import re
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]
NAME = r"[a-z][a-z0-9]*(?:-[a-z0-9]+)*"
VERSION = r"\d+\.\d+\.\d+"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def safe_path(root, relative):
    require(isinstance(relative, str) and relative and "\\" not in relative
            and not PurePosixPath(relative).is_absolute()
            and all(part not in {"", ".", ".."} for part in relative.split("/")),
            "Unsafe shared-system path")
    result = root / relative
    require(not any(part.is_symlink() for part in [result, *result.parents] if part != root.parent),
            "Shared-system symlinks are not allowed")
    require(result.resolve().is_relative_to(root.resolve()), "Shared-system path escapes root")
    return result


def package(root, name, version):
    require(isinstance(name, str) and re.fullmatch(NAME, name), "Invalid shared-system name")
    require(isinstance(version, str) and re.fullmatch(VERSION, version), "Pin an exact shared-system version")
    folder = safe_path(root, f"shared-systems/{name}/{version}")
    manifest = read(safe_path(folder, "manifest.json"))
    require(manifest.get("schema_version") == 1 and manifest.get("name") == name
            and manifest.get("version") == version, "Shared-system manifest identity mismatch")
    modules = manifest.get("modules")
    require(isinstance(modules, list) and modules
            and all(isinstance(item, str) and item.endswith(".luau") for item in modules)
            and len(modules) == len(set(modules)),
            "Shared system must declare its Luau modules")
    for relative in [*modules, "README.md", "tests/run.luau"]:
        require(safe_path(folder, relative).is_file(), f"Missing shared-system contract/source/test: {relative}")
    dependencies = manifest.get("dependencies")
    require(isinstance(dependencies, dict) and all(re.fullmatch(NAME, key)
            and isinstance(value, str) and re.fullmatch(VERSION, value)
            for key, value in dependencies.items()), "Invalid shared-system dependency versions")
    digest = hashlib.sha256()
    # Path ordering is case-insensitive on Windows. Hash the same canonical
    # relative-name order everywhere, retaining the original Linux pins.
    for path in sorted(folder.rglob("*"), key=lambda item: item.relative_to(folder).as_posix()):
        require(not path.is_symlink(), "Shared-system symlinks are not allowed")
        if path.is_file():
            digest.update(path.relative_to(folder).as_posix().encode("utf-8") + b"\0")
            digest.update(path.read_bytes() + b"\0")
    return folder, manifest, digest.hexdigest()


def catalog(root=ROOT):
    packages = []
    for path in sorted((root / "shared-systems").glob("*/*/manifest.json")):
        folder, manifest, _ = package(root, path.parent.parent.name, path.parent.name)
        for name, version in manifest["dependencies"].items():
            package(root, name, version)
        packages.append(folder)
    declared = {folder / module for folder in packages for module in read(folder / "manifest.json")["modules"]}
    actual = {path for path in (root / "shared-systems").rglob("*.luau") if "tests" not in path.relative_to(root / "shared-systems").parts}
    require(actual == declared, "Unmanifested shared-system source")
    return packages


def validate_lock(root, game_folder, lock):
    require(lock.get("schema_version") == 1 and isinstance(lock.get("systems"), list), "Invalid shared-system lock")
    entries = lock["systems"]
    names, destinations = set(), set()
    for entry in entries:
        require(isinstance(entry, dict) and all(isinstance(entry.get(key), str) and entry[key].strip()
                for key in ("name", "version", "source", "sha256")), "unpinned shared system")
        name, version = entry["name"], entry["version"]
        require(name not in names, "Duplicate shared-system pin")
        names.add(name)
        require(entry["source"] == f"shared-systems/{name}/{version}", "Shared-system source must match its version")
        folder, manifest, digest = package(root, name, version)
        require(entry["sha256"] == digest, f"Shared-system package digest mismatch: {name}")
        files = entry.get("files")
        require(isinstance(files, dict) and set(files) == set(manifest["modules"]), "Shared-system copy map must cover declared modules")
        for source, destination in files.items():
            require(isinstance(destination, str) and destination.startswith("src/"), "Shared-system destination must be game source")
            require(destination not in destinations, "Shared-system copies overlap")
            destinations.add(destination)
            copied = safe_path(game_folder, destination)
            require(copied.is_file() and copied.read_bytes() == safe_path(folder, source).read_bytes(),
                    f"Shared-system vendored copy differs: {name}/{source}")
        for dependency, version in manifest["dependencies"].items():
            require(any(item.get("name") == dependency and item.get("version") == version for item in entries),
                    f"Missing pinned dependency for {name}: {dependency}@{version}")
    installed = {path.relative_to(game_folder).as_posix() for path in (game_folder / "src").rglob("Systems/*.luau")}
    require(installed <= destinations, "Unpinned module in game Systems directory")


def install(root, game_id, name, version, destination):
    require(game_id in read(root / "factory-state/state.json")["games"], "Install into a registered game")
    catalog(root)
    folder, manifest, digest = package(root, name, version)
    game_folder = safe_path(root, f"games/{game_id}")
    lock_path = game_folder / "shared-systems.lock.json"
    lock = read(lock_path)
    require(not any(entry["name"] == name for entry in lock["systems"]), "Already pinned; perform upgrades as reviewed copy/lock changes")
    files = {module: f"{destination}/{module}" for module in manifest["modules"]}
    targets = [(safe_path(folder, source), safe_path(game_folder, target)) for source, target in files.items()]
    require(all(target.relative_to(game_folder).as_posix().startswith("src/") and not target.exists()
                for _, target in targets), "Install requires unused paths inside game src")
    lock["systems"].append({"name": name, "version": version, "source": f"shared-systems/{name}/{version}",
                            "sha256": digest, "files": files})
    for source, target in targets:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(source.read_bytes())
    lock_path.write_text(json.dumps(lock, indent=4) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("verify")
    command = sub.add_parser("install")
    for argument in ("game", "name", "version", "destination"):
        command.add_argument(argument)
    args = parser.parse_args()
    if args.command == "install":
        install(ROOT, args.game, args.name, args.version, args.destination)
    else:
        packages = catalog()
        for game_id in read(ROOT / "factory-state/state.json")["games"]:
            folder = ROOT / "games" / game_id
            validate_lock(ROOT, folder, read(folder / "shared-systems.lock.json"))
        print(f"PASS: {len(packages)} versioned packages and every game's pinned copies")


if __name__ == "__main__":
    main()
