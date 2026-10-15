"""Queue, scaffold, and validate the Game Factory without publishing anything."""

import argparse
import json
import re
import shutil
import tempfile
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAGES = (
    "SPEC-PENDING", "BUILDING", "DEV-COMPLETE", "PLAYTESTED",
    "RELEASE-READY", "LIVE", "WINNER", "DEAD",
)
PREPARATION = {"SPEC-PENDING", "BUILDING"}
GAME_FILES = (
    "game.json", "default.project.json", "spec.md", "decisions.md", "backlog.md",
    "assets-needed.md", "marketing.md", "completion-report.md", "playtest.md",
    "release-checklist.md", "metrics.md", "shared-systems.lock.json",
    "assets/README.md", "tests/run.luau", "tests/README.md",
)


def today():
    return datetime.now(timezone(timedelta(hours=3))).date().isoformat()


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=4, ensure_ascii=False) + "\n", encoding="utf-8")
    temporary.replace(path)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def evidence_valid(value):
    return isinstance(value, str) and bool(value.strip()) and value.strip().upper() not in {
        "PENDING", "TODO", "TBD", "NOT RUN", "NOT COMPLETE", "N/A",
    } and "{{" not in value


def dated_record_valid(value):
    if not isinstance(value, dict) or not evidence_valid(value.get("evidence")):
        return False
    try:
        return date.fromisoformat(value.get("at", "")).isoformat() == value["at"]
    except (ValueError, TypeError):
        return False


def approval_valid(value):
    return (
        isinstance(value, dict)
        and value.get("by") == "Snow"
        and dated_record_valid(value)
    )


def game_records(root, state):
    return [read_json(root / "games" / game_id / "game.json") for game_id in state["games"]]


