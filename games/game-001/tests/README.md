# Rule Stack test boundary

From this game directory run `../../.tools/bin/lune run tests/run.luau`. From repository root run `python scripts/check.py` for factory/Python tests, formatter, pinned-std Selene lint, both Lune suites and both local Rojo builds. CI invokes that same command.

The tests use the production engine-free modules directly, through dependency injection. Coverage includes:

- All six predicates, orthogonal versus diagonal adjacency, edge/corner and row/column boundaries, symmetric pair rules and combined predicates.
- Seeds 1..1000: deterministic replay, all 16 witness placements, every rule stage, validated existing boards, score and exact terminal victory.
- An eight-attempt bound, natural single-attempt exhaustion, a zero-budget fallback, the literal versioned fallback, and a deliberately corrupt witness.
- 200 alternative legal player paths, proving compatible rule additions and checking dead ends by available-cell search.
- Type/range/schema/NaN/infinity rejection; unknown fields and client reward claims; duplicate accepted and illegal requests; stale turns and old run IDs; no double strikes or terminal rewards.
- Win, two-strike and no-legal-cell losses; restart, duplicate restart, per-player isolation (including 20 concurrent sessions), reconnect cleanup, read-only respawn sync, rate limiting/refill and snapshot alias/hidden-state checks.
- Logical layout widths and >=48px cell geometry for phone, tablet and desktop safe rectangles.

These are not Roblox engine tests. No services, actual RemoteEvents, rendering, real InputObjects, emulator/device, physics, remote execution or gameplay feel are exercised. Follow ../playtest.md separately. No credentials are needed by the automated suite.
