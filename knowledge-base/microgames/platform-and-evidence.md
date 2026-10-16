> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Platform Notes and Evidence

Everything here came from the source report and was **not independently verified**. Treat as leads to re-check, especially numbers and policy statements. Platform policy and tooling change; confirm against current Roblox documentation before relying on any of it.

## Roblox platform claims

| Topic | Claim from the report | Caveat |
|---|---|---|
| Scale | Q2 2026: about 123M average daily users, 29B hours engaged; top ten experiences about 20% of hours (about 30% three years earlier) | Doesn't prove UI games are underserved or favored |
| Direction | Roblox says it is broadening into 2D and "novel" experiences | A hypothesis for opportunity, not a measured supply gap |
| Discovery signals | Home recommendations measure first-play bounce, play-through, play days, playtime, qualified sessions, intentional co-play, spend days, Robux spend; new experiences can enter testing before 28 days of history | No published retention threshold guarantees discovery; no guaranteed impressions |
| Mobile | Majority of sessions are on mobile; ScreenGui gives native 2D UI; UIDragDetector gives draggable GUI behavior | Layouts still need real-device testing; Studio emulation differs |
| Analytics | Creator Hub supports onboarding/progression funnels, retention metrics, and experiments for causal A/B tests | Ship instrumentation with the first public test |
| Clips | Roblox Moments adds native short-form gameplay clip sharing | No evidence clip-friendly games get guaranteed discovery |
| Security | Server is the source of truth; validate every client-sent value; clients can inspect and alter their local DataModel | Hidden info must never replicate to clients early |
| Persistence | DataStoreService for durable cross-session data; MemoryStoreService for temporary cross-server data | Only add MemoryStore if global queues/tournaments need it |
| Testing | Teleports can't be fully tested in Studio | One reason to avoid multi-place architecture unless needed |
| Content rules | Playable gambling (including simulated) is prohibited; paid random items have extra requirements and regional limits | Re-read current maturity and policy docs |
| Text | Creators are responsible for filtering uncontrolled text shown to players | Avoid free-form text where possible |
| AI tooling | Roblox reports growing creator adoption of AI tools and faster production in a survey | Doesn't validate any specific build-time estimate here |

## Reference games: what to take, what not to infer

| Reference | Take this | Don't infer this |
|---|---|---|
| Balatro | Familiar rules + combinatorial modifiers = deep replay with little spatial content | It was quick to build (it took years) |
| Liar's Bar | Hidden info + accuse/reveal cycles power social play in a tiny space | Peak concurrency = retention; copy its violent presentation |
| Buckshot Roulette | Tension from probability, information, limited tools | Transplant the weapon / gambling framing |
| CloverPit | One workstation + systemic modifiers is a viable structure | Use the gambling aesthetic |
| Block Blast | Tiny placement rules + endless scoring + dailies support mastery | Mobile download scale transfers to Roblox |
| Is This Seat Taken? | Arranging objects under readable constraints is itself a game | Authored puzzles are as cheap as a generator |
| Infinite Craft | Discovery trees feel exploratory without a map | A huge generated database is a good first project |
| Stimulation Clicker | UI itself can be the escalating obstacle | It's polished enough as-is for Roblox mobile |
| NYT Games | Daily seeds, short rituals, personal records, AI stand-ins support repeat use | Same audience or distribution as Roblox |
| Skull / Love Letter / Can't Stop | A handful of components can out-replay dozens of authored levels | - |
| Grow a Garden | A tiny, legible economic loop can carry engagement | Make another farming sim; its retention data is unavailable |
| Sol's RNG | One-button play works | Its collection-heavy retention is cheap to replicate (it carries a big content loop) |
| The Presentation Experience | One room can produce social replay via player-controlled disruption | Retention data exists |
| Steal a Brainrot | Other players causing reversals is inherently shareable | Copy its FOMO/economy |
| r/robloxgamedev threads | First-minute drop-off, unclear objectives and mobile UI bugs recur | They are statistics (they're self-selected anecdotes) |

## Known unknowns

- Public Day-1 / Day-7 retention is unavailable for almost every reference game.
- Nothing here proves a Roblox adaptation of any concept will retain.
- Build estimates (1-3 days for a playable MVP, etc.) are engineering judgment, not vendor or platform data.
