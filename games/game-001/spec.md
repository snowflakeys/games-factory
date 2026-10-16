# Rule Stack — v1 draft

- Game: game-001; queue: idea-001.
- Draft date: 2026-10-16.
- Status: SPEC-PENDING. Snow's spec approval: PENDING.
- Source: Snow selected Rule Stack for this supervised dry run on 2026-10-16. Research input: knowledge-base/microgames/specs/rule-stack.md.
- Selecting the idea did not approve this implementation scope. No gameplay implementation may begin yet.

## Pitch and core loop

A solo UI puzzle: place the next token on a 4×4 board while rule cards accumulate. Preview a target, commit a placement, see server-confirmed legality, then place again. Fill all 16 cells to win. Lose after two illegal in-board placements or when the next token has no legal cell. Show an immediate restart button after either result.

## Proposed frozen v1 scope (awaiting approval)

1. One solo mode, no 3D map, one active run per player. Tokens have color (red/blue/yellow/green), shape (circle/star/triangle), and number (1–4).
2. One starting rule; add one compatible rule after accepted placements 4, 8, and 12. Six initial predicates: red cannot touch red orthogonally; stars must be on an edge; blue cannot occupy a corner; yellow cannot share a row with green; odd-numbered tokens must be in the left two columns; triangles cannot share a column. Explain every active rule in plain text.
3. Generate a deterministic 16-token sequence and staged rules with at least one complete legal witness path. Validate existing placements when adding a rule. Bounded generation attempts must fall back to a versioned known-solvable seed, never an impossible board. Player choices may still create a dead end. Solvability is part of v1, not postponed.
4. Show board, next token, active rules, score, and two-strike counter. Score is 10 per accepted placement, maximum 160; rejected input grants nothing. No live timer or reward multipliers.
5. Touch-first tap-token/tap-cell placement, with optional drag-to-cell for mouse and touch. Preview legality and explain violations. Cancelled drags and drops outside the board do not consume a strike. In-flight input is disabled until authoritative acknowledgement.
6. Server owns seed, token sequence, board, active rules, score, strikes, and win/loss. Clients send cell intents with run ID and turn index. Reject malformed, duplicate, stale, out-of-range, and over-rate requests without applying rewards or strikes. An otherwise valid illegal cell placement consumes one strike. Disconnect ends that ephemeral run; respawn rehydrates the current server run. Restart creates a fresh run ID. Other players have independent runs.
7. End screen shows outcome, final score, and restart. No saved progression in v1.

## Required systems and test boundary

Pure Luau: board/token model, six predicates, staged-rule evaluator, seeded generator, witness validator, available-cell search, scoring, and run transitions. Lune tests cover witness legality across every rule stage, deterministic replay, malformed/late/duplicate intents, score/strike boundaries, loss, victory, and restart. Test at least 1,000 generated seeds and record the generator's bounded fallback behavior.

Thin Roblox adapters: remotes and per-player session lifecycle, safe-area ScreenGui, input/drag preview, server acknowledgements, and local result presentation. Keep hidden witness solutions server-side. Use the template MobileHud as a reference, not final game art.

## Mobile acceptance

Critical controls stay inside CoreUISafeInsets; board cells and primary actions have at least 48×48 logical-pixel targets at the smallest supported viewport. Verify small phone portrait and landscape, notches, tablet, desktop mouse, text legibility, touch cancellation, respawn, and spam/duplicate taps in Studio and on Snow's phone. If four columns cannot meet the target, change the layout before approval. Engine/UI checks remain unverified until performed.

## Win condition and measurable acceptance

A run accepts 16 legal placements, ends exactly once in victory or loss, then restarts without stale state. No invalid request changes score. Every generated seed has a validated witness solution. A first-time tester completes a placement without verbal help in about 20 seconds; Snow judges whether ten consecutive runs remain enjoyable without progression rewards. Automated checks cannot establish that judgment.

## Monetization decision requiring Snow

Proposed v1 exception to the factory's default 2x boost/ad plan: no monetization, XP, purchases, or ads in this puzzle prototype. A scoring boost would change the puzzle objective. This exception is not approved; Snow must explicitly accept it with the spec or request a revised scope. No product IDs are configured.

## Clippable moment

A new rule arrives just as a nearly full board leaves one legal move; a clever final placement completes the puzzle.

## Exclusions and v1.1 backlog

Daily shared seed, timed Sprint, multiplayer race, bots, rankings, persistence, achievements, cosmetics, extra predicates, monetization, sounds and custom art polish. Changes stay here unless Snow revises the approved v1 scope.
