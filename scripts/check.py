"""Run the same repository, formatting, lint, logic, and build checks as CI."""

import ast
import json
import subprocess
import sys
from pathlib import Path

from bootstrap import ensure_tools
from factory import ROOT, validate


def run(arguments, cwd=ROOT):
    print("+ " + " ".join(str(argument) for argument in arguments), flush=True)
    subprocess.run([str(argument) for argument in arguments], cwd=cwd, check=True)


def main():
    try:
        validate()
        print("PASS: factory files, state, WIP, and recorded human gates", flush=True)
        for folder in (ROOT / "scripts", ROOT / "tests"):
            for path in folder.rglob("*.py"):
                ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
        for folder in ("factory-state", "game-templates", "games"):
            for path in (ROOT / folder).rglob("*.json"):
                json.loads(path.read_text(encoding="utf-8"))
        run([sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v"])
        tools = ensure_tools()
        source_folders = [ROOT / "game-templates", ROOT / "games", ROOT / "shared-systems"]
        run([tools["stylua"], "--check", "--config-path", ROOT / ".stylua.toml", *source_folders])
        run([tools["selene"], *source_folders])
        state, _, _ = validate()
        projects = [("template-basic-round", ROOT / "game-templates/basic-round")]
        projects.extend((game_id, ROOT / "games" / game_id) for game_id in state["games"])
        build_folder = ROOT / "work/builds"
        build_folder.mkdir(parents=True, exist_ok=True)
        for name, folder in projects:
            run([tools["lune"], "run", "tests/run.luau"], cwd=folder)
            run([tools["rojo"], "build", "default.project.json", "--output", build_folder / f"{name}.rbxlx"], cwd=folder)
        print(f"PASS: all checks; {len(projects)} Rojo project(s) built locally. No place published.", flush=True)
    except (ValueError, OSError, KeyError, TypeError, subprocess.CalledProcessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
