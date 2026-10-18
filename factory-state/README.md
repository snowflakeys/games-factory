# Factory state

Read `state.json`, `idea-queue.json`, and `checkpoint.md` at session start, then check recent Git commits. State and per-game metadata are checked by `python scripts/factory.py check` and CI.

`state.json` owns the registry of game IDs, next unused number, active game, and WIP limit. `idea-queue.json` owns Snow's queue. Each idea records `id`, `name`, `idea`, `source` (Snow's actual message or note), and `game_id` (null until selected). Do not create ideas on Snow's behalf. `games/game-NNN/game.json` owns that game's stage, approvals, place IDs, and DEAD classification.

## Commands

```powershell
python scripts/factory.py status
python scripts/factory.py queue --name "Name from Snow" --idea "Snow's idea" --source "Link or dated reference to Snow's message"
python scripts/factory.py new-game --idea idea-001
python scripts/factory.py check
```

`new-game` selects the first unassigned idea in queue order, copies the round scaffold and documents into the next game directory, registers it, and sets `SPEC-PENDING`. Snow may explicitly reorder the queue. This creates a spec draft, not an approved or playable game. It refuses an empty queue, another active game, two games waiting for playtest, or a WINNER that needs the team's attention. It never overwrites an existing game directory. Staging preserves binary assets; a failed scaffold rolls back the new directory and metadata.

## Stage and approval records

`SPEC-PENDING` and `BUILDING` are preparation stages. The required completed-game flow remains:

`DEV-COMPLETE → PLAYTESTED → RELEASE-READY → LIVE → WINNER or DEAD`

To begin implementation, record Snow's spec approval and set `stage` to `BUILDING`. After checks and implementation pass, set `DEV-COMPLETE`, write the completion report, and clear `active_game`. DEV-COMPLETE games are the games waiting for playtest; two block the next start. Only Snow's completed playtest establishes `PLAYTESTED`. Record Snow's explicit publish approval before `RELEASE-READY`. Publishing remains a separate human-controlled action; no script here publishes.

Approval slots are null until Snow gives the relevant approval or completes the playtest. Use this structure, retaining a real source reference:

```json
{
    "by": "Snow",
    "at": "YYYY-MM-DD",
    "evidence": "Message link or dated note recording the exact decision"
}
```

Do not fill approval records from agent decisions or passing checks. Spec approval is required from BUILDING onward. Playtest evidence is required from PLAYTESTED onward. Publish approval is required from RELEASE-READY onward. WINNER uses the live-game requirements. DEAD requires a reason of exactly `NOT FUN` or `NOT DISCOVERED` and receives no more development.

`places.test` and `places.live` start null. Supply distinct positive place IDs before RELEASE-READY and restrict Rojo live syncing to the test place with `servePlaceIds`. Winning-game updates are developed in the separate test place and need fresh Snow approval for each live update.

Place restrictions are checked at every stage, including SPEC-PENDING and BUILDING. Local-only scaffolds may keep both IDs null and omit `servePlaceIds`. Once either place ID or `servePlaceIds` is configured, record a positive integer `places.test` and set the Rojo project's `servePlaceIds` to exactly `[places.test]`. Configure the test place before recording a live ID; a live ID can stay null until release preparation. Unrestricted, empty, live, or mixed sync targets fail validation. Passing this metadata check does not verify an open Studio session's actual connection or authorize an upload.

## Development completion evidence

`game.json` starts with `completion: null`. DEV-COMPLETE and subsequent successful stages require this record in addition to the report:

```json
{
    "at": "YYYY-MM-DD",
    "revision": "40-character Git hash of the tested code commit",
    "evidence": "Reference to the actual passing check output and completion report",
    "core_loop": "Description of the implemented loop and agent verification",
    "checks": {
        "formatter": "PASS",
        "lint": "PASS",
        "logic": "PASS",
        "build": "PASS"
    }
}
```

Commit the tested implementation first, then record its actual revision in the completion checkpoint. These checks validate recorded evidence and run automated checks; they cannot establish human approval, fun, mobile usability, or retention. Snow's playtest, outcomes, and source metrics remain human decisions. Shared lock checks validate package hashes, exact copied file bytes, module maps and dependency pins; see [shared systems](../shared-systems/README.md) for the portable hash contract.

Update checkpoint and state with each session. Commit the work after required checks pass. Git history identifies the saved checkpoint; do not try to put a commit's own hash in the same commit.
