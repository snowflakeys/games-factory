> Imported reference/proposal from Snow’s 2026-10-16 document pack. Root `AGENTS.md` remains canonical; existing approval gates, full-core-loop completion, CI requirements, and state schema take precedence over conflicting examples here. No policy replacement is approved by this import.

# Roblox Pipeline: tools, commands, what runs where

Source for platform claims: `knowledge-base/roblox-platform-rules.md`. Verified 2026-10-16. Commands below are the documented ones; the helper script is **untested against the live API**, so the first run must use `VERSION_TYPE=Saved`.

## Decision: Rojo is the source of truth

The repo (files on disk) is the source of truth, so cloud agents can build locally without Studio. That is Rojo's job. Studio's built-in **Script Sync** only syncs scripts, and it requires Studio open, so use it only as a convenience on the owner's PC. The built-in **Studio MCP server** is for desktop sessions (playtests, screenshots, input simulation).

## Toolchain

Use the repository’s `toolchain.lock.json` and `python scripts/bootstrap.py`. Lune, Rojo, StyLua, and Selene are already selected and pinned. Do not introduce a second tool manager. `python scripts/check.py` runs the required checks.

## Minimal project file

`games/game-NNN/default.project.json` (check it builds with `rojo build` before trusting it):

```json
{
  "name": "GameName",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": { "Shared": { "$path": "src/shared" } },
    "ServerScriptService": { "Server": { "$path": "src/server" } },
    "StarterPlayer": {
      "StarterPlayerScripts": { "Client": { "$path": "src/client" } }
    }
  }
}
```

Script naming on disk (Rojo and Script Sync agree): `name.luau` = ModuleScript, `name.server.luau` = server Script, `name.client.luau` = client Script, `name.local.luau` = LocalScript, `init.*.luau` for a script with children.

## Build

```bash
cd games/game-NNN
rojo build default.project.json -o build/game.rbxl
```

## Publish a version (owner only)

Agents never run these commands or receive publishing credentials. The owner runs them manually outside agent sessions. Both Saved uploads and Published releases are owner-only.

Prerequisites: the first publish was done once in Studio (it creates the IDs); an API key with write access for the place; `ROBLOX_API_KEY`, `UNIVERSE_ID`, `PLACE_ID` in the environment.

```bash
# staging: saved, not live
OWNER_PUBLISH_CONFIRM=I_AM_THE_OWNER VERSION_TYPE=Saved scripts/publish-place.sh games/game-NNN

# live: only when the owner said so
OWNER_PUBLISH_CONFIRM=I_AM_THE_OWNER VERSION_TYPE=Published scripts/publish-place.sh games/game-NNN
```

- `Saved` stores the version (visible in Studio) without changing what players get. `Published` makes it live.
- The API has a rate limit (30 requests per 60 seconds per key per IP).
- API keys can be restricted by IP; cloud runners with changing IPs may force a broad allow-list. Treat the key as a secret, use the narrowest permission, rotate it if it leaks.
- Publishing is subject to the same eligibility rules as Studio publishing.

## Tests, in three tiers

1. **Pure-logic tests (no Roblox engine):** rules, generators, resolvers, bots, seed replay. Runnable by any cloud agent. Prefer a standalone Luau runtime (for example Lune) or Jest-style tests; Lune is already selected by this repository.
2. **Owner-run engine tests via Luau Execution (headless, Roblox servers):** agents prepare test code only and never receive the key or invoke remote tasks. Snow can create a task, poll it, read results and logs. Physics doesn't run and scripts don't auto-run, so this tests required modules, not gameplay. Rate limit: 5 task creations per minute; at most 10 incomplete tasks per place; results kept 24 hours. **Run against the test place only.**
3. **Studio and device tests:** desktop session with Studio MCP (`start_stop_play`, `get_console_output`, `screen_capture`, simulated input) plus the owner's real phone.

## Studio MCP (desktop sessions only)

Enable in Studio: Assistant > ... > Manage MCP Servers > Enable Studio as MCP server; connect Claude Code, Codex CLI, or another client via Quick connect or the JSON/CLI config in the Roblox docs. Check for the green indicator. MCP clients can read and modify open places, so only connect trusted clients and disconnect when idle.

## Per-game metadata

Record test/live place IDs and approval evidence in `games/game-NNN/game.json` using the existing schema. Record additional Universe/version details in the game release checklist. Never record keys. `factory-state/checkpoint.md` holds the session handoff, not a competing game registry.
