--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local shared = ReplicatedStorage:WaitForChild("Shared")
local Rules = require(shared:WaitForChild("Rules"))
local Layout = require(shared:WaitForChild("Layout"))
local Controller = require(shared:WaitForChild("Controller"))
local View = require(script.Parent:WaitForChild("View"))
local remote = ReplicatedStorage:WaitForChild("DontMatchMe")
local controller = Controller.new()
local function now()
    return workspace:GetServerTimeNow()
end
local function send(packet)
    if packet then
        remote:FireServer(packet)
    end
end
local view = View.mount(Players.LocalPlayer:WaitForChild("PlayerGui"), Rules, Layout, {
    choose = function(id)
        send(controller:request("choose", id, now()))
    end,
    ready = function()
        send(controller:request("ready", nil, now()))
    end,
})
remote.OnClientEvent:Connect(function(response)
    controller:receive(response, now())
end)
local elapsed = 0
RunService.Heartbeat:Connect(function(delta)
    elapsed += delta
    if elapsed < 0.1 then
        return
    end
    elapsed = 0
    local time = now()
    send(controller:poll(time))
    view.render(
        controller.state,
        controller.pending ~= nil,
        time,
        if time < controller.noticeUntil then controller.notice else ""
    )
end)
game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()
send(controller:sync(now()))
