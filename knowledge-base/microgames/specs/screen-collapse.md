> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Screen Collapse

**Pitch:** "Finish tiny tasks while the game's own interface slowly falls apart."
**Family:** Experimental UI chaos. **Players:** solo primary; 2-6 same-seed race later. **Map:** none.
**Research rank:** 2nd by score; the strongest "this feels unlike normal Roblox" pitch and the best social/viral concept (failure visibly escalates into clips).
**Estimate (engineering judgment):** 3-6 d solo MVP; 5-8 d with multiplayer. **Build only after Rule Stack** has produced trustworthy responsive-layout and task-generation infrastructure.

## Gameplay

- A run starts with one centered panel and one trivial task: tap the odd symbol, drag three objects into bins, match two cards, order four numbers, stop a slider, dismiss the correct alert.
- Completing tasks earns Stability. Every 10-20 seconds the **chaos director** adds a reversible interface mutation: a panel drifts, windows overlap, the safe region shrinks, labels rotate, a fake notification appears, two tasks compete, a window must be moved before its controls are reachable.
- **Chaos must never randomly invalidate skill.** Each mutation belongs to a tested category with guaranteed minimum touch size, guaranteed access to essential controls, and capped overlap.
- Lose when Stability hits zero or three critical tasks expire. Score = completed tasks + combo multiplier + survival time.
- Multiplayer starts as **same-seed racing** (identical task/chaos sequence, compact opponent progress bars). Only after that works, add an optional Shared Chaos mode where successful players send predetermined nuisance effects.
- Difficulty scales by task cadence and permitted simultaneous task count, never by shrinking buttons below accessible size.

## Technical

- Two independent systems: a **Task Engine** and a **Chaos Director**. A task defines data, legal actions, renderer type, validation, estimated completion time, difficulty. A chaos effect declares eligibility, incompatibilities, layout impact, cleanup.
- Modules: `TaskRegistry`, `TaskGenerator`, `TaskValidator`, `ChaosDirector`, `LayoutSafety`, `SeededRandom`, `RunState`, `ScoreRules`, `DailySeed`, `InputAdapter`, `UIAnimator`, `AnalyticsEvents`.
- Task rules are unit-testable without Roblox rendering.
- **Invariant tests:** every generated task has a solution; every critical button stays inside allowed screen bounds; no modifier combination leaves an invisible mandatory control; cleanup returns the UI tree to a valid state.
- Solo runs need almost no continuous client/server traffic. Server issues a signed/validated seed and verifies coarse score events instead of trusting arbitrary final scores. Leaderboards add sanity checks: completion timings, impossible task rates, seed/version identity.
- Mobile reserved regions and layouts still need practical device testing.

## MVP phases

1. Five task types, three chaos effects, one run state, local scoring.
2. Polished panel motion, completion sounds, clear error flashes, **reduced-motion / screen-shake alternatives**.
3. 10+ task types, 12 chaos effects, daily seed, same-seed friend ghosts.
4. Test extreme aspect ratios, low-end phones, orientation assumptions, accessibility, layout recovery, thousands of generated effect combinations.

**Postpone:** direct player-vs-player attacks, leaderboards, cosmetics catalog, advanced metaprogression. A polished solo survival loop is enough to prove the idea.

## Agent task split

Schema agent defines the task/modifier interface; several small coding agents implement task plugins independently (narrow interface); property-test agent generates random sequences and asserts invariants; UI agent handles layout safety and mobile scaling; feel agent handles animation/audio.

## Human checks

Play long runs. "Technically accessible chaos" can still be psychologically exhausting.

## Go / no-go

Escalation stays readable on mobile and produces visible, funny failure stories rather than annoyance.
