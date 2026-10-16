> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Greenlight Checklist and Scoring Rubric

Use before spending build time on an idea, and again before promoting a released game.

## 1. Hard filters (any "no" kills or redesigns the idea)

- [ ] Does it avoid playable gambling / simulated gambling and paid random competitive items?
- [ ] Can it avoid free-form text and unrestricted drawing?
- [ ] Is there a solo mode, bots, async same-seed play, or meaningful 2-player play (so it survives low population)?
- [ ] Would an age-checked 16+ player who spends on Roblox pick this up and keep playing? (Evaluation for under-16 audiences counts engaged 16+ players first.) Is the content still safe enough for a Minimal/Mild/Moderate rating?
- [ ] Is the content loop small? (No dependence on dozens of collectibles to stay interesting.)

## 2. Quick tests

| Test | Pass condition |
|---|---|
| **Hundredth repetition** | Name the single decision that stays interesting after 100 repeats |
| **Remove-rewards** | Without currency, quests, streaks, unlocks, would players still press "Again"? |
| **Clip test** | A viewer with no context can understand the setup, mistake, reversal or reveal in about 10 seconds |
| **20-second first action** | A new player completes a first meaningful action within 20 seconds |
| **Solvability** | Every procedurally generated state has a solution (built forward from a legal state, not random-and-hope) |
| **Combinatorics** | Count modifier interactions: ten modifiers are not ten test cases. Can it be property-tested or simulated? |

## 3. Scoring rubric (0-100 per dimension)

| Dimension | Weight |
|---|---|
| Development simplicity (include networking, procedural validation, mobile QA, integration, not just code length) | 25% |
| Replayability | 25% |
| Originality | 15% |
| Roblox audience suitability | 15% |
| Social / viral potential | 10% |
| Maintenance / reuse | 10% |

`Total = 0.25*Dev + 0.25*Replay + 0.15*Orig + 0.15*Fit + 0.10*Social + 0.10*Reuse`

The report's scores are comparative design estimates, not measured player data. A one-point gap between ideas is noise. Use totals only to separate clear tiers. The 40 scored ideas are in `idea-catalog.md` (the top five scored 92.2-94.5; the bottom of the list 84.0).

**First-release adjustment:** the formula scores a *game*. The first factory project should also minimize launch-population dependency and maximize reusable engineering lessons, which is why Rule Stack (3rd by score) is recommended before Don't Match Me (1st).

Blank template:

| Idea | Dev | Replay | Orig | Fit | Social | Reuse | Total | Notes |
|---|--:|--:|--:|--:|--:|--:|--:|---|
| | | | | | | | | |

## 4. Release gates (all four before any promotion)

| Gate | Required evidence |
|---|---|
| **Mechanical** | Ten consecutive rounds/tasks stay enjoyable with no rewards or progression |
| **Technical** | Clean 1/2/4/8/12-player behavior where applicable; no impossible procedural states; remote validation tested |
| **First-minute** | New testers understand and perform the core action without external explanation |
| **Mobile** | Several aspect ratios tested; no overlapping controls; drag/tap targets comfortable |

## 5. Kill / pivot rules

- If a 30-minute playtest shows players have exhausted the social meta (e.g. Last Safe Number), cancel or bundle it. Do not attach grind to rescue it.
- If project N+1 isn't dramatically cheaper because of project N's reusable code, stop and examine the reuse strategy before adding more abstraction.
- Post-release, compare analytics against the hypotheses written in the game's spec, then decide: iterate, pivot or stop.
