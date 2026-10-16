--!strict
-- Opt-in reference only. Keep real scores and rewards on the server.
local MobileHud = {}

function MobileHud.mount(parent: Instance, onAction: () -> ()): ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Name = "MobileHudExample"
    screen.ResetOnSpawn = false
    screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.AnchorPoint = Vector2.new(0.5, 0)
    status.Position = UDim2.new(0.5, 0, 0, 16)
    status.Size = UDim2.new(0.9, 0, 0, 48)
    status.BackgroundColor3 = Color3.fromRGB(24, 30, 48)
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.Font = Enum.Font.GothamMedium
    status.TextSize = 18
    status.TextWrapped = true
    status.Text = "HUD reference | no gameplay"
    status.Parent = screen

    local statusLimit = Instance.new("UISizeConstraint")
    statusLimit.MaxSize = Vector2.new(320, 48)
    statusLimit.Parent = status

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 12)
    statusCorner.Parent = status

    local action = Instance.new("TextButton")
    action.Name = "PrimaryAction"
    action.AnchorPoint = Vector2.new(0.5, 1)
    -- Centered so the default thumbstick and jump corners stay clear.
    action.Position = UDim2.new(0.5, 0, 1, -24)
    action.Size = UDim2.new(0.55, 0, 0, 64)
    action.BackgroundColor3 = Color3.fromRGB(109, 72, 202)
    action.TextColor3 = Color3.fromRGB(255, 255, 255)
    action.Font = Enum.Font.GothamBold
    action.TextSize = 22
    action.Text = "TRY ACTION"
    action.Selectable = true
    action.AutoButtonColor = true
    action.Parent = screen

    local actionLimit = Instance.new("UISizeConstraint")
    actionLimit.MinSize = Vector2.new(144, 64)
    actionLimit.MaxSize = Vector2.new(240, 64)
    actionLimit.Parent = action

    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 16)
    actionCorner.Parent = action

    -- Activated supports touch, mouse, and selected gamepad activation.
    action.Activated:Connect(onAction)
    screen.Parent = parent
    return screen
end

return MobileHud
