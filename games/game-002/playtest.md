# Don't Match Me owner playtest

Status: NOT RUN. PLAYTESTED requires actual evidence from Snow. No Studio/device session is available in this cloud environment.

## Open locally

1. Open the generated `work/builds/game-002.rbxlx` in Studio (File > Open from File), or use pinned Rojo with this game's project in a blank local test place. Do not use a live place.
2. Press Play. Within one second, one human should get three labeled bots. Tap a symbol to lock it; see the lock count, wait six seconds, then see all choices and points. Repeated clicks cannot change the first accepted pick.
3. Finish eight rounds, review winner(s), and press PLAY AGAIN. Bots may win, ties share the win. No purchases, XP, ads or saved progression.
4. Run the matrix below. Record revision, device/safe dimensions, network/player count, console errors, screenshots and observations. Never infer a successful manual check from the pure tests.

| Scenario | Expected behavior | Evidence |
| --- | --- | --- |
| Small phone portrait, notched landscape, tablet and desktop | Safe insets, readable full-symbol names, no essential overlaps; >=64x64 symbol targets, >=48px replay; own score/rank visible and full standings accessible. Test safe regions near 320x480 and 568x300. | NOT RUN |
| 1/2/4/8/12/16 humans | Three/two/zero bots at 1/2/4 respectively, four symbols up to eight participants and six above; every client sees same rule/deadline. | NOT RUN |
| Unique, pairs, minority | Exactly the published rule; minimum-group ties qualify, one nonempty minority group does not, missed picks never score. | NOT RUN |
| Reveal privacy | During choosing, each client sees only own pick and aggregate count; opponent/bot choices stay absent from snapshots until reveal. Check two clients and server debugger. | NOT RUN |
| Timer boundary / delayed packet | Before-deadline valid picks accept; exact/after-deadline picks reject; no client clock can change score. | NOT RUN |
| Rapid taps and network delay | One locked pick, in-flight controls disabled, no change-choice exploits; three-second sync recovers without resubmitting. | NOT RUN |
| Mid-round and reveal joins | Wait for next round with clear countdown/label; no changes to current roster or bot commitments. | NOT RUN |
| Leave before/after submission | Accepted departing choice still affects current counts; a missed pick remains missing; bot fill changes only next round. Others keep playing. | NOT RUN |
| Respawn/rejoin | Same-server current match restores score/private choice/readiness; duplicate choice still rejected. Zero-human server starts fresh on next arrival. | NOT RUN |
| Shared win / all misses / bot win | Only participants with a locked pick in a resolved round qualify; eligible zero-point ties are shared; bot winners labeled. | NOT RUN |
| Results quorum / late join / auto rematch | All ready starts after one second; new arrival keeps others ready but waits for quorum or original automatic deadline; duplicate ready never extends timer. | NOT RUN |
| First-time tester + repeated play | Unaided first meaningful choice about 20 seconds or faster, including mid-match joins; ten consecutive rounds and repeat matches remain fun without rewards. | Snow judgment pending |

No Playtest or publish approval has been recorded. Any corrections from Snow become linked knowledge rules and fixes/backlog items.
