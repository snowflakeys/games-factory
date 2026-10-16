> UNVERIFIED imported research/reference, received 2026-10-16. Source: Snow’s `game-factory-docs.zip`; no source game or local playtest evidence yet. Claims of verification below describe the supplied document, not an independent check in this import. Re-verify platform requirements before relying on them. Root `AGENTS.md` controls factory policy.

# Roblox Platform Rules (publishing, audience, monetization, tooling)

**Retrieved:** 2026-10-16 from official Roblox Creator Hub docs and DevForum announcements (sources at the bottom).
**Re-verify before every launch.** Roblox changed publishing rules three times in the last year (Dec 2025, May 2026, ongoing tweaks). If this file and the live Creator Hub disagree, the Creator Hub wins; fix this file.

Roblox now calls experiences "games" in its docs. Same thing.

## 1. Who can see a new game

New games are gated by account tier and audience. The tiers:

| Audience | Account tier | Content ratings allowed |
|---|---|---|
| Roblox Kids (5-8) | Self-declared or age-checked 5-8 | Minimal, Mild |
| Roblox Select (9-15) | Self-declared 9+ until age-checked, or age-checked 9-15 | Minimal, Mild, Moderate |
| Roblox (16+ and Trusted Friends) | Age-checked 16+ | Everything except Restricted (18+) |

**Default for a new game:** reaches only age-checked 16+ users (plus Trusted Friends). Reaching under-16 players needs extra steps (section 2). This matters for any game aimed at a younger audience: launch reach starts at 16+ only.

## 2. Publish requirements

**To release to 16+ and Trusted Friends:**
- Account in good standing and at least 2 days old.
- Age check done (facial age estimation or government ID).
- Answer the first questionnaire question (does the game contain age-restricted content?). Answering No gives a **Content May Vary** label and 16+ only release.

**To release to all ages (Kids and Select) you additionally need:**
- Verified account: facial age estimation if under 18, government ID if 18+.
- 2-step verification on the account.
- Either an active Roblox Plus or Premium subscription held for 2 consecutive months, **or** a one-time refundable fee of **1,000 Robux per game**.
- The **full** Maturity & Compliance questionnaire, resulting in Minimal, Mild or Moderate.
- Passing the **evaluation process**: trial phase visible only to age-checked 16+ users; engagement is checked for real, highly engaged players (account age, play history, spend on Roblox); safety review; then a threshold of **250 unique plays from highly engaged age-checked users within 60 days**. Progress shows in Creator Hub under Audience > Reach.
- Optional **expedited review**: refundable 50,000 Robux per game, for timed launches; about 48 hours; same standards.

Fee refund: the 1,000 Robux fee is refunded if the game keeps 25 highly engaged players for 60 days without moderation (or 90 days after eligibility / payment, per the Kids and Select page). Fees are not refunded if the game is permanently removed for Community Standards violations.

"Highly engaged" players must have spent at least a minimum on Roblox in the last 60 days and played your game in that window. They don't need to spend in your game.

**Requirements apply to every release action:** first release, updating a released game, Publish As to another game, and changing audience settings. Open Cloud API publishing was confirmed subject to eligibility checks in the Dec 2025 announcement; assume that still holds.

**Older posts are stale.** The Dec 2025 rule (ID verification or a real-money purchase) was replaced by the age-check rules above. Trust the current publish doc.

## 3. Release mechanics and limits

- You can release **up to 5 never-before-released games per day**.
- Max place size 100 MB.
- New games are private to you, people with Edit access, and invited early testers. You can invite up to 10 friends of a similar age (age bands apply; Trusted Friends can cross bands, with parent approval for under 9).
- Target audience (Playtest / Public / Friends-only) is set in Creator Hub > Publish settings > Manage Audience. You can exclude a game from Recommended For You.
- A public game with no usable maturity label is unplayable. Roblox periodically adds questionnaire questions; labels have been removed in bulk before, so re-check labels after Roblox announcements.
- The first publish creates the **UniverseID** and **PlaceID**; both are needed later for Open Cloud publishing.

## 4. Game page assets

| Asset | Spec | Notes |
|---|---|---|
| Name | Keep stable; no keyword spam | Renaming often hurts discovery; spam can demote the game |
| Description | First sentence states genre and core loop; relevant keywords; no spam | |
| Genre / subgenre | Required dropdowns | |
| Icon | Square, 512x512 recommended | Shown down to about 150x150; check it at that size |
| Thumbnail | 1920x1080 (16:9) | Non-16:9 uploads get stretched; player-count UI can cover parts of it; must represent the real game |

Icon and thumbnail specs come from third-party summaries consistent with Roblox's docs. Confirm in the Creator Hub upload dialog.

## 5. Monetization

**Passes**
- Create in Creator Hub: Monetization > Passes. The game must be published first.
- Check ownership with `MarketplaceService:UserOwnsGamePassAsync(userId, passId)`; prompt with `PromptGamePassPurchase`. **You** deliver the benefit; Roblox only handles the transaction.
- Cross-experience pass sales were disabled on 2026-05-30. A pass sells only inside its own game.

**Developer products** (consumables) grant via `ProcessReceipt`. Rewarded ads use them (below).

**Rewarded video ads**
- Game: public and unrestricted, no free-form user creation, full questionnaire reviewed and approved, **average at least 2,000 unique visitors per month**.
- Publisher: 13+, account in good standing, 2FA on, **ID verified**.
- Implementation: the player must press a button first; clear disclosure of the reward; reward issued right after the ad; **not used as a progress gate**; no randomized rewards; no Robux rewards; must not harm the character during the ad (pause damage or show in a safe zone).
- The reward must be a **developer product that could normally be bought with Robux in the game's shop**, and must not inflate currency or unbalance the economy. Roblox suggests rewards worth roughly 3-10 Robux: boosters, in-game currency, extra lives, temporary privileges.
- Code path: client checks `AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)` only when about to offer the ad; server calls `AdService:CreateAdRewardFromDevProductId` then `ShowRewardedVideoAdAsync`; grant in `ProcessReceipt`.
- Ads only reach users 13+. Resubmitting the questionnaire temporarily removes ads eligibility while under review.
- Practical consequence: **ads cannot be live at launch**. Traffic first, then ads.

