# Rule Stack backlog

No known core-loop blockers after automated verification. The following are unverified acceptance items, not fabricated bug findings.

| ID | Priority | Work / reproduction | Status |
| --- | --- | --- | --- |
| QA-001 | Before PLAYTESTED | Studio small phone portrait and landscape, notches, tablet, desktop: inspect safe insets, labels, scrolling and all >=48px board/primary touch targets. Test smallest safe-area rectangles around 320x480 portrait and 568x300 landscape. Smaller heights can scroll; do not infer full visibility from geometry tests. | NOT RUN |
| QA-002 | Before PLAYTESTED | Tap-token/tap-cell/PLACE, occupied/illegal cells, valid and cancelled drags, outside drops, focus loss, multi-touch, rapid taps, latency recovery and respawn. | NOT RUN |
| QA-003 | Before PLAYTESTED | Studio multi-client isolation, disconnect/reconnect, actual remotes, memory/performance and manual adversarial traffic. Pure session tests cover 20 independent players; engine networking is unverified. | NOT RUN |
| QA-004 | Before PLAYTESTED | First action within about 20 seconds without verbal help; ten consecutive runs remain enjoyable without progression rewards. | Snow judgment pending |
| ART-001 | Before release | Snow reviews/generates icon and thumbnail from assets-needed.md; no final external art exists. | Pending owner art |

Frozen v1.1 backlog from approved spec: daily shared seed, timed Sprint, multiplayer race, bots, rankings, persistence, achievements, cosmetics, extra predicates, monetization, sounds and custom art polish. First-session analytics can be considered during release planning. No additions implemented during v1.
