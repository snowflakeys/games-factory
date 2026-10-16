> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Microgames Knowledge Pack

Research on Roblox microgames (UI-first, tabletop, micro-party) for the game factory. Written to be read by any coding agent or human: no model-specific instructions.

- **Source:** AI-generated deep-research report, received 2026-10-16. Condensed and restructured here.
- **Evidence status:** Roblox stats, reference-game numbers and platform-policy claims come from that report and are **not independently verified**. Scores and build-time estimates are the report's own judgment, not measured data. Re-check anything load-bearing before relying on it. See `platform-and-evidence.md`.
- **Not a decision log.** The build order below is the research's recommendation. What the factory actually builds next is decided in the factory's own planning docs.

> Platform rules (who can see a new game, fees, ads eligibility, tooling) are verified separately in `../roblox-platform-rules.md`. Where this pack and that file differ, that file is newer.

## Contents

| File | Read it when |
|---|---|
| `design-principles.md` | Before proposing or judging any game idea |
| `greenlight-checklist.md` | Before committing build time to an idea; includes the scoring rubric and release gates |
| `idea-catalog.md` | Looking for the next idea; 40 concepts with rank, build estimate, risk |
| `engineering-patterns.md` | Before touching code; project layout, reusable modules, testing, agent workflow |
| `release-playbook.md` | Before shipping or updating; bundle strategy, metrics, monetization, retention |
| `platform-and-evidence.md` | Checking where a claim came from, or what is still unknown |
| `specs/*.md` | Building one of the top five games |

## The thesis in one paragraph

Do not ask "what full Roblox genre can an agent build cheaply?" Ask **"what single decision stays interesting after the hundredth repetition?"** Games built on prediction, constraints, inspection or rule-driven chaos get their replay from rules and other players, not from maps, combat or hundreds of collectibles. That makes them cheap to build, easy to test automatically, and quick to show their hook.

## Research-recommended build order

| # | Game | Capability the factory gains | Go/no-go |
|--:|---|---|---|
| 1 | Rule Stack | Responsive UI, drag/drop, seeded challenges, procedural validation, daily mode, analytics | Players restart after failing without needing progression rewards |
| 2 | Don't Match Me | Match state machine, server-authoritative simultaneous choices, bots, rematch, multiplayer analytics | 2-player and bot sessions stay fun at low population; 4-8 players feels better, not just noisier |
| 3 | Last Safe Number | Proves reuse of the party framework | Ships mostly from shared systems; if it isn't dramatically cheaper than #2, stop and fix the reuse strategy |
| 4 | Alien Customs Desk | Procedural case engine, hidden server state, workstation UI | Generated cases stay understandable and funny over hundreds of simulations |
| 5 | Screen Collapse | Plugin-style tasks, chaos director, advanced responsive UI | Escalation stays readable on mobile and produces funny failures, not annoyance |

Why Rule Stack before Don't Match Me even though Don't Match Me scored higher: Rule Stack works at one concurrent player, so the first release doesn't depend on solving multiplayer cold start.

## How agents should use this pack

1. Proposing a game: read `design-principles.md`, then run the idea through `greenlight-checklist.md`.
2. Building: read the game's file in `specs/` (or write one in the same shape), then `engineering-patterns.md`.
3. Shipping: pass the four gates in `greenlight-checklist.md`, follow `release-playbook.md`.
4. After release: write a postmortem (fields in `engineering-patterns.md`) and add anything reusable back to this pack. Keep entries short and only for things that matter.
