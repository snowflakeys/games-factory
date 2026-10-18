--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Rules = require(ReplicatedStorage.Shared.Rules)
local SeededRandom = require(script.Parent.Systems.SeededRandom)
local TokenBucket = require(script.Parent.Systems.TokenBucket)
local PrivateRequests = require(ReplicatedStorage.Shared.Systems.PrivateRequests)
local PublicHistoryBot = require(script.Parent.Systems.PublicHistoryBot)(SeededRandom)
local Bot = require(script.Parent.Bot)(PublicHistoryBot)
local Match = require(script.Parent.Match)(Rules, Bot)
local Protocol = require(script.Parent.Protocol)(TokenBucket, PrivateRequests)
local random = Random.new()
local match = Match.new(function()
    return HttpService:GenerateGUID(false)
end, function()
    return random:NextInteger(1, 2147483645)
end)
local protocol = Protocol.new(match)
local remote = Instance.new("RemoteEvent")
remote.Name = "DontMatchMe"
local characterConnections = {}
local function idFor(player)
    return "u:" .. player.UserId
end
local function now()
    return workspace:GetServerTimeNow()
end
local function sendState(player)
    local state = match:snapshot(idFor(player))
    if state then
        remote:FireClient(player, { kind = "state", code = "updated", state = state })
    end
end
local function joined(player)
    if not match:join(idFor(player), player.DisplayName, now()) then
        player:Kick("This match supports 16 players. Please try another server.")
        return
    end
    protocol:join(idFor(player), now())
    if not characterConnections[player] then
        characterConnections[player] = player.CharacterAdded:Connect(function()
            sendState(player)
        end)
    end
end
-- UI is built in PlayerScripts at join; it does not need an avatar or map.
Players.CharacterAutoLoads = false
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)
    protocol:leave(idFor(player))
    match:leave(idFor(player), now())
    if characterConnections[player] then
        characterConnections[player]:Disconnect()
        characterConnections[player] = nil
    end
end)
remote.OnServerEvent:Connect(function(player, packet, ...)
    if select("#", ...) > 0 then
        packet = false
    end
    local response = protocol:handle(idFor(player), packet, now())
    if response then
        -- Acknowledgements and snapshots are always individualized. Never FireAllClients here.
        remote:FireClient(player, response)
    end
end)
for _, player in Players:GetPlayers() do
    joined(player)
end
local elapsed, sentRevision = 0, -1
RunService.Heartbeat:Connect(function(delta)
    elapsed += delta
    if elapsed < 0.1 then
        return
    end
    elapsed = 0
    match:advance(now())
    if sentRevision ~= match.revision then
        sentRevision = match.revision
        for _, player in Players:GetPlayers() do
            sendState(player)
        end
    end
end)
-- Listeners and initial membership are ready before the remote replicates.
remote.Parent = ReplicatedStorage
