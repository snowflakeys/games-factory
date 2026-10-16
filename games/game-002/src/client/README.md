# Mobile HUD reference

`MobileHud.luau` is an opt-in placeholder UI module, not game art or gameplay. In Studio, set the `ShowHudExample` boolean attribute on the cloned `Main` LocalScript to true and start Play. It stays off by default in newly scaffolded games.

The ScreenGui uses `CoreUISafeInsets`. A top-center status panel and bottom-center 64-pixel-high action button use relative placement and width constraints. The lower corners are left clear for default Roblox controls. TextButton.Activated supports touch, mouse and selected gamepad activation. The callback prints a local demonstration message only; real scores, rewards, and state must be server-owned.

Before copying into a game, use Studio's Device Emulator with a small phone, notched landscape phone, portrait phone, and tablet. Check the status stays readable, button stays within the safe region, default movement controls do not overlap, and one touch produces one callback. Check mouse and gamepad activation, respawn, and teardown via ScreenGui:Destroy(). Validate on a real phone as well. These are required manual checks, not claims that this reference has passed them.
