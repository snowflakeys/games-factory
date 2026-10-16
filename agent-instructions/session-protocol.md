# Session protocol

Root `AGENTS.md` is canonical. This protocol implements it without a second state model.

## Orient

Read `factory-state/state.json`, `idea-queue.json`, and `checkpoint.md`; inspect Git status and recent commits. Read the active game's `game.json`, `spec.md`, decisions, backlog, and relevant knowledge. Historical planning notes do not select an active game.

If no game is active, scaffold only from Snow's queue using `python scripts/factory.py new-game --idea idea-NNN`. An empty queue is a real blocker. At SPEC-PENDING, draft the spec and hand off for Snow's approval. Never invent an idea, approval, or playtest result. Explicit batch approval must identify each spec and revision and be recorded per game.

## Build and verify

Freeze the approved v1 acceptance criteria. Complete the full approved loop before marking DEV-COMPLETE. Work in testable slices and checkpoint if the session ends early; a slice alone is not development completion. New ideas go to v1.1 unless Snow explicitly revises scope.

Keep deterministic rules in pure Luau modules with Lune tests. Keep Roblox adapters thin. Run `python scripts/check.py`; record failures without bypassing them. Treat a failed Roblox standard-library download as a lint blocker, not a passing lint check. Test remote validation, duplicate/late input, disconnects, ties, and replay where applicable.

Cloud agents can edit, run pure logic, and build local Rojo artifacts. Studio integration, emulator behavior, real-device controls, physics, and fun require separate evidence. Studio automation requires an available local Studio session and must use the test place. Never test against the live place.

## Owner-only actions

All Roblox uploads, including Saved versions, and all releases are owner-only. Agents never execute `scripts/publish-place.sh`. Publishing keys must not be available to agents or CI. Agents also do not answer questionnaires, pay fees, or verify accounts. Prepare local artifacts and exact owner steps instead.

## Handoff

Update registry and per-game metadata only from actual evidence. Write the checkpoint and game completion report with: date and environment, scope completed, changed files, exact checks and outcomes, unverified engine/device behavior, blockers, parked v1.1 ideas, and the next concrete action. Commit intended changes. Do not claim hosted CI passed until observed.

Stop for missing owner input or approval, a real environmental blocker, or the session limit; leave a resumable checkpoint. Do not begin another game before completing the current approved loop. Respect the two-game playtest waiting cap and WINNER priority.
