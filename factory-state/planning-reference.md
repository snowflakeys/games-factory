> Historical planning reference, not the active registry. These chat-derived games and statuses are unconfirmed. Read `state.json`, `idea-queue.json`, and `checkpoint.md` for current state. No games or approvals were added by this import.

# Factory Status

Single source of truth for where every game stands. Update at the end of every session.

**States:** `idea` → `spec` → `v1-frozen` → `building` → `verify` → `ship-prep` → `released` → `scaling` / `dead`
Kill rule: if a released game isn't fun or isn't attracting players, mark it `dead` and move on. Scaling means all agents focus on it. Thresholds live in `kill-or-scale.md` (not written yet; owner sets the numbers).

## Games

| Game | State | v1 scope (frozen) | IDs (Universe / Place) | Audience reached | Blocked on | Last session | Next task |
|---|---|---|---|---|---|---|---|
| Dig to the Core | v1-frozen (build prompt next) | One core dig action, sell station, five upgrades, three zones (Dirt, Caves, Magma), data saving | not created yet | none yet | Owner: first Studio publish for IDs | | Build session from the Claude Code prompt |
| BIG ONE (10 vs 1, minimal style) | spec | Spec requested; art follows the identity style | not created yet | none yet | Full build spec | | Write the spec through the greenlight checklist |

Entries above come from planning chats. Verify before relying on them.

## Parked ideas

- Randomizer race (extreme random events): parked in favor of the grind-loop first ship.
- Research-pack candidates (`knowledge-base/microgames/idea-catalog.md`): Rule Stack, Don't Match Me, Last Safe Number, Alien Customs Desk, Screen Collapse. Recommendation only, not a queue.

## Owner account checklist

Record once done (the dates matter if rules change):

- [ ] Age check completed (date):
- [ ] Verified (facial age estimation / government ID) (date):
- [ ] 2-step verification on (date):
- [ ] Decision: Plus / Premium (2 consecutive months) or the 1,000 Robux per-game fee for all-ages:
- [ ] Open Cloud API key created and stored in the agent environment (scope: place publishing; separate key for Luau Execution on the test place):

## Decision log

| Date | Decision | Why |
|---|---|---|
| 2026-10-16 | Added agent entry file, session protocol, ship checklist, pipeline and platform rules docs | Scheduled sessions need shared state and a known path to release |
