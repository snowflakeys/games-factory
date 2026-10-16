# Rule Stack client

Main.client.luau binds Roblox input, sends semantic intents and consumes authoritative acknowledgements. View.luau constructs native UI and renders server snapshots; it never owns score, strikes or outcomes. Rules provides shared legality preview only; the server repeats every check.

Tap the next token, tap a board cell to preview, then PLACE. Dragging the token to a cell is an optional direct commit. Releasing outside, cancellation and focus loss send no placement. Primary controls remain locked until a response; a three-second timeout sends read-only sync rather than replaying the placement.

The ScreenGui uses CoreUISafeInsets and ResetOnSpawn=false. Layout computes a 4x4 board with at least 48px targets, 6px gutters, and portrait/landscape arrangements. Primary buttons are at least 52px tall. Rules scroll independently; the overall viewport can scroll on unusually short safe areas. Board labels pair color initials with shape abbreviation and number: R/B/Y/G and CIR/STAR/TRI. The next token uses full words.

No avatar or 3D map is required. No hidden sequence, seed, future predicate IDs or witness is sent to this client. See ../../playtest.md for the required Studio/device matrix. Local logic/build success is not device or engine verification.