## 6. Agent and build tooling

**Studio MCP server (official, built into Studio)**
- Enable in Studio: Assistant > ... > Manage MCP Servers > Enable Studio as MCP server. Quick connect supports Claude Code, Claude Desktop, Codex CLI, Cursor, Gemini CLI, VS Code, Antigravity.
- Tools include: script read/edit/search, game-tree inspection, `execute_luau`, start/stop playtest, console output, screenshots, simulated keyboard/mouse/character movement, asset search/insert/upload, mesh/material/model generation, and an explore/playtest subagent. Every call targets a `studio_id`.
- **Needs desktop Studio running on a computer.** A cloud-only agent session cannot use it. Clients can read and modify open places; connect only trusted ones.

**Script Sync (Studio beta)** syncs scripts only (Script, LocalScript, ModuleScript, Folder) between Studio and disk. Good for editing in an IDE while Studio stays the source of truth. Don't sync scripts that have attributes or tags. Roblox says to use a tool like **Rojo** if you want the whole project in version control with the file system as source of truth.

**Rojo** latest release seen: 7.7.1 (7.7.0 added `rojo syncback` and switched `rojo serve` to websockets). Install via Rokit (`rojo = "rojo-rbx/rojo@7.7.1"` in `rokit.toml`) or releases.

**Open Cloud Place Publishing API:** `POST https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType=Saved|Published` with the `.rbxl`/`.rbxlx` as the body and `x-api-key` header. `Saved` stores the version without making it live; `Published` goes live. Needs an API key with write permission for that place; limit 30 requests per 60 seconds per key per IP. The API doesn't update certain instance types (check the usage guide).

**Open Cloud Luau Execution API:** runs a Luau script headlessly on Roblox's servers against a place version. Physics does not run and server/client scripts do not auto-run, so it tests logic modules, not live gameplay. Limits: 5 task-creation calls per minute per key owner, at most 10 incomplete tasks per place, results kept 24 hours. Key scope: `universe.place.luau-execution-session:write`. Use a dedicated test place, never the live place.

## 7. Mobile UI (official guidance)

- `ScreenGui.ScreenInsets` defaults to `CoreUISafeInsets` (clear of notches and Roblox's top bar); Roblox recommends it for any ScreenGui with interactive or important UI. `DeviceSafeInsets` lets backgrounds and non-critical UI reach the physical edge.
- Test with Studio's Device Emulator.
- No official minimum touch-target size was found. The factory uses a conservative internal rule (see `agent-instructions/ship-checklist.md`); treat it as house policy, not a Roblox rule.

## 8. Saving data (community consensus, not an official rule)

- Wrap every DataStore call in `pcall` with retry + exponential backoff; never overwrite saved data after a failed load.
- Use session locking so two servers can't write the same player (ProfileService / ProfileStore-style libraries are the common choice; check which is currently maintained before adopting).
- Handle `PlayerRemoving` and `game:BindToClose` (about 30 seconds of grace); both can fire for the same player, so save once.
- Reconcile new default fields into existing players' data.
- Official docs to read: data stores best practices, error codes and limits, and Data Stores Manager (Creator Hub) for inspecting and reverting keys.

## 9. Known unknowns

- Forum posts around May 2026 mention Playtest-permission sharing counting as "public" for requirements; the current publish doc separates early testers from public release. Confirm in Studio before inviting testers.
- Evaluation thresholds have moved (forum posts mention 100, then 25, for retaining Kids/Select eligibility; the Kids and Select page says 250 plays to complete evaluation). Read the Audience Reach dashboard for the live number.
- Whether passes or ads require ID verification beyond the stated ad rule: unconfirmed for passes.
- Third-party Studio MCP plugins exist; the factory uses the official one.

## Sources

- Create and publish games and places: https://create.roblox.com/docs/production/publishing/publish-games-and-places
- Roblox Kids and Select: https://create.roblox.com/docs/production/publishing/kids-and-select
- Content Maturity FAQ: https://en.help.roblox.com/hc/en-us/articles/8863284850196-Content-Maturity-FAQ
- Publishing requirements announcement and follow-ups: https://devforum.roblox.com/t/new-publishing-requirements-evaluation-process-for-games/4573166 and https://devforum.roblox.com/t/alternate-publishing-requirements-for-roblox-kids-and-select/4630944
- Dec 2025 publish requirements: https://devforum.roblox.com/t/new-requirements-to-publish-and-update-public-experiences/4143953
- Rewarded video ads: https://create.roblox.com/docs/production/promotion/rewarded-video-ads and https://devforum.roblox.com/t/rewarded-video-ads-are-now-available-to-all-ads-eligible-creators/4063278
- Passes: https://create.roblox.com/docs/production/monetization/passes
- Studio MCP: https://create.roblox.com/docs/studio/mcp
- Script Sync: https://create.roblox.com/docs/en-us/scripting/sync
- Place Publishing API: https://create.roblox.com/docs/cloud/open-cloud/usage-place-publishing
- Luau Execution: https://create.roblox.com/docs/cloud/reference/LuauExecutionSessionTask
- Rojo releases: https://github.com/rojo-rbx/rojo/releases
- ScreenInsets: https://create.roblox.com/docs/reference/engine/enums/ScreenInsets
