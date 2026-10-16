# Don't Match Me preparation report

Date: 2026-10-16, Europe/Istanbul. Environment: cloud/headless. Status: SPEC-PENDING, NOT DEVELOPMENT-COMPLETE.

Snow requested moving to the second game. The factory's imported build order identifies Don't Match Me as second. Recorded the exact request plus that interpretation in the owner queue, scaffolded game-002 using scripts/factory.py, and prepared spec.md revision 1 for review. Proposed scope: pure UI, 1–16 humans, bot-filled low population, secret choices, three visible scoring rules, eight rounds, authoritative scoring/reveal and fast rematches.

All game-002 approvals and completion remain null. The game-specific no-monetization exception is proposed, not approved. Root AGENTS.md requires approval of this specific spec version before gameplay implementation. Game-001 stays DEV-COMPLETE with its approval and source unchanged; 1/2 games await playtest.

Changed: owner queue/registry/checkpoint and the game-002 template scaffold, spec, decision log and backlog. Shared systems remain empty/self-contained. Existing Rule Stack source is unchanged. No custom game-002 gameplay, bot, scoring or networking implementation exists yet.

Required validation: python scripts/check.py; see final recorded outcome below. Passing scaffold tests validates factory consistency and the copied round-state reference only. No Don't Match Me game logic, Studio/device behavior, first-action time or fun is verified.

Next: Snow approves this exact spec revision including the proposed no-monetization exception, or requests scope edits. Then record actual approval evidence and build the full v1. No credentials, remote execution, Roblox uploads or publishing actions performed.

## Preparation check outcome

`python scripts/check.py` PASS: factory/approval/WIP consistency, 32 Python tests, StyLua, Selene (0 errors/warnings), unchanged Rule Stack suite (95,507 assertions, 1,000 seeds, 200 alternative paths), 51 assertions each for the template and game-002 scaffold, and all 3 local Rojo builds. Game-002's 51 assertions cover only the copied round-state scaffold, not the proposed game. Hosted CI is not claimed.

GitHub handoff branch: `spec/game-002-dont-match-me`, based on completed game-001 branch head `0e3df41f2ca43cfe624a9d12491a3f6bcde2362a`. No main-branch merge or release is implied.
