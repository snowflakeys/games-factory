# Definition of done

Only the root `AGENTS.md` defines the factory's mandatory policy. These checks make its gates reviewable.

## Before development

- The idea comes from Snow's queue and has a short, searchable game name.
- The spec states the core loop, win condition, required systems, mobile controls, and a clippable moment.
- Snow's spec approval is recorded with a date and a reference to the approved version or message.
- Fewer than two games are awaiting Snow's playtest. A WINNER takes priority over new games.

## DEV-COMPLETE — agent records

- The full approved core loop is playable from start through win/loss and the next round or replay.
- Controls and UI support mobile. Hits, scores, rewards, and round state are authoritative on the server.
- The game has its own Rojo project, source, meaningful logic tests, spec, decisions, backlog, and completion report.
- Formatter check, lint, and logic tests pass. Record the commands and results; CI must run these checks. Do not claim a remote CI run passed unless observed.
- Shared systems are pinned to an explicit copy or immutable version. No older game's dependency is silently changed.
- The approved implementation addresses the default permanent 2x boost gamepass and optional ad-for-15-minute-XP-boost reward. Document missing product configuration or integration limits; do not grant benefits for unverified purchases or ad completion. Never pressure Robux purchases.
- `assets-needed.md` contains ready-to-paste icon, thumbnail, and effect prompts following the style bible. Report missing final artwork plainly.
- `marketing.md` contains 5–10 clip ideas with hook lines and captions for Snow's manual, free distribution.
- Minor defects are in the backlog. A broken core loop, unsafe client authority, or failing required check blocks DEV-COMPLETE.
- The report lists implemented behavior, test evidence, known limitations, and clear playtest steps. Factory state is updated.

DEV-COMPLETE is an agent development milestone. It does not establish playtest success or release readiness.

## PLAYTESTED — Snow records

- Snow has played the game and provided findings; record the date and evidence.
- Every correction becomes a linked knowledge rule with an honest evidence tag.
- Report unresolved findings. Do not silently treat playtest completion as approval to release.

## RELEASE-READY and LIVE — Snow's approval required

- Record Snow's explicit publish approval for the specific release before marking RELEASE-READY.
- Record the target place and tested revision. Winner updates are developed in a separate test place.
- Snow performs all uploads and releases, including Saved versions. Agents prepare local artifacts and owner steps only; record Snow’s resulting version/place evidence before marking LIVE.

## Outcome

Use dated Creator Dashboard day-1 retention and average session length. Do not substitute player count or invented metrics. Snow judges WINNER or DEAD; record each DEAD reason as `NOT FUN` or `NOT DISCOVERED`. Stop work on DEAD games. Focus all agents on a WINNER.
