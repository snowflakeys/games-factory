# Checkpoint

- Date: 2026-10-16, Europe/Istanbul; cloud/headless environment.
- Active: game-002, Don't Match Me; stage SPEC-PENDING. Owner queue: idea-002.
- Selection evidence: Snow asked "can you move the 2nd game" in this conversation. Interpreted as second in knowledge-base/microgames/README.md's research build order. Exact request and interpretation recorded in idea-queue.json; no spec or monetization approval inferred.
- Prepared: concrete spec.md revision 1, template scaffold, decisions, backlog and preparation report. No Don't Match Me gameplay implementation.
- Proposed core: UI-only, 1–16 humans, bots to fill four seats, hidden choices with simultaneous server reveal, UNIQUE/PAIRS/MINORITY rules, eight rounds and fast rematches.
- Human gate: Snow approves the exact committed spec, including this game's proposed no-monetization v1 exception, before BUILDING. All game-002 approvals/completion remain null.
- game-001 remains DEV-COMPLETE; verified implementation e9e5f5159c205c94fca721b0ab3e712f6f6f8005 and approved spec unchanged. Awaiting playtest: 1/2. No game-001 engine/device/fun approval exists.
- Next after approval: implement full v1 with pure Luau/Lune tests and thin Roblox adapters, run python scripts/check.py, write report, DEV-COMPLETE only after passing required checks. Do not start a third game while two await playtest.
- No credentials, Roblox upload, publish helper, remote execution, account or payment actions performed. GitHub code handoff uses connected app; shell sign-in is unavailable. No main-branch merge or release implied.
- Verification: python scripts/check.py PASS; 32 Python tests, formatter, 0 lint errors/warnings, unchanged 95,507 Rule Stack assertions, template/game-002 scaffold 51 each, 3 local Rojo builds. Game-002 gameplay and engine/device checks are NOT RUN; scaffold checks do not establish a playable game. Hosted CI not observed.
- Handoff branch: spec/game-002-dont-match-me, based on completed game-001 at 0e3df41f2ca43cfe624a9d12491a3f6bcde2362a. Await exact spec approval.
