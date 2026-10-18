# Rule Stack owner playtest

Status: NOT RUN. Only Snow can record PLAYTESTED. No engine session or physical device is available in this cloud environment.

## Local owner steps (no publish required)

1. Check out the candidate revision identified in game.json/completion-report.md. Run `python scripts/check.py` locally if desired.
2. Open `work/builds/game-001.rbxlx` in Studio after the check builds it. Alternatively use the repository-pinned Rojo with `games/game-001/default.project.json` and a blank local test place. Do not use a live place.
3. Start Play. The UI is created at join without an avatar or map. Tap the token, tap a cell, read the preview, press PLACE. A legal placement earns 10. Tokens use their full color/shape names in the next-token card and compact labels in cells.
4. Complete a run or take two illegal in-board placements; verify outcome, final score and immediate RESTART. Repeat ten runs, recording whether the puzzle stays fun without rewards. Ask a new tester to make a placement unaided in about 20 seconds.
5. Run the matrix below. Save console errors, screenshots, device/safe-area dimensions, exact revision and findings here. Do not change human approval metadata until Snow provides actual evidence.

For a reproducible victory in a local test, the owner can inspect the session's generated seed/witness with the Studio server debugger (break inside Sessions:join), or temporarily inject Generator.fallback() in a local uncommitted test copy. Fallback path is cells 1 through 16. Never add a public hint/witness remote. Pure witness victories are already covered automatically.

| Scenario | Expected | Result |
| --- | --- | --- |
| Small phone portrait and notched landscape; tablet; desktop mouse | Inside CoreUISafeInsets, readable labels, no overlap; board and primary targets >=48px; all rule cards accessible by scrolling. Test safe rectangles near 320x480 and 568x300. | NOT RUN |
| Resize/rotate while selecting or dragging | Stable board, no accidental placement; preview updates to the actual target. | NOT RUN |
| Tap token, cell, PLACE; optional drag | Correct legal/illegal explanation, server-confirmed state, one placement per intent. | NOT RUN |
| Cancel touch, focus loss, outside drop, multi-touch | No unintended intent, score or strike. | NOT RUN |
| Two illegal in-board attempts, duplicate first attempt | Two distinct attempts lose; duplicate does not strike twice; no rejected-input score. | NOT RUN |
| Rules arrive after accepted 4/8/12 | Earlier board remains legal, new card explained; strikes do not advance stages. | NOT RUN |
| Dead end, victory and restart | One terminal outcome; score <=160; new run ID and empty board; old intents ineffective. | NOT RUN |
| Spam taps, delayed acknowledgement, timeout | Controls disabled in flight; timeout reads state, never resubmits placement; input recovers. | NOT RUN |
| Studio two or more clients | Independent runs; no opponent traffic/state; one player's spam cannot affect another. | NOT RUN |
| Respawn using local Studio tooling | Existing server run and score retained, ScreenGui persists/rehydrates; no duplicate UI. | NOT RUN |
| Disconnect/rejoin | Old ephemeral session gone, fresh run. | NOT RUN |
| New tester + ten runs | First placement around 20 seconds unaided; Snow judges sustained enjoyment. | NOT RUN |

Test date, revision, device, network, player count and findings: pending actual owner test.
Monetization expectation: none in approved v1. Publishing approval remains null.
