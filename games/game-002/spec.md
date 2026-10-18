# Don't Match Me — v1 approval draft, revision 1

- Game: game-002; queue: idea-002; draft date: 2026-10-16.
- Status: SPEC-PENDING. Spec approval and monetization exception: PENDING.
- Selection evidence: Snow asked to "move the 2nd game" in this conversation. Interpreted as second in the imported research build order, Don't Match Me. This does not approve the scope below. Actual wording and interpretation are retained in idea-queue.json.
- Input reference: knowledge-base/microgames/specs/dont-match-me.md, imported design research rather than verified demand or measured fun.

## Pitch and core loop

Pick a symbol secretly, reveal everyone's picks together, and score according to the visible rule. Predict what others will pick without seeing their current choices. Nobody is eliminated. Eight short rounds decide the match, followed by a quick replay. Pure UI, no 3D map.

## Proposed frozen v1 scope

1. One shared match per server, supporting 1–16 human players. Fill empty seats with visibly labeled bots until there are at least four participants. One human gets three bots; two get two; three get one; four or more get none. Recompute only between rounds. Pause with zero humans; the next human begins a fresh match.
2. Eight rounds per match. Each round has 6 seconds to choose, 2 seconds of reveal, then 1 second before the next round. A match starts within 1 second when a human arrives to an empty server. Results last 6 seconds before automatic rematch. A PLAY AGAIN button lets current humans mark ready; if all currently connected humans are ready, start the next match after a 1-second transition. Joining during results clears only that newcomer's ready flag; the automatic deadline still applies.
3. Show four symbols for round rosters of 4–8 participants and six for 9–16. Symbols use stable IDs and distinct labeled shapes (circle, star, triangle, square, diamond, heart); color is supplementary. Every participant sees the same legal symbols and round rule.
4. Three scoring predicates in a fixed, visible schedule: rounds 1–2 UNIQUE, 3–4 PAIRS, 5–6 MINORITY, 7–8 UNIQUE. UNIQUE: a symbol picked by exactly one participant earns that participant 1 point. PAIRS: exactly two picks earn those two participants 1 each. MINORITY: when at least two distinct symbols were picked, participants on any smallest nonempty group earn 2 each; ties for smallest group all qualify. If everybody picked the same symbol, nobody scores in MINORITY. Empty symbols and missed submissions never score. No negative points, stealing, multipliers or elimination.
5. Server resolves exactly once at its deadline, even if everyone chose early. Highest total after round 8 wins; ties are shared wins. Show each round's choices, points gained, running standings, final winners and rematch controls. No persistent records, currency or XP.
6. Bots lock choices before human input can affect the current round. Their pure policy accepts only a seed, legal choices, current public modifier and previous revealed history. Mix seeded randomness with simple public-frequency preferences; no LLM/API and no access to current human submissions. Bots remain clearly identified as bots.
7. Freeze membership at the start of every round. A new arrival joins the next choosing phase, with zero current-match points and an explicit "joined mid-match" label; explain the next-round countdown while waiting. A departing player's already-accepted choice remains in the current reveal/scoring counts; an unsubmitted choice stays missing. Never replace a departed participant with a bot mid-round. Retain ephemeral scores keyed by participant ID until match end, so reconnecting to that same server/match rehydrates them; no cross-server or saved progression. Human participation is needed in at least one completed round to appear among final human winners. Bots may win the match and are labeled accordingly.
8. Touch-first one-tap choice, private server acknowledgement and locked selection until reveal. Show round number, modifier explanation, server deadline countdown, number locked (without identities), own score, symbol buttons, reveal and scrollable standings. Own score/rank and primary actions remain visible; no avatar, purchases, movement or chat-driven gameplay.
9. Server owns membership, match/round IDs, deadlines, choices, bot policy/seed, resolution, score and winners. Clients send only semantic choice or rematch-ready intents with the current IDs, plus read-only sync. Exact schema/type/choice/membership/phase/deadline checks; first valid submission locks, duplicates cannot change it. Reject stale, malformed, out-of-range, extra-field and late requests without points or side effects. Per-player rate limit: burst 6, refill 3 requests/second, including invalid traffic; excess can be dropped and recovered with read-only sync. Never trust client timestamps or scores.
10. Each player's choosing snapshot exposes legal symbols, public rule/deadline/standings, aggregate locked count and only that player's own acknowledged selection. Other picks, seeds, bot commitments and unrevealed state stay server-side until reveal. Respawn rehydrates that player's state. Disconnect cleanup cannot end the match for other humans. Network retries do not replay unacknowledged choices automatically.

