# Don't Match Me v1 completion report

Date: 2026-10-16, Europe/Istanbul. Environment: cloud/headless Linux. Implementation complete; all required local checks PASS. Target is DEV-COMPLETE, separate from owner playtest/release approval.

## Approval and delivered scope

Snow approved spec.md at `9749d9f5d13aa03832a39d2bd67f3fc499a30942`, including its no-monetization v1 exception, by replying "approve and move to the next game" to the explicit approval question. Actual evidence, exact spec SHA-256 and approved revision are in game.json. The original spec is byte-for-byte unchanged; its draft language describes the historical approved source.

Implemented the complete solo/multiplayer loop: 1–16 humans, bots to fill four seats, four/six labeled symbols, private one-tap choices, six-second choosing and simultaneous authoritative reveal, UNIQUE/PAIRS/MINORITY scoring, eight-round totals and shared winners, results and quick/automatic rematches. Bots commit before human input, from seeded randomness and public revealed frequency history only. No map, avatar, elimination, persistence, XP, purchases, ads or product IDs.

Roster freezes per round. Arrivals wait for the next choice phase; accepted departing picks remain in current counts; bots replace vacancies only at the next freeze. Same-server match records rehydrate score/private choice on reconnect; respawn is idempotent. Zero humans clears the ephemeral match; next arrival begins fresh. All-ready results shorten to one second; a result-phase arrival retains others' ready flags and falls back to the original automatic deadline until a new quorum.

Server-owned deadlines, match/round IDs, membership, choices, scores and winners. Exact semantic/envelope validation, bounded correlation IDs and per-player burst-six/refill-three rate limiting. Client input locks until private acknowledgement; timeout requests only state sync. Broadcasts and stale acknowledgements cannot unlock the wrong request. Choosing snapshots contain only the viewer's own pick plus aggregate locked count, never opponents/bot picks or seed. Choices and counts become public only at reveal.

Native warm-paper/coral/teal UI uses CoreUISafeInsets, >=64px symbol targets, >=48px replay action, labeled glyphs, visible own score/rank, timed feedback and scrolling standings. No external art required for the core loop. Actual rendering, input, timing feel and mobile performance remain unverified.

## Architecture and changes

- `src/shared/Rules.luau`: symbols, schedule, score resolver and winner eligibility. `Controller.luau`: pure request/ack/timeout model. `Layout.luau`: logical geometry.
- `src/server/Bot.luau`, `Match.luau`, `Protocol.luau`: pure public-history bot policy, match/roster/phase transitions, private snapshot filtering, validation and rate limits. Dependencies injected for the same production code in Lune and Roblox.
- `src/server/Main.server.luau`: thin Player/service clock/RemoteEvent/heartbeat lifecycle wiring. Server callbacks never broadcast one person's private snapshot to everyone. Extra remote tuple arguments are rejected through the same invalid-packet limiter path.
- `src/client/Main.client.luau`, `View.luau`: native UI/input/clock transport; score and outcome always come from the server.
- Replaced only game-002's copied RoundState/MobileHud scaffold. The original template and game-001 are unchanged. No external shared systems; empty dependency lock remains accurate.
- Updated test/client docs, decisions, backlog, owner matrix, release checklist, asset prompts, marketing and the narrowly verified source-game lesson `knowledge-base/dont-match-me-private-acks.md`.

## Required verification

Command: `python scripts/check.py` from repository root. All required local checks pass. No checker or policy gate was weakened or skipped. Hosted CI is not claimed until observed.

| Check | Outcome |
| --- | --- |
| Factory registry/approval/WIP, Python syntax and JSON | PASS |
| Python repository tests | PASS, 32 tests |
| StyLua | PASS |
| Selene with committed Roblox std | PASS, 0 errors/warnings/parse errors |
| Template Lune tests | PASS, 51 assertions |
| Rule Stack unchanged tests | PASS, 95,507 assertions, 1,000 seed/witness replays, 200 alternative paths |
| Don't Match Me Lune tests | PASS, 444,169 assertions |
| Exhaustive scoring oracle | PASS, all 625 four-player four-symbol-or-miss combinations under 3 rules: 1,875 configurations |
| Generated simulation/replay | PASS, 10,080 seeded rounds across 1/2/4/8/12/16 humans, plus 480 replay rounds |
| Adversarial/lifecycle/privacy | PASS, exact deadlines, fake score/time/membership fields, duplicates/stale IDs, bot precommit, frozen joins/leaves, all active-phase respawns, reconnects, ties/misses/bot wins, rates and acknowledgement recovery |
| Local Rojo builds | PASS, all 3 projects; `work/builds/game-002.rbxlx` is the ready-to-open game-002 build |
| Studio/actual remotes/emulator/phone/fun | NOT RUN; separate owner verification |

Scoring is capped at 10 per participant per eight-round match. Deadline equality is late. Resolution is idempotent, no points are applied before reveal, and catch-up after server hitches is bounded to 64 transitions per tick. These are pure-logic evidence, not claims about engine/network/device performance.

## Limitations and owner handoff

No known automated core-loop blocker. `backlog.md` and `playtest.md` list remaining engine, real-input, clock/network, font/glyph, screen-safe-area and device checks. Snow still judges first pick within about 20 seconds and ten enjoyable consecutive rounds/repeat matches without rewards. No successful playtest is invented.

Icon/thumbnail/effect prompts are ready in assets-needed.md; final art does not exist. v1.1 remains extra modifiers, forbidden symbols, stealing, daily/ranked/party modes, persistence, cosmetics/XP, monetization, custom art/audio/haptics and advanced bot difficulty.

Completion metadata pins the checked implementation revision. GitHub branch: `build/dont-match-me-v1`, based on approved spec commit 9749d9f. No main merge or Roblox upload/release. The final handoff commit changes only metadata/reports after source verification.

Stop before game-003: game-001 and game-002 are now the two awaiting-playtest slots. AGENTS.md says, "WIP cap: at most 2 games waiting for Snow's playtest. Don't start more until he clears one." No playtest/publish approvals or place IDs have been fabricated. No credentials, remote execution, payments, questionnaires or account actions performed.
