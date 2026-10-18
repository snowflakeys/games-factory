# Rule Stack v1 completion report

Date: 2026-10-16 (Europe/Istanbul). Environment: cloud/headless Linux. Status: DEV-COMPLETE; no playtest or release approval implied.

Original v1 implementation revision: `e9e5f5159c205c94fca721b0ab3e712f6f6f8005`. That original handoff changed only metadata/reports; the explicit system extraction below is a later verified maintenance change.

## Approval and implemented scope

Snow approved `games/game-001/spec.md` at `4aee649`, explicitly including no monetization, XP, purchases or ads for v1. The exact message, full approved commit and spec SHA-256 are recorded in game.json. The spec file remains byte-for-byte unchanged; its historical draft status is superseded by the actual approval record.

Implemented the complete solo loop: tap token, preview cell, commit or drag, authoritative legality/score/strike response, rule additions after 4/8/12 accepted placements, 16-cell victory or two-strike/dead-end loss, immediate restart. Includes all six predicates, a deterministic 16-token generator, staged-board compatibility, complete hidden witness validation, bounded fallback, per-player sessions, stale/duplicate/schema/range/rate validation, and read-only acknowledgement recovery. Disconnect deletes the ephemeral run; respawn/sync retains the existing run. No map, avatar, saved progression, timer or reward multipliers.

The native ScreenGui uses CoreUISafeInsets, labeled colored tokens, >=48px board targets, 52px primary actions, responsive portrait/landscape placement and scrollable rule explanations. Optional mouse/touch dragging cancels outside the board and on focus loss. These behaviors are implemented; engine/device verification remains NOT RUN.

## Changed files and architecture

- `src/shared/Rules.luau`: pure board model, predicates, staged evaluation and available-cell search; `Layout.luau`: logical geometry.
- `src/server/Generator.luau`, `Run.luau`, `Sessions.luau`: engine-free seeded generation, hidden state and transitions, semantic validation and per-player limits, injected into Roblox and Lune without alternate rule implementations.
- `src/server/Main.server.luau`: service wiring, GUID/seed creation, per-player lifecycle and one validated RemoteEvent. Only public snapshots replicate; seed, future order/sequence and witness stay server-side.
- `src/client/Main.client.luau`, `View.luau`: input, previews, in-flight locks, timeout sync and native rendering. Replaced game-001 scaffold RoundState/MobileHud; the original template is unchanged.
- `tests/run.luau` and test/client READMEs, decisions, backlog, owner playtest, release checklist, assets-needed and marketing docs. Added the narrowly VERIFIED pure-logic lesson `knowledge-base/rule-stack-kernel.md` and updated its index.
- Approval, registry/checkpoint and completion metadata document the handoff. No external shared systems; existing empty lock is accurate. Other game/template source and factory checks are unchanged.

## Required checks

Command: `python scripts/check.py`, repository root. Every required local check passed. No checker was weakened or skipped. Hosted CI is not yet observed.

| Check | Outcome |
| --- | --- |
| Factory files, registry, WIP and actual approval gates | PASS |
| Python syntax, JSON and repository tests | PASS, 32 tests |
| StyLua formatting | PASS |
| Selene against committed Roblox std | PASS, 0 errors, 0 warnings, 0 parse errors |
| Template Lune suite | PASS, 51 round-state assertions |
| Rule Stack Lune suite | PASS, 95,507 assertions; 1,000 deterministic seeds/witness victories and 200 alternative player paths |
| Generator bounds / fallback | PASS; 0/1,000 normal-budget fallbacks, maximum 3/8 attempts; 3/100 one-attempt budgets exhausted into fallback; forced zero-budget fallback passed |
| Alternative-path dead ends | 111/200 lost with zero legal next-token cells; earlier placements remained compatible with every new rule |
| Local Rojo builds | PASS, template and game-001. Game artifact: `work/builds/game-001.rbxlx`, reproducible from source |
| Studio, emulator, phone, actual services/network and fun | NOT RUN; separate owner gates, not local checks |

Full command output was captured locally in `work/rule-stack-check.log`; the reproducible suite prints the assertion and generation counts above. CI already runs the same command on Linux and Windows. Completion metadata pins the checked implementation revision; the final metadata/report commit is checked again before handoff.

## Limitations, backlog and parked work

No known automated core-loop blocker. Engine execution, notches, actual hit testing, touch cancellation/dragging, respawn, latency recovery and multi-client behavior require Studio and Snow's phone. Geometry tests alone do not verify readability or touch feel. First action within about 20 seconds and ten enjoyable consecutive runs are Snow's judgments, still unverified. QA items are recorded in backlog.md and the complete matrix in playtest.md.

Final icon/thumbnail artwork is absent; assets-needed.md supplies ready-to-paste prompts. Native UI labels are development art. No external asset IDs or product IDs. Daily seeds, Sprint, multiplayer race, bots, rankings, persistence, achievements, cosmetics, extra predicates, monetization, sounds and custom-art polish remain v1.1. No invented telemetry, playtest results or platform approvals.

## Handoff

Stopped at DEV-COMPLETE after all required local checks passed. Snow's next action is local Studio playtesting with the built place and playtest.md matrix, then a real-phone test. Approvals for playtest/publish and test/live place IDs remain null. Do not begin another game in this session.

No publishing helper, Roblox upload, Luau remote execution, payments, account verification, release or credential actions were performed.

## GitHub handoff

Snow explicitly authorized pushing `build/rule-stack-v1` after being asked whether to upload the code without publishing the Roblox game. The completed game files are on that branch in `snowflakeys/games-factory`; `main` is not merged or changed by this handoff.

The original shell push was first blocked by automatic approval review, then failed because no shell GitHub sign-in was available after authorization. The connected GitHub app uploaded identical Git blobs and an identical source tree instead; no credential files or tokens were read or configured. The source tree SHA is `a89d8477234f89c8b9301b0d645ce87d4a3fef35`, exactly matching the checked local implementation. The completion revision above identifies the corresponding GitHub source commit. The final commit only updates handoff metadata/reports.

Hosted CI is not claimed until observed. The game remains DEV-COMPLETE, with null playtest/publish approvals and no Roblox uploads or releases. Original local commits remain preserved in the downloadable bundle and a local archive branch.

## Versioned system extraction, 2026-10-16

Snow requested "extract the systems". This game now loads the explicit local copies in shared-systems.lock.json. SeededRandom 1.0.0 and TokenBucket 1.0.0 are integrated without changing the approved v1 rules or spec. See [shared extraction report](../../shared-systems/extraction-report.md) and [reuse instructions](../../shared-systems/README.md).

Latest verified source revision: `310692363de43e8755131f3a0e62b5706cbe9bff`; tree `b8f28f0a992e9766022a7103976d8091685bb421` matches the checked local implementation. The final handoff commit updates only completion metadata and reports and is checked again. `python scripts/check.py` PASS: 45 Python tests; formatter/lint; 3,119 shared-package assertions; template 51; Rule Stack 95,514; Don't Match Me 444,769; all 3 local Rojo builds. Pre-extraction comparison matched 1,000 full puzzles and 6,000 bot picks; committed golden fixtures protect the original seeded traces. Pin/hash/copy/dependency validation is enforced by the factory gate and CI command. GitHub branch: `refactor/extract-shared-systems`.

Both games remain DEV-COMPLETE; approval records/spec bytes are retained and owner playtest/publish gates remain null. Studio/device/fun and hosted CI are not claimed. No Roblox upload, main merge or credentials.
