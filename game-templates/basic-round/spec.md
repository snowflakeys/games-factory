# {{GAME_NAME}} — spec

- Game: {{GAME_ID}}
- Snow's queue idea: {{IDEA_ID}}
- Draft date: {{DATE}}
- Status: SPEC-PENDING
- Snow's spec approval: PENDING
- Approval evidence and date: PENDING

## One-sentence pitch

PENDING — describe only the queued idea Snow supplied.

## Core loop

PENDING — explain the player's action, immediate feedback, round end, and replay in a few sentences.

## Win condition

PENDING — define exactly how the server selects winners and handles ties, disconnects, and too few players.

## Minimal systems

PENDING — list only systems required by this loop. Specify player limits, round timing, respawn behavior, and any persistence that the loop actually needs.

## Mobile controls and UI

PENDING — specify touch interactions, readable UI, safe-area behavior, and how players learn the core action.

## Server authority

The server owns round state, hit validation, scores, rewards, and win decisions. PENDING — define allowed client requests and server validation/rate limits. Never accept a client-supplied score or reward.

## Monetization and rewards

Default plan: a permanent 2x boost gamepass, an optional rewarded ad for a 15-minute XP boost, and rewards. PENDING — define the exact boost/reward, required XP behavior, stacking rules, and platform eligibility before implementing. Never push Robux purchases. Record any Snow-approved exception in `decisions.md`.

## Clippable moment

PENDING — describe one moment created by this loop; expand approved ideas in `marketing.md`.

## Scope and acceptance

PENDING — list measurable conditions for a full playable session and explicit exclusions. Build the playable loop after Snow approves this spec. DEV-COMPLETE means implementation and required checks pass; Snow's playtest and publishing approval are separate gates.
