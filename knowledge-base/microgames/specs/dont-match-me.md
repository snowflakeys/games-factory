> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Don't Match Me

**Pitch:** Everyone secretly taps one symbol. Reveal together. Unique picks score, and rotating modifiers change the psychology.
**Family:** Simultaneous-choice micro-party. **Players:** bots for solo; 2-12 (ideal 4-8). **Map:** none.
**Research rank:** 1st by score; recommended **second release** (reuses #1's UI/seed/analytics/mobile systems, adds the reusable simultaneous-round network layer).
**Estimate (engineering judgment):** 2-4 d MVP, plus time for reveal effects, player-count balancing and mobile/network testing.

## Gameplay

- Each round shows the same 3-6 large symbols. 4-7 seconds to pick secretly; server locks and reveals all at once.
- Default scoring: a symbol chosen by exactly one player scores 1; duplicates score 0.
- Every 2-3 rounds a highly visible modifier changes one element: "exact pairs score", "least-picked symbol scores two", "last round's winning symbol is blocked", "matching the leader steals a point", "everyone gets one private forbidden symbol".
- First to 8-12 points, or highest score after 90 seconds. Nobody is eliminated.
- Solo: three rule-based bots, same mechanic. Difficulty changes bot prediction quality, never gives bots hidden information.
- 2-player needs a third virtual "house" choice or a rotating bonus symbol to avoid trivial alternating equilibria. 12 players: expand from four to six symbols.
- Progression: almost entirely cosmetic plus rule discovery (badges, button skins, reveal effects, titles, advanced-modifier playlists). Daily fixed-seed tournament uses predetermined bot tendencies and deterministic modifier order.

**Long-term expansion is a curated modifier library that changes psychology, not more buttons:** unique wins; exact pair wins; majority loses; last winner can't repeat; visible rotating bonus; one symbol secretly worth double to one player; teams change for one round; predict another player before choosing.

## Technical

- Server-authoritative rounds. Client receives `RoundId`, legal choices, modifier, deadline. Client sends only `{RoundId, ChoiceId}`.
- Server validates membership, choice legality, duplicate submissions and deadline before committing.
- Modules: `RoundStateMachine`, `ChoiceResolver`, `ModifierRegistry`, `BotPolicy`, `ScoreService`, `SeededRandom`, `RemoteValidator`, `PlayerRoster`, `CosmeticService`, `AnalyticsEvents`, shared `UIFeedback`.
- Client owns buttons, touch state, animations, sounds, local countdown display. Server owns deadline timestamps, accepted choices, modifier logic, scores, win conditions.
- Persist only cosmetic ownership, unlocked modifier/tutorial state, wins, personal records, settings. Don't persist round-critical state unless reconnect support later justifies it.
- Exploit risks (all neutralized by server authority): submitting after reveal, invalid choices, multiple submissions, spoofed round id, manipulated local countdown.

## MVP phases

1. Four-choice rounds, server reveal, scoring, rematch, three bots.
2. Reveal animation, audio/haptics, player portraits, responsive mobile layout, sub-five-second transitions.
3. 8-12 modifiers, bot personalities, daily challenge, cosmetics.
4. Test 1/2/4/8/12-player servers, reconnects, leaving during submission, duplicate remotes, aspect ratios, real network delay.

**Postpone:** daily challenge polish, ranked ladder, parties, subscriptions, elaborate cosmetics. **Do not postpone bots, mobile layout or rematch speed.**

## Agent task split

Spec agent formalizes each modifier as pure input/output rules with edge cases; rules agent builds `ChoiceResolver` + deterministic tests; server agent builds transitions/remotes; UI agent builds buttons and reveal; bot agent builds probability-weighted heuristics (e.g. frequency tracking); QA agent runs generated simulations across player counts and modifiers.

## Human checks

Do repeated mind games stay fun? Are icons readable at phone size? Do reveals feel exciting?

## Metric chain

`first round completed → voluntary rematch → third round → completed match → joined another match` (more telling than minutes played).

## Go / no-go

2-player and bot sessions are fun enough to survive low concurrency; 4-8 players feels better, not just noisier. Base rule is shallow, so modifier cadence is the main design risk.
