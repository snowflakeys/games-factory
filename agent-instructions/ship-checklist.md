> Imported reference/proposal from Snow’s 2026-10-16 document pack. Root `AGENTS.md` remains canonical; existing approval gates, full-core-loop completion, CI requirements, and state schema take precedence over conflicting examples here. No policy replacement is approved by this import.

# Ship Checklist

Per game, in order. Platform facts and sources are in `knowledge-base/roblox-platform-rules.md` (retrieved 2026-10-16; re-verify before a launch). **[Owner]** = a human must do it. **[Agent]** = an agent can do it. **[Either]** = whoever is running.

## Decide once, up front (owner)

1. **Audience for launch.** New games reach only age-checked 16+ users until they pass evaluation. Choose:
   - **16+ first** (free, quickest): answer No to the age-restricted-content question, get *Content May Vary*, release. Evaluation toward Kids and Select still needs the full questionnaire and the steps below.
   - **All ages** (needed to reach under-16 players): verified account, 2FA, the full questionnaire, Plus/Premium held 2 consecutive months **or** 1,000 Robux refundable fee per game, then pass evaluation (250 unique plays from highly engaged age-checked users within 60 days). Expedited review costs 50,000 Robux per game (refundable).
2. **Plus vs per-game fee.** Cheaper per game with several games: Plus. The fee is refunded when the game keeps 25 highly engaged players for 60 days. Record the choice in the game release checklist.
3. **Note the effect on launch traffic and design.** The 250-play evaluation counts engaged, age-checked 16+ users, so design, art and promotion aim at 16+ first (clean, skill-based, not kiddie-coded) while keeping content safe enough for a Minimal to Moderate rating. Promotion aimed at younger viewers can't convert until the game is available to under-16 accounts.

## Phase 0: account (owner, once)

- [ ] Age check done (facial age estimation or ID).
- [ ] If all-ages: verification (facial age estimation under 18, government ID 18+) and 2-step verification.
- [ ] For ads later: 13+, 2FA, **ID verified**.
- [ ] Create an Open Cloud API key (place publishing). Keep it out of git; keep it only in the owner’s manual publishing environment as `ROBLOX_API_KEY`, never in agents or CI. Create a second key scoped to Luau Execution for the **test place**.

## Phase 1: before the first publish (agent + owner)

- [ ] [Agent] `spec.md` exists with frozen v1 list, v1.1 list, hypotheses and go/no-go.
- [ ] [Agent] Game name, one-sentence description (genre and core loop first), genre and subgenre drafted. No keyword spam; the name should stay stable.
- [ ] [Agent] Image prompts written for the icon (square, 512x512, readable at about 150x150) and thumbnail (1920x1080, shows the real game).
- [ ] [Owner] Generate and approve art; drop files in `games/game-NNN/assets/incoming/`.
- [ ] [Owner] **First publish in Studio** (File > Publish): upload icon and thumbnail, fill name/genre/description, save. This creates the Universe and Place IDs.
- [ ] [Either] Record test/live place IDs in `games/game-NNN/game.json` and Universe ID in its release checklist. Create a separate **test place** in the same game (File > Publish As > add as new place) for headless engine tests.

## Phase 2: build gates (all must pass before promoting anything)

From `knowledge-base/microgames/greenlight-checklist.md`, plus launch basics:

- [ ] **Mechanical:** ten consecutive rounds or loops stay enjoyable without rewards. [Owner]
- [ ] **First minute:** a new tester does the core action within about 20 seconds with no explanation. [Owner]
- [ ] **Mobile:** tested in Studio's Device Emulator and on a real phone; critical UI inside the safe area (`ScreenInsets` = `CoreUISafeInsets` for interactive ScreenGuis); no overlapping controls; house rule: touch targets at least 44x44 px-equivalent. [Agent for emulator, Owner for real device]
- [ ] **Server authority:** every remote validated (type, range, state, rate); no hidden state replicated; attacked with late, duplicate and malformed input. [Agent]
- [ ] **Data saving** (if the game saves): retry with backoff, session locking, no overwrite after failed load, `PlayerRemoving` and `BindToClose` handled, new fields reconciled, tested with a leave-mid-save case. [Agent + Owner]
- [ ] **Analytics:** first-session funnel events in place (joined, core interaction visible, first action, first completed loop, return). [Agent]
- [ ] **Policy scan:** no playable gambling or paid random competitive items; no free-form text unless essential; no copied IP; no misleading thumbnail. [Either]
- [ ] **Place size** under 100 MB. [Agent]

## Phase 3: monetization setup (agent builds, owner configures)

- [ ] [Owner] Create passes after the game is published (Creator Hub > Monetization > Passes). Passes sell only inside their own game.
- [ ] [Agent] Grant pass benefits on join and on purchase using `UserOwnsGamePassAsync`; the game grants the benefit, Roblox doesn't.
- [ ] [Agent] Gate any boost so it can't unbalance the economy; keep boosts time-limited or measured.
- [ ] **Rewarded ads: not at launch.** Requires 2,000 average unique monthly visitors, a public unrestricted game with an approved full questionnaire, and an ID-verified publisher. Build the ad button behind a feature flag if wanted, but ship it off. When eligible:
  - [ ] [Owner] Create a **developer product** for the reward (it must be something that could be bought with Robux; for example a 15-minute XP boost) and enable Rewarded Video in Creator Hub > Monetization > Ads > Settings.
  - [ ] [Agent] Button the player presses first; plain disclosure of what they get; reward granted right after the ad via `ProcessReceipt`; never a progress gate; no randomized or Robux rewards; check `GetAdAvailabilityNowAsync` only when opening the shop or menu; show only to eligible users.
  - [ ] [Either] Don't resubmit the questionnaire casually; it pauses ads eligibility during review.

## Phase 4: release (owner presses the button)

- [ ] [Agent] Build the release candidate locally with Rojo. [Owner] Upload a Saved version using the owner-only helper and inspect it in Studio.
- [ ] [Owner] Questionnaire: answer truthfully. Age-restricted content question first; full questionnaire if aiming for Kids and Select, ads, or regions that require it.
- [ ] [Owner] Release from Studio (File > Publish) or publish with Open Cloud (`VERSION_TYPE=Published`). Updates to a released game re-check the same eligibility requirements.
- [ ] [Owner] Remember the limit: at most 5 never-before-released games per day.
- [ ] [Either] Update `games/game-NNN/game.json` using the existing LIVE stage and real publish evidence; record audience and date in the release checklist.

## Phase 5: after release

- [ ] [Owner] Watch Audience > Reach for evaluation progress (if aiming all-ages).
- [ ] [Either] Review the funnel after 24 hours and 7 days; compare to the hypotheses in the spec.
- [ ] [Either] If a game passes the scale threshold, point all agents at it for updates (variation, not grind). If it fails the kill rule, record DEAD with NOT FUN or NOT DISCOVERED in its `game.json`.
- [ ] [Owner] If using the per-game fee: confirm the refund arrives.
- [ ] [Either] Check ads eligibility once visitors approach 2,000 per month.

## Known sharp edges

- Releasing or updating re-checks eligibility; losing eligibility (for example, disabling 2FA) blocks updates.
- If the maturity label disappears, a public game becomes unplayable until retaken; watch DevForum announcements.
- Headless tests can't see physics or live scripts; they never replace a real playtest.
