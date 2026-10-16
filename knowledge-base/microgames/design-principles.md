> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Design Principles

## The core rule

> A microgame gets its longevity from interactions between rules, randomness, skill and other players, not from having 500 things to collect.

Distinguish the **input loop** (what the player does) from the **content loop** (what has to be produced to keep them playing). One-button games with hundreds of collectibles have a trivial input loop but a huge content loop. The factory should avoid content-heavy loops.

## Mechanic families, in priority order

| Priority | Family | Why it fits |
|---|---|---|
| Highest | Simultaneous-choice social games | No elimination, tiny network payloads, instant reveal, easy bots, 2-12 players |
| Highest | Rule-changing UI puzzles | Work at zero concurrency, procedural, highly testable, "how did I survive that?" moments |
| Very high | Compact inspection / organization games | Touch-friendly, one screen, procedural jobs, strong theme without a map |
| Very high | Hidden-information tabletop | Cards/tokens are cheap assets; players supply the replayability |
| Selective | Shared-control chaos | Very clip-friendly, but latency hurts feel directly; carries a networking complexity penalty |

## Three kinds of replayability

1. **Mechanical**: a small rule set recombines (modifiers, constraints, piece sequences). Best for the factory, because code produces the variation.
2. **Social**: bluffing, simultaneous choice, sabotage, prediction. Even more efficient: human behavior is the content.
3. **Progression**: dailies, cosmetics, new modifiers, personal bests. Useful as a *multiplier* on a good game; never as life support for a weak one.

**Remove-rewards test:** strip currency, streak rewards, quests and unlocks. Would the player still press "Again"? If not, the design isn't ready.

## Rules of thumb

- **Show the real mechanic immediately.** First-play bounce matters. Don't make a new player walk through a lobby, read a tutorial and travel to "the real game". Target: first meaningful action within 20 seconds (an internal metric, not a Roblox benchmark).
- **Avoid elimination.** A player who loses a 10-second round should be choosing again 10 seconds later, not spectating.
- **Prefer simultaneous input + server reveal.** Adding players adds no turns, so it scales from 2 to 12. Sequential tabletop games: cap a table at 4-6 and run parallel tables above that.
- **Every multiplayer launch candidate needs one of:** a real solo mode; bots that preserve the decision structure; asynchronous same-seed / ghost competition; or a mechanic that is still meaningful at 2 players.
- **Bots are cheap when the action space is discrete.** Frequency trackers, weighted-random predictors, heuristic scorers. No ML needed. Give bots visible personality tags rather than pretending they're humans.
- **Chaos must be readable.** Difficulty scales by cadence and simultaneous task count, never by shrinking touch targets below accessible size.
- **Variation over grind in updates:** new rules/modifiers, a daily seed, a second scoring mode, friend comparison, a few cosmetics, one difficulty layer.
- **Postpone aggressively.** Each game's v1 has an explicit "postpone" list (see `specs/`). Park new ideas for a later version instead of growing v1.

## Avoid

| Avoid | Why |
|---|---|
| Playable gambling or simulated casino wagering as a theme | Roblox content rules prohibit it. Frame risk as score allocation, forecasting, drafting or push-your-luck, never as wagering chips/currency |
| Paid random items / selling spins or random competitive pieces | Extra policy and regional requirements; unnecessary complexity |
| Free-form text or unrestricted drawing | Creators are responsible for filtering; removing it shrinks the moderation and QA surface |
| Real-time shared control as an early project | Latency decides feel; "looks trivial, debugs badly" |
| A universal game framework built up front | Don't predict abstractions before three games have independently needed them |
| Paid power in competitive modes (extra moves, better starts, paid hints, paid sabotage) | See monetization table in `release-playbook.md` |
| Copying violent / adult presentation from reference games | Inappropriate for broad Roblox audiences |
