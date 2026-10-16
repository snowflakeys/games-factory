# Shared systems

Four pure Luau packages have been extracted from the approved v1 games. Each package has a contract, manifest, tests, and an immutable `1.0.0` source directory. These are small opt-in building blocks; a complete Universal Blocks Engine has not been implemented.

| Package | Reusable behavior | Consumers |
| --- | --- | --- |
| [seeded-random 1.0.0](seeded-random/1.0.0/README.md) | Reproducible bounded draws and nonmutating shuffle | Rule Stack generator; Don't Match Me bots |
| [token-bucket 1.0.0](token-bucket/1.0.0/README.md) | Independent per-session burst/refill request limiter | Both games' server protocols |
| [private-requests 1.0.0](private-requests/1.0.0/README.md) | Exact envelope, private ack correlation, context invalidation and timeout detection | Don't Match Me server protocol and client controller |
| [public-history-bot 1.0.0](public-history-bot/1.0.0/README.md) | Seeded frequent/rare weighted choices from public resolved counts only | Don't Match Me bots |

Scoring, puzzle constraints/solvability, roster/match transitions, personalized snapshot filtering and UI stay in their source games. Copying these packages alone does not supply those game policies.

## Install and wire an explicit dependency

For an already registered game, install only what its approved loop needs. For example, replace `game-NNN` with that game's ID:

```sh
python scripts/shared_systems.py install game-NNN seeded-random 1.0.0 src/server/Systems
python scripts/shared_systems.py install game-NNN public-history-bot 1.0.0 src/server/Systems
python scripts/shared_systems.py verify
python scripts/check.py
```

Install dependencies first: PublicHistoryBot requires SeededRandom 1.0.0. Use `src/server/Systems` for server-only code; PrivateRequests is copied to `src/shared/Systems` when both server and client require it. The installer refuses existing pins and occupied files; it does not silently upgrade a game. Explicitly load the local copies in the Roblox adapter and inject them into pure modules. Lune tests load those same copies using relative string paths. See either game's Main adapter and test runner for working integrations.

The installer creates source copies and the game's `shared-systems.lock.json` entries. Each entry identifies exact name/version/source, maps every source module to its game path, and pins a package SHA-256. The digest covers **all package files**, including contract/tests/manifest: sort relative paths lexically, append each UTF-8 path, NUL, exact file bytes, NUL, and hash the concatenation. Repository line endings are pinned to LF by `.gitattributes`.

## Compatibility rules

- No game loads a live path outside its own source tree. Shared edits cannot silently change a built game.
- Never change an existing released package directory. Create a new version, keep the old version available, and explicitly review each game's copy/lock upgrade.
- `scripts/factory.py` verifies package identity/hash, exact copied bytes, complete module maps, exact transitive pins, duplicate/overlapping pins and unpinned `Systems` modules. Unsafe paths and symlinks are rejected.
- `python scripts/check.py` runs every package's Lune contract tests plus factory/Python tests, formatter, lint, all game regressions and local Rojo builds. CI invokes this same command.
- Keep contracts narrow. Add a shared system only when it serves an approved core loop; do not add speculative engine infrastructure.

Extraction evidence and limitations: [completion report](extraction-report.md). Actual Roblox engine/device behavior and fun still need Snow's playtest.
