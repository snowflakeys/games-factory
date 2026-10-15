# Games

No games have been created yet. The queue and active-game record live in `factory-state/`.

Use `game-NNN` directories with increasing, three-digit IDs, starting at `game-001`. Keep each game's short, searchable display name in its spec and state record.

Take the next idea from Snow's queue, draft a spec, and record Snow's approval before implementing gameplay. Copy the appropriate `game-templates/` scaffold into the new game's directory when the workflow calls for it. Never treat template placeholders as completed game content.

Each game owns its Rojo project, source, assets, tests, spec, decisions, backlog, completion report, playtest record, release checklist, metrics, asset prompts, marketing plan, and shared-system pins. Follow the [definition of done](../agent-instructions/definition-of-done.md) for status changes.

Work on one game at a time. At most two DEV-COMPLETE games may await Snow's playtest; do not start more until Snow clears one. A WINNER takes priority over new ideas, and DEAD games receive no further work.

Keep approval and metric fields pending until supported by evidence. Snow approves specs, performs playtests, and approves each publish.
