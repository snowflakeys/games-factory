--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Rules = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rules"))
local Layout = require(ReplicatedStorage.Shared.Layout)
local View = require(script.Parent.View)
local remote = ReplicatedStorage:WaitForChild("RuleStack")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
-- This UI-only game does not wait for an avatar before showing its interface.
game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()
local state, selected, hover, drag = nil, nil, nil, nil
local pending, armed = true, false
local requestNumber = 0
local view
local function render()
    view.dragging(drag ~= nil)
    view.render(state, selected, pending, armed, hover)
end
local function unlocked()
    return state and state.status == "playing" and not pending
end
local send
send = function(intent)
    pending = true
    requestNumber += 1
    local number = requestNumber
    render()
    remote:FireServer(intent)
    task.delay(3, function()
        if pending and requestNumber == number then
            -- Never repeat an unacknowledged placement: read back authoritative state.
            view.message("Recovering connection to your board...")
            send({ action = "sync" })
        end
    end)
end
local function place(cell)
    if unlocked() then
        drag = nil
        send({ action = "place", runId = state.runId, turn = state.turn, cell = cell })
    end
end
view = View.mount(playerGui, Layout, Rules, {
    select = function(cell)
        if unlocked() and armed then
            selected = cell
            render()
        end
    end,
    hover = function(cell)
        if unlocked() and armed then
            hover = cell
            render()
        end
    end,
    arm = function()
        if unlocked() then
            armed = true
            render()
        end
    end,
    action = function()
        if not state or pending then
            return
        end
        if state.status ~= "playing" then
            send({ action = "restart", runId = state.runId, turn = state.turn })
        elseif selected then
            place(selected)
        end
    end,
    dragStart = function(input)
        if
            unlocked()
            and (
                input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1
            )
        then
            armed = true
            drag = { input = input, start = input.Position, moved = false }
            render()
        end
    end,
})
UserInputService.InputChanged:Connect(function(input)
    if not drag or not unlocked() then
        return
    end
    if
        input == drag.input
        or (
            drag.input.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        )
    then
        if (input.Position - drag.start).Magnitude >= 8 then
            drag.moved = true
        end
        if drag.moved then
            hover = view.cellAt(input.Position)
            selected = hover
            render()
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if
        not drag
        or (
            input ~= drag.input
            and not (
                drag.input.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1
            )
        )
    then
        return
    end
    local moved = drag.moved
    drag = nil
    if moved and unlocked() then
        local cell = view.cellAt(input.Position)
        if cell and input.UserInputState ~= Enum.UserInputState.Cancel then
            place(cell)
        else
            selected, hover = nil, nil
            render()
            view.message("Drag cancelled. No break used.")
        end
    end
end)
UserInputService.WindowFocusReleased:Connect(function()
    drag, selected, hover = nil, nil, nil
    render()
end)
remote.OnClientEvent:Connect(function(response)
    local incoming = response.state
    if state and incoming.runId == state.runId and incoming.revision < state.revision then
        return
    end
    state = incoming
    pending, selected, hover, drag = false, nil, nil, nil
    render()
    if state.status == "playing" then
        if response.code == "illegal" then
            view.message("Break " .. state.strikes .. "/2: " .. response.errors[1])
        elseif response.code == "accepted" and state.placed % 4 == 0 then
            view.message("New rule: " .. Rules.text[state.active[#state.active]])
        elseif response.code == "stale" then
            view.message("Board refreshed. Choose your next cell.")
        end
    end
end)
send({ action = "sync" })
