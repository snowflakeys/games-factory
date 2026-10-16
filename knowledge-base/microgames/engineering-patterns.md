> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Engineering Patterns

For small, independently understandable game kernels. The factory should **not** generate whole Roblox projects from one giant shared framework.

## Project layout (Rojo)

```text
game-project/
  default.project.json
  src/
    shared/   GameConfig.luau, Rules/, Types/, Util/
    server/   GameServer.server.luau, Match/, Persistence/, Networking/, Analytics/
    client/   GameClient.client.luau, UI/, Input/, Effects/
  tests/      rules/, generators/, simulations/
  docs/       GAME_SPEC.md, NETWORK_CONTRACT.md, TEST_MATRIX.md, POSTMORTEM.md
```

Rojo maps files to server/client/ModuleScript instances by naming convention, which keeps the project version-controlled and agent-friendly.

## Reusable components

Build boring, narrow, heavily tested modules first.

| Component | Build early? | Owns | Must not own |
|---|---|---|---|
| `MatchStateMachine` | Yes | Named states, transitions, timers, cancellation, player-leave handling | Game-specific scoring |
| `SeededRandom` | Yes | Deterministic shuffle, weighted choice, seed/version logging | Procedural gameplay rules |
| `RemoteValidator` | Yes | Type / range / state / rate validation helpers | A giant abstract networking framework |
| `ResponsiveUI` | Yes | Insets, safe areas, touch sizes, scale utilities | Visual theme |
| `DragDrop` | Yes | Drag lifecycle, snapping, touch/mouse normalization | Inventory or business rules |
| `UIFeedback` | Yes | Tweens, pulses, counters, error/success feedback | Game cutscenes |
| `RoundTimer` | Yes | Server timestamps + client display reconciliation | Game outcomes |
| `ScoreService` | Yes, small | Score changes, reason codes, multipliers | A universal economy |
| Bot interface | Yes | `Observe`, `ChooseAction`, difficulty/personality hooks | General AI pathfinding |
| `DailySeed` | Yes | Day-to-seed mapping, ruleset version | A full live-ops calendar |
| `AnalyticsEvents` | Yes | Typed wrappers for the standard funnels | Per-game interpretation |
| DataStore wrapper | Yes | Retry/error handling, schema versioning, safe defaults | Complex profile systems before required |
| Card/Table engine | After game 2-3 | Hands, deck zones, reveal states, turn/simultaneous choice | Every conceivable board game rule |
| Lobby/party layer | After multiplayer proof | Ready state, rematch, roster | Custom matchmaking until population justifies it |
| Universal "Game Framework" | **No** | - | Don't predict abstractions before three games need them |

## Core patterns

- **Authoritative state.** Client requests an action; server validates it against match state, commits, and broadcasts the result. Purely cosmetic motion stays client-side.
- **Semantic actions, not coordinates.** Send `CardChosen(3)`, `TokenPlaced(2,4)`, `ApproveCase(17)`. Almost never network GUI positions.
- **Never replicate hidden truth early.** Unrevealed cards, case answers, hidden traits stay server-side until legitimately revealed.
- **Determinism.** Generate content from explicit `seed + ruleset_version`. Log enough to reproduce any match:

```text
game_version = 17
ruleset_version = 4
seed = 81429201
player_count = 4
modifier_ids = ["UNIQUE_ONLY", "LOCK_PREVIOUS"]
```

- **Generate forward from a known-legal state** for puzzles, so solvability is guaranteed by construction. Validate with brute-force solvers and simulation anyway.
- **Server timestamps** for competitive timing, never frame-dependent timers. Don't claim millisecond fairness the network can't deliver.
- **Small modules.** No single "GameManager" coordinating UI, rules, persistence and networking; it defeats parallel agent work.

## Testing tiers

1. **Pure-Luau simulation tests:** rule predicates, generators, resolvers, bots, millions of random placements, modifier combinations, property/invariant checks.
2. **Studio integration tests:** client/server contract, remotes, UI layout on emulated devices, persistence.
3. **Published-client tests:** real devices, real network delay, real multiplayer sessions.

## Common failures to test for

1. Client-authoritative scoring (claimed wins or impossible completion times)
2. Hidden information sent to the client
3. Frame-dependent competitive timers
4. Random generation without solvability guarantees
5. Huge manager modules
6. Universal abstractions too early
7. UI authored for one monitor size (mobile-heavy audience)
8. Analytics added after launch

## What agents handle well vs. what needs a human

**Agents:** schemas, deterministic state machines, exhaustive rule tests, boilerplate ScreenGui, data-driven registries, bot heuristics, analytics instrumentation, remote validation, procedural simulation, refactors, docs.

**Human playtest required even if agents write all the code:** touch targets that are reachable but feel bad; valid rules that are mentally exhausting; a reveal 800 ms too slow that kills the urge to rematch; icons players misread but tests understand; a balanced bluffing game that feels random.

## Per-game workflow

| Stage | Coordinator | Specialist agents | Human gate |
|---|---|---|---|
| Mechanic formalization | Turns the concept into invariants and acceptance criteria | Rules agent explores edge cases | "Is the loop fun on paper?" |
| Simulation kernel | Reviews data model / API boundaries | Rules, generator, test agents in parallel | Inspect generated examples |
| Roblox integration | Enforces the client/server contract | Server, UI, persistence, analytics agents | Test real device feel |
| Adversarial QA | Prioritizes failures | Fuzz, exploit, player-count, layout agents | Play real multiplayer sessions |
| Release candidate | Checks scope against MVP spec | Docs and regression agents | Approve the first-session experience |
| Post-release | Compares analytics to hypotheses | Analysis agent prepares cohorts/funnels | Iterate, pivot or stop |

## Scope discipline

Freeze a short v1 list before building. Anything new goes on a v1.1 list, not into v1. Each spec in `specs/` has an explicit **Postpone** list; treat it as binding.

## Metrics and postmortem

First-session funnel for almost every game:

`joined → core interaction visible → first action → first completed round/task → pressed rematch/continued → completed third round → opened customization/shop`

Headline factory metric: **completed first meaningful action within 20 seconds** (proposed internal metric, not a Roblox benchmark).

Every `POSTMORTEM.md` should record production economics, not just bugs: estimated agent-hours, human-hours, regressions, systems newly reusable, first-minute completion, repeat-round rate, sessions per user, population sensitivity, mobile failures, and whether each feature actually changed behavior.
