> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Alien Customs Desk

**Pitch:** Check strange visitors' documents against a rules board that keeps changing. Stamp ALLOW or DENY, fast.
**Family:** Compact inspection / minimal-space simulation. **Players:** solo-first (optional 2-4 co-op/sabotage desk later). **Map:** one desk scene.
**Research rank:** 4th by score; strongest theme-mechanic combination and naturally clip-friendly (absurd rule combinations create funny errors).
**Estimate (engineering judgment):** 4-7 d for a solid MVP; more expensive than the party games.

## Gameplay

- A shift has 8-20 visitors. Each shows a portrait, a passport-like document, an optional permit, and one carried object.
- A pinned rules board starts with two regulations and adds/removes one periodically. Fictional examples: "Visitors with antennae require a triangle permit." "Orange cargo is allowed only before Day 4." "Moon citizens may bring one living object." "Visitors with exactly three eyes use the blue entry lane."
- Player inspects documents, may run one limited scanner operation, then stamps ALLOW or DENY.
- Correct fast decisions build a combo; mistakes cost reputation; expensive scans cost score but reveal a hidden property. That trade makes it a decision, not spot-the-difference.
- Harder shifts add interacting rules and ambiguity, **not document text length**.
- Two-player (one player has documents, the other the rule board) is an expansion, not MVP.

## Technical

- Generate each case from a canonical object model first (`VisitorTraits + DocumentFields + Cargo + HiddenTraits`), evaluate it through the active rules to get the objectively correct outcome, **then** let the presentation layer introduce mismatches or missing documents. This keeps content and answer logic from drifting apart.
- Modules: `RegulationRegistry`, `CaseGenerator`, `CaseEvaluator`, `DocumentRenderer`, `InspectionTools`, `ShiftState`, `DifficultyDirector`, `ScoreRules`, `SeededRandom`, `AnalyticsEvents`.
- Client: document movement, zoom, stamps, effects. Server: challenge seed, canonical case, allowed inspection actions, authoritative result if leaderboards matter.
- Persistence: shift records, unlocked desk themes, cosmetics, difficulty, achievements.
- **Biggest security risk:** a modified client exposing hidden case truth. Don't replicate secret fields to the client until an inspection legitimately reveals them.

## MVP phases

1. Ten trait icons, five regulations, one document template, allow/deny, generated cases.
2. Satisfying stamps, desk sounds, character reactions, transitions.
3. Rule changes, optional scanners, combo scoring, 25+ traits, daily shift.
4. Generate thousands of cases and verify the evaluator; manually test ambiguous visual combinations and mobile document manipulation.

**Postpone:** cooperative multiplayer, story, elaborate alien animation, a large campaign. The procedural desk is the product.

## Agent task split

Schema agent owns canonical case definitions; generator agent creates cases; **independent oracle/testing agent** verifies every generated case; UI agent renders data into documents without owning rules; security agent ensures unrevealed data never replicates.

## Human checks

Visual legibility and whether it's funny.

## Go / no-go

Generated cases stay understandable and funny over hundreds of simulations/playtests. Every case must be logically decidable. Avoid becoming a superficial *Papers, Please* clone.
