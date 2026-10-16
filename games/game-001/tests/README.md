# Tests

From this game directory, run `lune run tests/run.luau`. The tests use built-in Luau only and exercise every legal and illegal phase pair plus repeated complete cycles. They do not require Roblox Studio or simulate a playable game.

Run the root validation command for formatting, lint, logic tests, repository rules, and the Rojo build. CI must pass before recording DEV-COMPLETE. A successful build or logic suite does not replace Snow's mobile and multiplayer playtest.

Add focused pure logic tests for the approved game's win condition and authoritative scoring when implemented. Record manual results in `../playtest.md`; do not mark checks passed before running them.
