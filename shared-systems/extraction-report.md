# Shared systems extraction — completion report

Date: 2026-10-16. Authorized by Snow's message: "extract the systems". Maintenance of the two approved v1 games; no new game or gameplay scope added.

Delivered four versioned pure Luau packages: SeededRandom, TokenBucket, PrivateRequests and PublicHistoryBot, all 1.0.0. Contracts, manifests and executable Lune tests are in each version directory. Rule Stack pins two packages; Don't Match Me pins four. Runtime adapters load only game-local copies. PublicHistoryBot explicitly pins/injects SeededRandom 1.0.0; no hidden runtime loader or live cross-game paths.

The installer records exact package hashes and copy paths. The factory gate now verifies actual bytes rather than accepting any SHA-shaped label. The full checker discovers/runs shared package tests. Thirteen added Python tests exercise source/contract drift, copy drift, dependency omissions, duplicate pins, wrong source paths, incomplete copy maps, path traversal/symlinks, unpinned copies, required contracts/tests and overwrite refusal. The existing human/WIP gates are retained.

## Verification

`python scripts/check.py`: PASS in cloud/headless Linux.

| Check | Evidence |
| --- | --- |
| Registry, recorded approval/WIP gates, syntax/JSON and copy integrity | PASS |
| Python tests | 45 PASS, including 13 new pin-integrity tests |
| StyLua / Selene | PASS; 0 lint errors/warnings/parse errors |
| Shared package Lune tests | 3,119 assertions: SeededRandom 1,021; TokenBucket 50; PrivateRequests 21; PublicHistoryBot 2,027 |
| Template | 51 assertions PASS |
| Rule Stack | 95,514 assertions PASS; 1,000 seeded witness runs and 200 alternate paths retained |
| Don't Match Me | 444,769 assertions PASS; 10,080 seeded rounds, 480 replay rounds and 1,875 exhaustive scoring configurations retained |
| Local Rojo builds | Template and both games PASS; refreshed `work/builds/game-001.rbxlx` and `game-002.rbxlx` |
| Engine/device/network feel/fun | NOT RUN; Snow's owner checks remain |

A side-by-side comparison loaded the pre-extraction Generator and Bot from local revision `18eadcd` (same source tree as GitHub `707ae62258e3b06c18f138d4d9068f66b288441e`). All **1,000 complete puzzle objects and 6,000 bot choices** matched the extracted implementation exactly. Committed golden fixtures additionally preserve seven representative puzzle fingerprints and 600 original bot choices in the ongoing game suites. Game tests require the actual pinned production copies.

Game-specific rules, score calculations, phase/roster transitions, snapshot filtering and UI remain local. The shared limiter rejects nonfinite clocks without poisoning its state; the shared request tracker fails closed at ID exhaustion instead of issuing an invalid envelope. Neither change affects ordinary v1 traces. Public bot inputs remain caller-validated, resolved public counts; the package does not grant permission to use private choices.

## Handoff

GitHub branch: `refactor/extract-shared-systems`. Final source revision is recorded in both games' game.json and completion reports after the final check. Existing spec bytes, Snow's approval evidence, no-monetization exceptions, null playtest/publish approvals and null place IDs are retained. Both games remain DEV-COMPLETE, filling 2/2 awaiting-playtest slots. No game-003 is started. No main merge, Roblox upload/release, remote execution or credential access.

Future reuse: follow [package install and wiring instructions](README.md). Use new package versions for future changes and review each game's upgrade explicitly. This extraction is verified within local pure-logic/build boundaries; hosted CI and Studio/phone behavior are not claimed.
