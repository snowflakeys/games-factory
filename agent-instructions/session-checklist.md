# Session checklist

## Start

1. Read root `AGENTS.md`, `factory-state/`, and recent commits (`git log -5 --oneline`). Inspect `git status` before editing; preserve unrelated work.
2. Find the active game and its last checkpoint. Read its spec, decisions, backlog, and only relevant knowledge entries.
3. Check Snow's recorded approvals and the number of games awaiting playtest. At two waiting games, do not start another. If a game is WINNER, focus development on it.
4. If no game is active, take the next idea from Snow's queue. If the queue is empty, record that missing input and ask for an idea. Do not invent a game.
5. Draft the short spec and obtain Snow's approval before implementing gameplay. Repo setup and template maintenance may proceed without a game spec.

## During work

- Complete one game's approved core loop before beginning another. Maintain mobile controls and server authority.
- Record material decisions in the game's `decisions.md`. Log minor bugs in its backlog.
- Keep unknowns explicit: no invented approvals, product IDs, analytics, or passing checks.
- Add an important lesson only when it has a source game and an evidence tag. Turn every Snow playtest correction into a rule and link it to the correction.
- Follow the [definition of done](definition-of-done.md) before assigning a status. Never publish without Snow's explicit approval for that release.

## End

1. Run the required formatter check, lint, and logic tests. Record exact results and any remaining failures.
2. Update the game report or checkpoint with what changed, remaining work, blockers, and the next concrete step.
3. Update `factory-state/` so the active game, queue, approvals, and waiting-for-playtest count reflect evidence.
4. Review the diff, stage only intended files, and commit. If a commit cannot be made, record the reason and leave an accurate checkpoint; do not claim the session was committed.

DEV-COMPLETE games await Snow's playtest. A missing approval keeps its gate pending; elapsed time never grants approval.