def validate(root=ROOT):
    """Raise ValueError for inconsistent state or a missing recorded human gate."""
    root = Path(root)
    for relative in (
        "AGENTS.md", "CLAUDE.md", "README.md", "factory-state/checkpoint.md",
        "agent-instructions/art-style-bible.md", "knowledge-base/README.md",
        "shared-systems/README.md", ".github/workflows/ci.yml",
    ):
        require((root / relative).is_file(), f"Missing required file: {relative}")
    state = read_json(root / "factory-state/state.json")
    queue = read_json(root / "factory-state/idea-queue.json")
    require(state.get("schema_version") == 1 and queue.get("schema_version") == 1,
            "Unsupported factory state schema")
    require(state.get("owner") == "Snow", "Factory owner must be Snow")
    require(state.get("max_waiting_for_playtest") == 2, "WIP cap must be 2")
    ids = state.get("games")
    require(isinstance(ids, list), "games must be an array of game IDs")
    require(all(isinstance(item, str) and re.fullmatch(r"game-\d{3,}", item) for item in ids),
            "Invalid game ID in registry")
    require(len(ids) == len(set(ids)), "Duplicate game ID in registry")
    folders = {item.name for item in (root / "games").glob("game-*") if item.is_dir()}
    require(folders == set(ids), "Game folders and factory registry differ")
    next_number = state.get("next_game_number")
    require(type(next_number) is int and next_number > 0, "Invalid next_game_number")
    require(all(next_number > int(item[5:]) for item in ids), "next_game_number would reuse an ID")

    ideas = queue.get("ideas")
    require(isinstance(ideas, list), "ideas must be an array")
    idea_ids = set()
    selected_games = set()
    for idea in ideas:
        require(isinstance(idea, dict), "Invalid queue entry")
        idea_id = idea.get("id")
        require(isinstance(idea_id, str) and re.fullmatch(r"idea-\d{3,}", idea_id), "Invalid idea ID")
        require(idea_id not in idea_ids, "Duplicate idea ID")
        idea_ids.add(idea_id)
        for field in ("name", "idea", "source"):
            require(isinstance(idea.get(field), str) and idea[field].strip(), f"{idea_id}: missing {field}")
        selected = idea.get("game_id")
        require(selected is None or selected in ids, f"{idea_id}: unknown selected game")
        if selected is not None:
            require(selected not in selected_games, "Game selected by multiple ideas")
            selected_games.add(selected)

    records = []
    for game_id in ids:
        folder = root / "games" / game_id
        for filename in GAME_FILES:
            require((folder / filename).is_file(), f"{game_id}: missing {filename}")
        require((folder / "src/server").is_dir() and (folder / "src/client").is_dir(),
                f"{game_id}: missing source directories")
        game = read_json(folder / "game.json")
        require(game.get("schema_version") == 1 and game.get("id") == game_id, f"{game_id}: invalid metadata")
        require(isinstance(game.get("name"), str) and game["name"].strip(), f"{game_id}: missing name")
        stage = game.get("stage")
        require(stage in STAGES, f"{game_id}: invalid stage")
        linked = [idea for idea in ideas if idea["id"] == game.get("idea_id") and idea.get("game_id") == game_id]
        require(len(linked) == 1, f"{game_id}: missing queue provenance")
        approvals = game.get("approvals")
        require(isinstance(approvals, dict), f"{game_id}: missing approval slots")
        for kind in ("spec", "playtest", "publish"):
            require(kind in approvals, f"{game_id}: missing {kind} approval slot")
            require(approvals[kind] is None or approval_valid(approvals[kind]), f"{game_id}: invalid {kind} evidence")
        if stage != "SPEC-PENDING":
            require(approval_valid(approvals["spec"]), f"{game_id}: Snow's spec approval required")
        if stage in {"DEV-COMPLETE", "PLAYTESTED", "RELEASE-READY", "LIVE", "WINNER"}:
            completion = game.get("completion")
            require(dated_record_valid(completion) and evidence_valid(completion.get("core_loop"))
                    and re.fullmatch(r"[0-9a-f]{40}", completion.get("revision", ""))
                    and completion.get("checks") == {"formatter": "PASS", "lint": "PASS", "logic": "PASS", "build": "PASS"},
                    f"{game_id}: completion and passing-check evidence required")
        if stage in {"PLAYTESTED", "RELEASE-READY", "LIVE", "WINNER"}:
            require(approval_valid(approvals["playtest"]), f"{game_id}: Snow's playtest evidence required")
        if stage in {"RELEASE-READY", "LIVE", "WINNER"}:
            require(approval_valid(approvals["publish"]), f"{game_id}: Snow's publish approval required")
            places = game.get("places", {})
            require(all(type(places.get(key)) is int and places[key] > 0 for key in ("test", "live")),
                    f"{game_id}: test and live place IDs required")
            require(places["test"] != places["live"], f"{game_id}: test and live places must differ")
            project = read_json(folder / "default.project.json")
            require(project.get("servePlaceIds") == [places["test"]],
                    f"{game_id}: restrict servePlaceIds to the test place")
        require(game.get("dead_reason") in {"NOT FUN", "NOT DISCOVERED"} if stage == "DEAD"
                else game.get("dead_reason") is None, f"{game_id}: invalid DEAD classification")
        lock = read_json(folder / "shared-systems.lock.json")
        require(lock.get("schema_version") == 1 and isinstance(lock.get("systems"), list),
                f"{game_id}: invalid shared-system lock")
        for system in lock["systems"]:
            require(isinstance(system, dict) and all(isinstance(system.get(key), str) and system[key].strip()
                    for key in ("name", "version", "source", "sha256")), f"{game_id}: unpinned shared system")
            require(re.fullmatch(r"[0-9a-f]{64}", system["sha256"]), f"{game_id}: invalid shared-system SHA-256")
        records.append(game)

    pending = [game["id"] for game in records if game["stage"] in PREPARATION]
    require(len(pending) <= 1, "Only one game may be in preparation/build")
    require(state.get("active_game") == (pending[0] if pending else None), "active_game disagrees with game stages")
    waiting = sum(game["stage"] == "DEV-COMPLETE" for game in records)
    require(waiting <= 2, "More than two games are waiting for Snow's playtest")
    require(not (pending and waiting >= 2), "Cannot have an active new game with two awaiting playtest")
    require(not (pending and any(game["stage"] == "WINNER" for game in records)), "Focus on the WINNER before new games")
    return state, queue, records


def add_idea(root, name, idea, source):
    state, queue, _ = validate(root)
    require(all(value.strip() for value in (name, idea, source)), "Name, idea, and Snow source are required")
    number = max((int(item["id"][5:]) for item in queue["ideas"]), default=0) + 1
    entry = {"id": f"idea-{number:03d}", "name": name.strip(), "idea": idea.strip(),
             "source": source.strip(), "game_id": None}
    queue["ideas"].append(entry)
    write_json(root / "factory-state/idea-queue.json", queue)
    state["updated_on"] = today()
    write_json(root / "factory-state/state.json", state)
    return entry["id"]


