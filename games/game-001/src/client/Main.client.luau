--!strict

-- Enable this script's ShowHudExample attribute in a local Studio test only.
-- This reference never implements a queued game's unapproved core loop.
if script:GetAttribute("ShowHudExample") == true then
    local Players = game:GetService("Players")
    local MobileHud = require(script.Parent.MobileHud)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    MobileHud.mount(playerGui, function()
        print("HUD example action activated. No score, reward, or remote was sent.")
    end)
end
