> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Rule Stack

**Pitch:** Drag tokens onto a 4x4 board while new rules keep stacking up. Every placement must obey every active rule. Survive as many rules as you can.
**Family:** Rule-changing UI puzzle. **Players:** solo-first. **Map:** none.
**Research rank:** 3rd by score, recommended **first factory release** (works at zero concurrency, builds the most reusable UI/procedural/test infrastructure).
**Estimate (engineering judgment):** 1-2 d rough prototype, 2-3 focused days for a playable MVP, plus public-release polish.

## Questions the first release must answer

1. Do Roblox users accept an almost entirely ScreenGui-based game when the interaction is immediately satisfying?
2. Can procedural rules generate voluntary rematches without a progression treadmill?
3. Can automated generator tests reduce QA cost enough to matter?

## Gameplay

- 4x4 board, a queue of simple tokens, one starting rule.
- A turn: drag the next token to an empty legal cell.
- Every 2-4 placements a new rule card joins the stack; from then on placements must obey **all** active rules.
- Example rules: "Red cannot touch red." "Stars must be on an edge." "Even numbers need a blue neighbor." "Exactly two corners must be occupied." "Yellow cannot share a row with green."
- The UI previews whether a drop is legal; harder difficulties don't say why.
- Normal run: two mistakes ("rule breaks"). Relaxed mode: unlimited undo.
- Score rewards placements, surviving extra rules, optional hard-rule multipliers, board efficiency.
- Run ends when no legal placement exists or strikes run out.
- Modes: Daily (one shared seed), Endless (rule count climbs), Sprint (hit a target board under a timer), future Race (identical token/rule sequence for everyone).

## Technical

- **Generator must build forward from a known legal state**, not pick random rules and hope they're satisfiable. This is the decision that makes it production-worthy.
- Rule model is pure data + predicates: `RuleDefinition = {Id, Difficulty, AppliesTo, CheckPlacement, CheckBoard, Explain, CompatibilityTags}`.
- Modules: `BoardState`, `RuleRegistry`, `RuleEvaluator`, `SolvableGenerator`, `SeededRandom`, `ScoreRules`, `DragController`, `HintService`, `DailySeed`, `RunRecorder`, `AnalyticsEvents`.
- UI: 4x4 board, queue strip, active-rule stack, score/stability display, end-of-run summary. UIDragDetector can reduce drag plumbing, but wrap it to normalize touch/mouse feedback and snapping.
- Persistence: settings, best scores, cosmetics, achievements, daily completion.
- Networking surface in MVP is almost nil. For leaderboards the server issues seed + ruleset version and rejects clearly impossible scores instead of trusting client totals.

## MVP phases

1. Board, token model, six rules, legality check, score, loss, restart.
2. Drag snap, rule-card animation, sound, rule-violation explanation, fast rematch from the end screen.
3. Solvable generator, 20-30 parameterized rules, daily seed, difficulty tiers.
4. Brute-force generation tests, mobile drag tests, impossible-state detection, analytics funnels, public soft launch.

**Postpone:** cosmetics, competitive race mode, seasonal rules, achievements, large rule counts. **Solvability validation cannot be postponed.**

## Agent task split

Board-model agent, predicate agent, brute-force solver agent, generator agent, drag-UI agent, test agent: all work in isolation. Simulation plays millions of random placements cheaply.

## Human checks

Is each rule understandable in under one glance? Does the difficulty curve feel clever rather than arbitrary?

## Go / no-go

Players voluntarily restart after failure without needing progression rewards.