def new_game(root, idea_id):
    root = Path(root)
    state, queue, records = validate(root)
    require(state["active_game"] is None, "Finish the active game first")
    require(sum(game["stage"] == "DEV-COMPLETE" for game in records) < 2, "Two games await Snow's playtest")
    require(not any(game["stage"] == "WINNER" for game in records), "All agents must focus on the WINNER")
    pending_ideas = [idea for idea in queue["ideas"] if idea["game_id"] is None]
    require(bool(pending_ideas), "Select an unassigned idea from Snow's queue")
    require(pending_ideas[0]["id"] == idea_id, "Take the next idea in Snow's queue; Snow may reorder it first")
    idea = pending_ideas[0]
    game_id = f"game-{state['next_game_number']:03d}"
    destination = root / "games" / game_id
    require(not destination.exists(), f"Refusing to overwrite {game_id}")
    require(destination.parent.resolve().is_relative_to(root.resolve()), "Game directory escapes repository")
    scratch = root / "work"
    scratch.mkdir(exist_ok=True)
    require(scratch.resolve().is_relative_to(root.resolve()), "Scratch directory escapes repository")
    tokens = {"{{GAME_ID}}": game_id, "{{GAME_NAME}}": idea["name"], "{{IDEA_ID}}": idea_id, "{{DATE}}": today()}
    state_paths = [root / "factory-state" / filename for filename in ("state.json", "idea-queue.json", "checkpoint.md")]
    snapshots = {path: path.read_bytes() for path in state_paths}
    state["games"].append(game_id)
    state["next_game_number"] += 1
    state["active_game"] = game_id
    state["updated_on"] = today()
    idea["game_id"] = game_id
    checkpoint = (
        f"# Checkpoint\n\n- Date: {today()} (Europe/Istanbul)\n- Active game: {game_id}.\n"
        f"- Selected idea: {idea_id} — {idea['name']}.\n- Stage: SPEC-PENDING.\n"
        "- Next action: complete the spec from Snow's idea and obtain Snow's approval before implementation.\n"
        "- Human decisions: retain actual approval evidence in game.json; none created by scaffolding.\n"
    )
    installed = False
    try:
        with tempfile.TemporaryDirectory(prefix="factory-", dir=scratch) as temporary:
            staged = Path(temporary) / game_id
            shutil.copytree(root / "game-templates/basic-round", staged)
            text_extensions = {".md", ".json", ".jsonc", ".luau", ".lua", ".toml", ".txt", ".yaml", ".yml"}
            for path in staged.rglob("*"):
                if path.is_file() and path.suffix.lower() in text_extensions:
                    content = path.read_text(encoding="utf-8")
                    replacements = {key: json.dumps(value, ensure_ascii=False)[1:-1] for key, value in tokens.items()} if path.suffix == ".json" else tokens
                    content = re.sub(r"\{\{(?:GAME_ID|GAME_NAME|IDEA_ID|DATE)\}\}", lambda match: replacements[match[0]], content)
                    path.write_text(content, encoding="utf-8", newline="\n")
            staged.rename(destination)
            installed = True
            write_json(root / "factory-state/idea-queue.json", queue)
            write_json(root / "factory-state/state.json", state)
            (root / "factory-state/checkpoint.md").write_text(checkpoint, encoding="utf-8", newline="\n")
            validate(root)
    except Exception:
        for path, content in snapshots.items():
            path.write_bytes(content)
        if installed:
            require(destination.resolve().is_relative_to(root.resolve()), "Refusing cleanup outside repository")
            shutil.rmtree(destination)
        raise
    return game_id


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("status", help="Show active work and Snow's queue")
    sub.add_parser("check", help="Validate registry, WIP, files, and recorded human gates")
    queue = sub.add_parser("queue", help="Record an idea actually supplied by Snow")
    queue.add_argument("--name", required=True)
    queue.add_argument("--idea", required=True)
    queue.add_argument("--source", required=True)
    new = sub.add_parser("new-game", help="Create a spec-pending scaffold from a queued idea")
    new.add_argument("--idea", required=True)
    args = parser.parse_args(argv)
    try:
        if args.command == "queue":
            print(add_idea(ROOT, args.name, args.idea, args.source))
        elif args.command == "new-game":
            print(f"Created {new_game(ROOT, args.idea)}; Snow's spec approval is still required.")
        else:
            state, queue, records = validate()
            if args.command == "status":
                print(f"Active: {state['active_game'] or 'none'}")
                print(f"Waiting for playtest: {sum(game['stage'] == 'DEV-COMPLETE' for game in records)}/2")
                print(f"Games: {len(records)}")
                pending = [idea for idea in queue["ideas"] if idea["game_id"] is None]
                print(f"Queued ideas: {len(pending)}")
                for idea in pending:
                    print(f"  {idea['id']}: {idea['name']}")
            else:
                print("Factory state checks passed.")
    except (ValueError, OSError, KeyError, TypeError) as error:
        parser.exit(1, f"Factory check failed: {error}\n")


if __name__ == "__main__":
    main()
