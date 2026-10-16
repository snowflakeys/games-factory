# GAME FACTORY: AGENT INSTRUCTIONS
(Canonical file: AGENTS.md. CLAUDE.md and other agent files only point here.)

## Mission
Build many simple Roblox games fast, one at a time, and learn from each. Games with minimal systems and one core loop, competitive or round-based, finished in one short session. Snow is the owner and playtester.

## Repo
agent-instructions/ · game-templates/ · shared-systems/ (Universal Blocks Engine goes here) · knowledge-base/ · factory-state/ · games/game-NNN/ (own Rojo project, spec, assets, tests, decisions, report)
Each game pins its own copy or version of shared systems. Never edit a shared module in a way that breaks older games.

## Session start
Read factory-state, find the active game, check recent commits, load only the relevant knowledge-base entries, continue from the last checkpoint. Session end: commit and update factory-state.

## Game cycle
1. Take the next idea from Snow's queue. Do not invent trends; you have no live Roblox data.
2. Write a short spec (core loop, win condition, systems needed). Snow approves it.
3. Build the full playable game. Don't stop for polish or relitigate decisions.
4. Mark it DEV-COMPLETE. This does not mean tested or release-ready.
5. Log minor bugs in a backlog. Write a completion report.
6. Extract lessons, then start the next game.
WIP cap: at most 2 games waiting for Snow's playtest. Don't start more until he clears one.

## Non-negotiable rules
- Mobile-first UI and controls. Most players are on phones.
- Server authority: never trust the client for hits, scores, rewards or round state.
- Minimal systems. If a feature isn't needed for the core loop, don't build it.
- Lint, formatter and logic tests run in CI. Passing is required for every agent.
- Default monetization: a permanent 2x boost gamepass, "watch an ad for a 15-minute XP boost," rewards. Never push Robux purchases.

## Status flow
DEV-COMPLETE → PLAYTESTED (Snow) → RELEASE-READY (Snow approves publish) → LIVE → WINNER or DEAD

## Human gates
Snow approves the spec, playtests daily, and approves every publish. Never publish by yourself.

## Judging games
Use day-1 retention and average session length from Creator Dashboard, not player count alone. Log every dead game as NOT FUN or NOT DISCOVERED. Dead games get no more effort.
If a game wins, all agents focus on it. Develop updates in a separate test place and get Snow's approval before pushing live.

## Knowledge library
Start empty. Add entries only for important parts (mobile UI, networking, data saving, exploits, etc.).
Tag each entry VERIFIED or UNVERIFIED and link its source game. Every correction Snow makes in playtesting becomes a rule.

## Assets
You can't draw them. Write games/game-NNN/assets-needed.md with ready-to-paste ChatGPT image prompts (icon, thumbnail, effects). Follow the art style bible. Give each game a short, searchable name.

## Marketing (free only, no ad spend)
Design clippable moments into the game. Write marketing.md: 5-10 clip ideas, hook lines and captions. Snow uploads manually. No bot accounts or mass duplicate posting.


## Imported research and operational references
Read `knowledge-base/microgames/README.md` for the imported idea catalog and draft specs. Operational references are in `agent-instructions/session-protocol.md`, `ship-checklist.md`, and `roblox-pipeline.md` (paths relative to that folder). These references are subordinate to this file. `agent-instructions/proposed-policy.md` contains an unadopted policy proposal; `factory-state/planning-reference.md` contains unconfirmed planning history. The existing registry and queue remain authoritative.
