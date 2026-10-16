# Checkpoint

- Date: 2026-10-15 (Europe/Istanbul)
- Task: upload the existing Game Factory setup to snowflakeys/games-factory.
- Active game: none.
- Snow's queue: empty.
- Waiting for playtest: 0 of 2.
- Latest outcome: existing repository scaffold imported to GitHub; local checks pass (32 Python tests, 51 Luau assertions, formatter, lint, and Rojo build).
- Hosted repository: https://github.com/snowflakeys/games-factory (main).
- CI: GitHub Actions configured for Windows and Linux; hosted result not yet observed for this import. Windows tools executed locally; Linux release archive hashes and binary architecture verified.
- Commit: repository import at branch HEAD, preserving the existing remote initial commit.
- Next action: take Snow's first queued idea, generate its spec draft, and obtain Snow's approval before implementation.
- Unknown inputs: first game idea, Snow's art preferences, test/live place IDs, monetization IDs and ad eligibility.
- Human decisions recorded: repository setup and upload to the named GitHub repository requested; no game specs or publishes approved.


## 2026-10-16 document integration
- Imported all 19 files from Snow’s corrected ZIP into the existing folder layout; adjusted explicit repository paths.
- Retained canonical root policy and machine-readable game registry/queue; conflicting policy and unconfirmed planning state are labeled references.
- No game implementation, spec approval, account action, or Roblox publish performed.
- Next: Snow selects an idea; use the research as input to the existing spec-approval workflow.

## 2026-10-16 scheduling-readiness reconciliation
- Canonical policy now defines frozen v1 scope, state ownership, pure-module/Lune testing, safe 16+ design preference, secrets policy, and owner-only uploads/releases/account actions.
- CLAUDE.md imports @AGENTS.md. Removed competing instructions from the old proposed-policy file and reconciled session/pipeline/shipping guidance.
- Publishing helper requires a manual owner acknowledgement; it was not executed against Roblox. Keep all publishing credentials out of agents and CI.
- Queue remains empty; no game spec or batch approval was invented. Owner must select ideas and approve each exact spec.
- Restricted-egress lint remains blocked until a genuine generated Roblox standard library is vendored or the environment can fetch it. No hand-written stub substitutes for Roblox API coverage.
