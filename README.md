# Game Factory

Snow owns and playtests a factory for simple Roblox games with one core loop. [AGENTS.md](AGENTS.md) is the canonical policy. This repository is initialized with no active game, no queued ideas, and no recorded game approvals.

## Start here

Use Git, Python 3.11+, Roblox Studio, and the Rojo Studio plugin. The scripts install their pinned development tools locally; nothing needs a global PATH change.

```powershell
python scripts/bootstrap.py
python scripts/check.py
python scripts/factory.py status
```

Checks cover factory state and approval records, Python workflow tests, Luau formatting (StyLua), lint (Selene), logic tests (Lune), and local Rojo builds. GitHub Actions runs the same command on Windows and Linux after this repo is pushed to a configured GitHub remote. This setup does not include a publish workflow.

## Start a game from Snow's queue

Record only an idea actually supplied by Snow. The values below show command syntax; they are not a seeded game idea.

```powershell
python scripts/factory.py queue --name "Snow's game name" --idea "Snow's actual idea" --source "Reference to Snow's message"
python scripts/factory.py new-game --idea idea-001
```

The command makes `games/game-001/` from the round template, with a spec draft and all required documents. Complete `spec.md`, then wait for Snow's approval before implementing gameplay. Record his decision in `game.json` with actual source evidence. See [state and approvals](factory-state/README.md) for the metadata format.

Implement the full approved core loop, run `python scripts/check.py`, write the completion report, and mark DEV-COMPLETE. Two DEV-COMPLETE games waiting for Snow's playtest block another start. Snow establishes PLAYTESTED and approves every publish. DEV-COMPLETE never means tested or release-ready.

## Build or edit in Studio

After creating a game, run these from the repo root in PowerShell, substituting its real ID:

```powershell
.\.tools\bin\rojo.exe build games/game-001/default.project.json --output work/game-001.rbxlx
.\.tools\bin\rojo.exe serve games/game-001/default.project.json --address 127.0.0.1
```

Open the local build in Studio or connect the Rojo plugin to the local server. Studio and the plugin are separate installs: see the [official Rojo installation guide](https://rojo.space/docs/v7/getting-started/installation/). Use a separate test place for winner updates. Set `servePlaceIds` to the test ID once configured; never connect development sync to the live place. No Roblox credentials or monetization IDs are needed for repository setup.

The hosted source repository is [snowflakeys/games-factory](https://github.com/snowflakeys/games-factory).

## Repository map

| Path | Purpose |
| --- | --- |
| `agent-instructions/` | Session checklist, definition of done, draft art-style bible |
| `game-templates/basic-round/` | Rojo source, tested round-state helper, and game document templates |
| `shared-systems/` | Versioned systems; Universal Blocks Engine reservation |
| `knowledge-base/` | Imported research, platform references, and evidence-tagged lesson template |
| `factory-state/` | Registry, Snow's idea queue, and current checkpoint |
| `games/game-NNN/` | Each game's own source, spec, assets, tests, reports, and approvals |
| `scripts/`, `tests/` | Tool setup, quality checks, queue/scaffold CLI, workflow tests |
| `toolchain.lock.json` | Pinned official tool archives and SHA-256 digests |
| `work/` | Ignored temporary downloads, test fixtures, and local builds |
| `outputs/` | Ignored shareable source snapshot and setup report |

Each game receives its own `game.json`, Rojo project, spec, decisions, backlog, asset prompts, marketing plan, completion report, playtest record, release checklist, metrics sheet, assets/tests directories, and shared-system lock. Templates show PENDING until real work and evidence replace them. No game or Universal Blocks Engine has been implemented by this setup.

## Decisions still needed from Snow

- First game idea and spec approval.
- Art preferences; the starter style bible is a draft.
- Test/live place IDs, pass IDs, and ad eligibility when a game's spec needs them.

The default monetization plan is a permanent 2x boost gamepass, an optional ad for 15 minutes of XP boost, and rewards, without purchase pressure. Define the benefit in each spec; record unconfigured integrations honestly. Never grant rewards from unverified client claims.

At session end, update the checkpoint and state, run the checks, and commit. Read [the session checklist](agent-instructions/session-checklist.md) and [definition of done](agent-instructions/definition-of-done.md) for the full cycle. Tool pins and maintenance instructions are in [tools/README.md](tools/README.md).


## Research and operations pack

- [Microgames catalog and draft specs](knowledge-base/microgames/README.md)
- [Session protocol reference](agent-instructions/session-protocol.md)
- [Shipping checklist reference](agent-instructions/ship-checklist.md)
- [Roblox build/publish pipeline reference](agent-instructions/roblox-pipeline.md)
- [Consolidated policy pointer](agent-instructions/proposed-policy.md)
- [Unconfirmed planning history](factory-state/planning-reference.md)

The publishing helper is owner-only, guarded by an explicit manual acknowledgement, and untested against Roblox. Agents and CI must never receive publishing keys or upload Saved/Published versions. No upload or release was performed. Existing root policy, approval gates, registry, and queue remain authoritative.
