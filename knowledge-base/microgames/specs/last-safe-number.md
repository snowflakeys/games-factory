> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Last Safe Number

**Pitch:** Everyone picks a number at once. Duplicates cancel. Highest unique number scores.
**Family:** Simultaneous-choice tabletop. **Players:** bots for solo; ideal 4-8. **Map:** none.
**Research rank:** 5th by score; **easiest to ship** and the best **factory infrastructure test** (proves the party framework gets reused).
**Estimate (engineering judgment):** 1-day core prototype; 2-3 days release MVP. A prototype is not a polished product.

## Gameplay

- Number cards 1-5 each round, 5 seconds to choose secretly.
- At reveal, any number picked by more than one player is crossed out; highest remaining unique number scores 1.
- Every third round uses a modifier: lowest unique wins; numbers 4-5 are unsafe; exactly two matching players both score; your previous choice is locked; number 1 is worth two; choose two numbers but the second costs a point if both survive.
- A public "danger forecast" can show that one region of the range will lose value.
- First to 7 wins. Nobody is eliminated. Reveal under 2 seconds so the next prediction starts immediately.
- Solo: 3-5 bots with visible personality tags ("Repeater", "Greedy", "Avoider", "Chaos"), making bot exploitation part of the game.

## Technical

Essentially a reusable simultaneous-choice engine:

`Lobby → Countdown → AcceptChoices → Lock → ResolveDuplicates → ApplyModifier → Score → Reveal → NextRound → MatchEnd`

- Modules: `MatchStateMachine`, `ChoiceCollector`, `NumberResolver`, `ModifierRegistry`, `BotPolicy`, `ScoreService`, `SeededRandom`, `RemoteValidator`, `RematchService`.
- Payload: choice id + round id only. Server controls timers and resolution.
- Intended base for Don't Match Me, Copycat Trap, voting games and later party prototypes.

## MVP phases

1. Five number buttons, server submit, reveal, duplicate cancellation, scoring, simple bots (one-day prototype).
2. Animation, sound, responsive UI, rematch, 2-8 player testing.
3. 8-10 modifiers, bot personalities, cosmetics.
4. Timeout / leave / rejoin tests; confirm all player counts stay interesting.

**Postpone:** ranked matchmaking and long-term progression, entirely.

## Agent task split

State machine agent, resolver-test agent, bot agent, UI agent, and an attacker agent firing malformed/late submissions at the remotes.

## Human checks

Almost all human QA is one question: does the modifier mix keep predictions interesting after 30-60 minutes?

## Go / no-go

Ships mostly from systems built for game 2, proving real (not theoretical) reuse. **Commercial weakness is depth:** if a 30-minute playtest shows the social meta is exhausted, cancel it or bundle it. Don't bolt grind on.
