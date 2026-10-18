VERIFIED — pure Luau logic only, 2026-10-16. Source: [game-002 approved spec](../games/game-002/spec.md), [production match/protocol](../games/game-002/src/server), [client controller](../games/game-002/src/shared/Controller.luau), [Lune suite](../games/game-002/tests/run.luau), [report](../games/game-002/completion-report.md).

# Hidden-choice games need individualized snapshots

Rule: before reveal, serialize a viewer-specific snapshot with only that viewer's accepted choice plus safe aggregate counts. Keep all other current picks, bot commitments, seed and resolver state server-side. Reveal only at the server's deadline; a client clock must not decide admission or points. Freeze round membership, retaining already-accepted departing picks until resolution so leaving cannot rewrite other players' scoring.

Evidence: game-002 checks complete scoring against an independent per-person oracle for 1,875 exhaustive configurations, and simulates 10,080 rounds across 1/2/4/8/12/16 humans plus 480 replays. Targeted tests inspect choosing snapshots for absence of private picks/seeds, verify exact reveal boundaries, preserve departed accepted choices and wait until next round to change bot fill. Bot policy inputs contain only seed, legal symbols, public modifier and copied public revealed counts; bots commit before human submissions.

# A broadcast is not an acknowledgement

Rule: lock input until the corresponding private acknowledgement or an authoritative new round makes the old intent obsolete. Use bounded transport correlation IDs; never use those IDs as score or identity authority. A timeout sends a fresh read-only sync rather than replaying an uncertain game action. Ignore obsolete acknowledgements when a newer sync/action is pending.

Evidence: production Controller/Protocol tests deliver another player's state update before the pending action acknowledgement, delay an accepted action acknowledgement until after a newer sync, and interleave stale acknowledgements with new readiness. In-flight input stays locked; recovery reads the server's existing accepted choice instead of submitting it twice. Per-player limits include invalid envelopes; public mutation cannot leak through mutable snapshot aliases.

Not verified: actual RemoteEvent delivery, Studio scheduling, real-network delay, rendering, phone input or game feel. These remain owner checks in the source game's playtest matrix. The same pure-logic modules execute in production; no general framework or unrelated engine behavior is claimed verified.
