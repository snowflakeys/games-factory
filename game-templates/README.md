# Game templates

`basic-round/` is the initial Rojo scaffold for a small round-based game. It contains no approved game idea, playable loop, monetization implementation, or publishing credentials.

Create games through the factory CLI described in the root README. The CLI copies this directory to `games/game-NNN/`, replaces `{{GAME_ID}}`, `{{GAME_NAME}}`, `{{IDEA_ID}}`, and `{{DATE}}`, and registers the game in factory state. Never develop a game inside this template.

Before implementation, complete the copied `spec.md` and record Snow's explicit approval. Keep the game's copy of any shared system pinned in `shared-systems.lock.json`. Template changes affect future games only; changes to existing games require their own checks.

The scaffold's `RoundState` helper accepts only `Waiting → Intermission → Playing → Results → Waiting`. It supplies transition validation, not timers, scoring, rewards, elimination, or networking. Extend it only when the approved core loop requires it.

Run the root validation command after changing this template. A generated game supports `rojo build default.project.json --output <temporary-path>.rbxlx` and, from its own directory, `lune run tests/run.luau`.