## Pure logic and meaningful Lune tests

Pure Luau: choice model, three scoring predicates, bot policy, roster/bot filling, phase/deadline transitions, eight-round totals/winners, validation/rate/session model, public/private snapshot filtering and rematch readiness. Roblox services, clocks, remotes, input, rendering and player lifecycle remain thin adapters. Reuse narrow proven patterns from game-001; do not build a universal framework or silently couple games.

Required tests before DEV-COMPLETE:

- Exhaustively resolve small choice combinations for each predicate, including ties, one nonempty group, missing choices and all misses. Verify independent expected scores, not only example matches.
- At least 10,000 seeded simulated rounds across 1/2/4/8/12/16 humans, including bot-filled low population, legal choices, bounded scores, deterministic replay and 16-player behavior.
- End-to-end eight-round matches and rematches; deadline equality is late; resolve exactly once; no awards before reveal or after terminal resolution.
- Adversarial schema, unknown action, fake player/score/time claims, duplicate/change-choice attempts, stale match/round IDs, late input, over-rate/refill, disconnect before/after submission, joins and respawns during every phase.
- Snapshots never expose another player's current choice or hidden bot commitment before reveal. Mutating a snapshot cannot mutate server state. Bot policy's inputs contain no private human choices.
- Shared wins, all-zero scores, bots winning, readiness quorum, late-ready intents, results timeout and zero-human pause/restart.
- Run python scripts/check.py without weakening gates. Local Rojo builds are not engine/device evidence.

## Mobile and owner acceptance

All interactive UI lives inside CoreUISafeInsets. Choice targets are at least 64x64 logical pixels; primary actions at least 48px high. Support safe rectangles around 320x480 portrait and 568x300 landscape plus tablets/desktop; use adaptive arrangements and scrollable standings, with no offscreen essential controls. Distinguish symbols with shapes and text, not color alone. Provide readable feedback if the server has not acknowledged a tap; timeout sync cannot accidentally submit a second choice.

Studio/device verification must cover 1/2/4/8/12/16 humans where practical, phone rotation/notches, small screens, actual remote privacy, rapid taps, latency, phase changes, respawn, leave/rejoin and quick rematches. These remain unverified until performed. Target first meaningful choice within about 20 seconds even for a mid-match join. Snow judges ten consecutive rounds and repeat matches without rewards: solo and two-human play must stay interesting, and larger rosters must stay readable.

## Monetization exception proposed for approval

Propose no monetization, XP, ads, purchases or product IDs for this v1 prototype. Multiplying competitive score would change the win condition; adding cosmetic progression would expand this narrow test. Snow must approve this game-specific exception with the spec. Game-001's exception does not automatically apply here. If Snow wants the factory defaults, revise the reward/XP scope before approval; do not implement competitive paid advantages.

## Clippable moment and hypothesis

Everyone avoids the obvious symbol, one participant picks it anyway and gets the only UNIQUE point; the following PAIRS rule flips the group strategy. Hypothesis: prediction and the visible two-round rule cadence create voluntary rematches without progression rewards. This is a design hypothesis, not a claim about measured demand.

## v1.1 backlog and exclusions

Extra modifiers, private forbidden symbols, stealing, daily seeds, ranked ladder, parties/private rooms, teams, spectator tools, persistent wins, achievements, cosmetics/XP, monetization, custom art/audio/haptics and advanced bot difficulty. No map, 3D characters, free-form text, paid randomness or eliminated-player waiting. Park later ideas here unless Snow explicitly revises approved scope.

## Approval gate

Approve this exact spec revision (or its committed SHA), including the proposed no-monetization exception, before game.json changes to BUILDING. Preparing this draft and scaffold does not approve gameplay implementation, PLAYTESTED or publishing.
