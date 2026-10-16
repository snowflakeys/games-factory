> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Release Playbook

## Bundle or standalone?

The report recommends a **hybrid**: keep distinctive solo loops standalone; pool compatible short party rounds into one shared experience. The reasoning is population and product identity, not code sharing.

| Factor | Independent | One bundle | Hybrid |
|---|---|---|---|
| Discoverability | Each concept gets its own icon/title/proposition; traffic fragments | One listing concentrates history and marketing | Distinct concepts stay distinct; compatible party games pool traffic |
| Cold start | Dangerous for 4+ player games | Strongest: all party traffic in one population | Strong if every multiplayer title has bots |
| Retention | Players aren't forced through other modes | Variety helps; weak modes can dilute a strong one | Deep solo loops standalone; compatible microgames combined |
| Analytics | Cleanest funnels | Cross-mode retention can hide which mode carries it | Fine if each mode logs identifiers |
| Updates | Isolated, but N games = N products | One update serves everyone | Shared tech + selective bundles |
| Technical coupling | Lowest | Highest if on one giant framework | Moderate: versioned shared modules, independent projects |

**Standalone candidates:** Rule Stack, Screen Collapse, Alien Customs Desk, Pack Panic, Desktop Disaster, Merge With Consequences, Tiny Repair Desk.

**Party Lab candidates** (short rounds, common lobby/scoreboard/reveal): Don't Match Me, Last Safe Number, Copycat Trap, Fake Timer, Count Without Counting, Freeze Frame, Human Loading Bar, Sort Sprint, plus selected tabletop rounds. Compatible party rounds can swap UI/state inside one server; multi-place Teleport architecture is rarely needed.

Never make a party game wait for a healthy population. Launch candidates need a solo mode, bots, async same-seed competition, or 2-player viability.

## Platform gating (as of 2026-10-16)

New games reach only age-checked 16+ users until they pass evaluation for under-16 audiences. This changes cold start and what "promotion" can convert. Details, thresholds and fees: `../roblox-platform-rules.md` and `agent-instructions/ship-checklist.md`. Rewarded ads are unavailable until about 2,000 monthly unique visitors.

## Before promotion

Pass all four gates in `greenlight-checklist.md` (mechanical, technical, first-minute, mobile). Newer experiences can enter recommendation testing with little history, which supports shipping small experiments, but impressions are not guaranteed.

## Retention: variation, not grind

First update for a successful game should usually add one or more of: new rules/modifiers that change decisions; a daily fixed seed; a second scoring mode; friend/party comparison; a few aspirational cosmetics; one new difficulty layer.

Don't immediately add pets, rebirths, ten currencies and a giant upgrade tree because a session-time graph looks short. Discovery signals include play days and retention, and per-user daily playtime is capped in some recommendation metrics, so raw session length isn't the only objective.

## Monetization (for these microgame types)

Best product is self-expression, not power.

| Category | Good | Avoid |
|---|---|---|
| Pure UI | Interface themes, cursor trails, board/token packs, sound packs, animated backgrounds | Extra moves that invalidate scores, better starting boards, paid hints in competitive modes |
| Tabletop | Card backs, dice looks, table surfaces, token sets, reveal animations | Stronger cards/dice, paid random competitive pieces |
| Micro-party | Victory poses, reactions, button themes, player frames, announcer packs | Paid sabotage, extra lives vs free users, priority wins |
| Desk sim | Workstation themes, stamps, scanners, cosmetic customer packs | Paying to remove deliberately annoying difficulty |
| Experimental | Screen themes, trails, visual chaos packs, sound sets | Mechanics that let buyers ignore the central trade-off |

- Passes fit permanent cosmetic packs. Developer products fit clearly disclosed, non-competitive consumables.
- Subscriptions on day one are usually poor judgment for a tiny game.
- Rewarded video should be optional and peripheral, never interrupting 10-second rounds. Test whether an ad reward hurts next-round continuation.
- **Paid random rewards: default "do not use".** No simulated gambling. For risk-themed tabletop, score is *round score*, not purchasable or tradable currency wagered on chance.

## Marketing and virality

Add a **clip test** to greenlighting: can a viewer with no context understand the setup, mistake, reversal or reveal in about 10 seconds? Don't Match Me, Screen Collapse and Alien Customs Desk pass; a spreadsheet-like scheduler with no dramatic state change does not.

## Post-release loop

1. Watch the first-session funnel (`engineering-patterns.md`).
2. Compare against the hypotheses in the game's spec.
3. Decide: iterate, pivot, or stop. If the loop isn't fun or players aren't coming, stop and move on rather than adding grind.
4. Write the postmortem and fold reusable lessons back into this pack.
