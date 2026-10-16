# Don't Match Me tests

From this folder: `../../.tools/bin/lune run tests/run.luau`. From repository root: `python scripts/check.py` runs repository/Python tests, formatter, pinned Roblox-standard Selene lint, all game/template Lune suites and local Rojo builds. CI runs the same command on Linux and Windows.

Tests import the production pure modules directly through dependency injection; no alternate gameplay implementation is substituted. The suite covers:

- All 625 four-player combinations of four symbols or a miss, under each of three scoring rules: 1,875 configurations checked against a separate per-person group-size oracle.
- 10,080 seeded rounds across 1/2/4/8/12/16 humans, with 480 complete replay rounds; bot fill, fixed rule cadence, legal choices, no pre-reveal scoring, bounded totals, exact-once resolution, final winners and deterministic complete match traces.
- Schema/type/range/NaN/infinity, false membership, fake score/time claims, stale IDs, duplicate/change-pick attempts, and exact deadline boundaries.
- Bot commitments before human input, public-only policy input shape, private/personalized choosing snapshots, real reveal at the boundary, and mutable-alias rejection.
- Joins and respawn synchronization across starting/choosing/reveal/intermission/results; departures before/after picks; same-server score/choice rehydration; zero-human cleanup and fresh match; 16-human capacity.
- Shared all-zero eligible wins, all-miss noneligibility, bot wins, all-ready early rematch, results arrivals/leaves, duplicate/late readiness and automatic rematch.
- Per-player burst/refill limits including malformed envelopes, private correlation IDs, in-flight lock during broadcasts, read-only timeout recovery, delayed acknowledgements and authoritative phase changes.
- 64-transition server-hitch work bound and logical 64px choice-target geometry at phone/tablet/desktop sizes.

Not verified: actual Roblox services, RemoteEvents, ScreenGui layout/font rendering, touch input, rotation/notches, network feel, mobile performance, first action within 20 seconds or ten enjoyable rounds. Use ../playtest.md for the separate owner matrix. No credentials or remote execution are involved in these local tests.
