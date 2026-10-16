--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Rules = require(ReplicatedStorage.Shared.Rules)
local Generator = require(script.Parent.Generator)(Rules)
local Run = require(script.Parent.Run)(Rules)
local Sessions = require(script.Parent.Sessions)(Run, Generator)
-- UI-only: no map or avatar is needed; manual respawns retain the same session.
Players.CharacterAutoLoads = false
local random = Random.new()
local sessions = Sessions.new(function()
    return HttpService:GenerateGUID(false)
end, function()
    return random:NextInteger(1, 2147483645)
end)

-- Only snapshots replicate: no seed, full sequence, scheduled rules, or witness.
local remote = Instance.new("RemoteEvent")
remote.Name = "RuleStack"
remote.OnServerEvent:Connect(function(player, intent)
    local response = sessions:handle(player.UserId, intent, os.clock())
    if response then
        remote:FireClient(player, response)
    end
end)
local function joined(player)
    sessions:join(player.UserId, os.clock())
end
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
    sessions:remove(player.UserId)
end)
for _, player in Players:GetPlayers() do
    joined(player)
end
-- Expose only after listeners and initial per-player state are ready.
remote.Parent = ReplicatedStorage
