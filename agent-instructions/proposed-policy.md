> Imported reference/proposal from Snow’s 2026-10-16 document pack. Root `AGENTS.md` remains canonical; existing approval gates, full-core-loop completion, CI requirements, and state schema take precedence over conflicting examples here. No policy replacement is approved by this import.

# AGENTS.md: Roblox Game Factory

This repo is the headquarters for every Roblox game the owner makes. Any coding agent (Claude, Codex, or whatever is added later) can be the worker. **The repo is the source of truth, not anyone's chat history.**

## Start every session like this

1. Read this file.
2. Read `factory-state/planning-reference.md`: which game is active, its state, and the last handoff note.
3. Read `agent-instructions/session-protocol.md` once per session (it defines what you may do in this environment).
4. Open the active game's spec in `games/game-NNN/spec.md`.
5. Pick **one** task. Do it. Update status. Stop (see the protocol's stop conditions).

## Repo map (adjust if the real layout differs)

```text
AGENTS.md
agent-instructions/  session protocol, ship checklist, pipeline, proposed policy
factory-state/       registry, queue, checkpoint, unconfirmed planning reference
knowledge-base/      platform reference and microgames research/specs
games/game-NNN/      one Rojo project per game, spec.md, src/, tests/, assets/
scripts/             publish-place.sh and existing factory tools
```

## Rules (all agents, always)

1. **Freeze v1 scope before building.** Write the v1 list in the game's spec. Anything new goes on the **v1.1 list**, never into v1. Don't add features mid-build, even if the owner asks mid-session: log it on the v1.1 list and finish v1 first.
2. **Build the smallest thing that can be playtested**, then hand off. A playable build beats a complete system.
3. **Server is the authority.** Clients send intents, the server validates and commits. Never trust client values, never send hidden state to clients.
4. **Mobile first.** Most players are on phones. Respect safe areas, test on the device emulator, keep touch targets generous.
5. **Never draw game art in code** (icons, effects, backgrounds, character art). Write image prompts to `games/game-NNN/assets-needed.md` and list the files you need; the owner generates them and drops files in `games/game-NNN/assets/incoming/`. Placeholder shapes are fine until then.
6. **Never answer the content maturity questionnaire, accept payments, verify accounts, or press the final Release button.** Those are owner actions. Prepare everything and write the exact steps.
7. **Never commit secrets** (API keys, cookies, IDs tied to credentials). Read them from environment variables.
8. **Don't invent platform facts.** Check `knowledge-base/roblox-platform-rules.md`; if it is more than a few weeks old or the task is a launch, re-verify against official Roblox docs and update the file.
9. **Record decisions and surprises**, not just code. Add reusable lessons to `knowledge-base/` (important ones only; short).
10. **Design for age-checked 16+ players first, with kid-safe content.** Reaching under-16 audiences requires hooking engaged 16+ players first, so no kiddie-coded themes, humor or art. Also no gore, scares or mature themes that would push the rating above Moderate. Target: clean, skill-based, competitive or mastery-driven, all-ages-safe.
11. **If a game isn't fun or isn't attracting players after release, stop investing.** Move to the next game. Don't bolt grind onto a weak loop.

## What counts as a finished session

- Code or docs changed are committed with a clear message.
- `factory-state/planning-reference.md` updated: state, what changed, what is blocked, what the owner must do next.
- A handoff note exists in the format in `session-protocol.md`.
- Nothing half-built is left in the main branch.
