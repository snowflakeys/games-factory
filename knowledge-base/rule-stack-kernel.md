VERIFIED — pure Luau logic only; 2026-10-16. Source: [game-001 Rule Stack](../games/game-001/spec.md), [production modules](../games/game-001/src/server), [Lune suite](../games/game-001/tests/run.luau), [completion report](../games/game-001/completion-report.md).

# Staged constraints need compatibility beyond a witness

Rule: when adding constraints to a player-modified board, validate the actual existing board. A complete witness proves only that one path works; it does not prove a future rule is compatible with every legal earlier player choice.

Rule Stack's six predicates permit a simple construction: do not emit a rule's triggering attribute before that predicate activates. No red before red adjacency; no stars before edge-only stars; no blue before blue-corner restrictions; no yellow before yellow/green row exclusion; no odd number before left-column odds; no triangles before triangle-column exclusion. Earlier tokens therefore cannot violate newly arriving rules, regardless of where the player legally placed them. Once active, normal placement rules enforce compatibility. This is specific to these predicates, not a general puzzle-generator algorithm.

Observed evidence: all 1,000 generated seeds completed via their validated 16-move witness, through every rule stage. 200 alternative legal player paths preserved existing-board compatibility; 111 legitimately ended with zero available next-token cells. Generation used at most 3 of the permitted 8 attempts in that sample, with 0 normal-budget fallbacks. Three of 100 single-attempt runs exhausted their budget and used the known-solvable fallback; forced zero-budget fallback also passed. This sample does not predict difficulty or fun.

# Duplicate strikes need an attempt counter

Rule: consuming an illegal in-board placement must advance the authoritative intent counter even if the accepted-placement count stays fixed. Otherwise replaying an identical illegal request can apply another strike.

Observed evidence: production Run/Sessions tests reject duplicates after both accepted and illegal moves, ignore old IDs after restart, isolate 20 sessions, and prevent malformed/out-of-range/over-rate requests from changing score or strikes. Snapshots copy public data and exclude seed, future token sequence and hidden witness.

Not verified here: actual RemoteEvent delivery, engine/input behavior, UI readability, real-network performance, phone usability or sustained gameplay enjoyment. These require the separate owner playtest in the source game.
