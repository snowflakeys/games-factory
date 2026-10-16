> Imported reference/proposal from Snow’s 2026-10-16 document pack. Root `AGENTS.md` remains canonical; existing approval gates, full-core-loop completion, CI requirements, and state schema take precedence over conflicting examples here. No policy replacement is approved by this import.

# Session Protocol

How one scheduled or ad-hoc agent session runs. Written so any agent can follow it.

## 1. Know your environment first

What you can do depends on where you run. State which one applies in your handoff note.

| Capability | Cloud / headless session | Desktop session (owner's PC with Studio open) |
|---|---|---|
| Edit files, run git | Yes | Yes |
| `rojo build` to a `.rbxl` | Yes (if Rojo is installed) | Yes |
| Pure-logic tests (no Roblox engine) | Yes | Yes |
| Publish a **Saved** version via Open Cloud | Yes, with `ROBLOX_API_KEY` in env | Yes |
| Make a version **live** (`Published`) | Only when the owner has said so in the task | Same |
| Headless engine tests via Luau Execution | Yes, against the **test place** only | Yes |
| Studio MCP (read tree, run playtest, screenshots, input simulation) | **No** (needs Studio running locally) | Yes, after the owner enables it |
| Real-device feel, humor, fun | **No** | Owner only |
| First-ever publish (creates the Universe and Place IDs) | **No** | Owner does it in Studio |

Rules that follow:
- A cloud session can write and verify logic, build, and push a Saved version. It cannot judge fun or mobile feel. Flag those as **owner playtest needed**.
- Never run Luau Execution or tests against the live place.

## 2. Session types

Pick one type per session. Don't mix.

| Type | Output | Ends when |
|---|---|---|
| **Spec** | `spec.md` with v1 list, v1.1 list, hypotheses, go/no-go | Spec passes the greenlight checklist |
| **Build** | Working code for part of the v1 list, tests passing | The chosen slice is playable or testable |
| **Verify** | Test runs, exploit/malformed-input attacks, mobile layout checks | Failures fixed or logged with repro seeds |
| **Ship prep** | Items on `ship-checklist.md` that agents can do; owner steps written out | Everything agent-doable is done |
| **Research** | A short note added to `knowledge-base/` with sources and date | Question answered or marked unknown |
| **Review** | Postmortem or kill/scale recommendation using real numbers | Recommendation written |

## 3. Procedure

1. **Orient:** read `AGENTS.md`, `factory-state/checkpoint.md`, the active spec, the last handoff. Check `git log` for what changed since.
2. **Choose one task** from the spec's v1 list (or the ship checklist). If the task isn't on the v1 list, stop and log it on the v1.1 list.
3. **Plan in a few lines** inside the session, not a document. Note assumptions.
4. **Do the task in small commits.** Prefer deterministic logic modules with tests; keep UI thin.
5. **Verify**: run tests; for networked games, attack your own remotes with late, duplicate and malformed input.
6. **Update `factory-state/checkpoint.md`** and write the handoff.
7. **Stop** when a stop condition hits.

## 4. Stop conditions

Stop and hand off when any of these is true:
- The chosen task is done and verified.
- You need an owner action (account step, payment, art files, playtest, publishing to live).
- Platform facts in the docs look stale or contradictory and the task depends on them.
- You've hit the same failure twice without new information (write down what you tried).
- Scope would grow beyond the frozen v1 list.

## 5. Owner-only gates (prepare, don't perform)

- Age check / ID verification / 2FA on the Roblox account.
- Choosing Roblox Plus vs the refundable publishing fee; paying any fee.
- The first publish in Studio (creates the Universe and Place IDs).
- The content maturity questionnaire answers (must be truthful and are the owner's responsibility).
- Generating and approving art.
- Daily playtest and the "is it fun?" call.
- Making a version live; moving a game from Saved to Published.

## 6. Handoff note (paste into `factory-state/checkpoint.md` and the game's `completion-report.md`)

```text
Date / agent / environment (cloud or desktop):
Game and state:
Task done:
Changed (files / systems):
Verified how (tests, attacks, emulator):
Not verified (needs owner playtest / device / live):
Blocked on (owner action):
New ideas parked on v1.1:
Surprises / platform facts learned (and where recorded):
Next task for the next session:
```

## 7. Daily playtest loop (owner)

Owner plays the latest Saved build daily. Notes go in `games/game-NNN/playtest.md`: what felt bad, what confused, what was fun. The next Build session works from that list, filtered through the frozen v1 scope.

## 8. Anti-patterns

- Growing v1 because a new idea seemed better.
- Building a shared framework before three games have needed the same code.
- Declaring "done" without saying what wasn't verified.
- Treating a headless pass as proof the game is fun or readable on a phone.
- Re-researching settled platform rules every session; instead, update the rules file when you find a change.
