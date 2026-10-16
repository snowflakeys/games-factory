# Don't Match Me client

Main.client.luau is a thin Roblox service/input transport. The pure shared Controller creates one in-flight request at a time and correlates private acknowledgements. View.luau builds and renders native UI from individualized server snapshots. All scores, choices, bot decisions, phases, deadlines and winners remain authoritative on the server.

Tap exactly one symbol to lock; the public clock reaches the server deadline before choices reveal. The count of locked picks reveals no player identities. Bots are labeled BOT. During results PLAY AGAIN marks ready; everyone ready can shorten replay to one second, otherwise the automatic result timer starts the next match. There is no elimination, map, avatar, saved progression or monetization.

A transport packet is `{requestId = integer, intent = {action = ...}}`. Choice intents contain matchId, roundId and choiceId; readiness contains matchId/roundId; sync contains only action. Request IDs are bounded correlation metadata, never authority for game results. The server validates membership from the actual Player. Three-second acknowledgement recovery sends read-only sync with a new ID; it never repeats the choice. State broadcasts do not impersonate a private acknowledgement, and obsolete acknowledgements do not unlock a newer request.

UI uses CoreUISafeInsets and ResetOnSpawn=false, paired glyph/text/color symbols, >=64px choice targets and a 48px PLAY AGAIN action. Portrait and landscape layouts keep own score/rank and core controls visible at supported safe rectangles; standings scroll separately, and short overall viewports can scroll. Display names truncate to avoid score overlap, while bots, winners and inactive/departed participants are labeled.

The countdown uses the same Workspace:GetServerTimeNow adapter as the server, but has no authority over deadline enforcement. Actual clock synchronization, renderer/fonts, touch targets and controls still require Studio and phone testing. See ../../playtest.md.
