--!strict
local View = {}
local palette = {
    red = Color3.fromRGB(181, 48, 69),
    blue = Color3.fromRGB(43, 94, 188),
    yellow = Color3.fromRGB(244, 204, 87),
    green = Color3.fromRGB(31, 125, 94),
}
local abbreviations = { circle = "CIR", star = "STAR", triangle = "TRI" }
local ink = Color3.fromRGB(237, 241, 255)
local panel = Color3.fromRGB(36, 43, 65)

local function create(className, parent, name)
    local object = Instance.new(className)
    object.Name = name
    object.BorderSizePixel = 0
    object.Parent = parent
    return object
end
local function label(parent, name, text, size)
    local object = create("TextLabel", parent, name)
    object.BackgroundTransparency = 1
    object.Text = text
    object.TextColor3 = ink
    object.Font = Enum.Font.GothamMedium
    object.TextSize = size
    object.TextWrapped = true
    object.TextXAlignment = Enum.TextXAlignment.Left
    return object
end
local function button(parent, name, text)
    local object = create("TextButton", parent, name)
    object.BackgroundColor3 = panel
    object.TextColor3 = ink
    object.Font = Enum.Font.GothamBold
    object.TextSize = 15
    object.TextWrapped = true
    object.Text = text
    object.AutoButtonColor = true
    object.Selectable = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = object
    return object
end
local function rect(object, x, y, width, height)
    object.Position = UDim2.fromOffset(x, y)
    object.Size = UDim2.fromOffset(width, height)
end
local function tokenText(token, short)
    if short then
        return string.upper(string.sub(token.color, 1, 1))
            .. "\n"
            .. abbreviations[token.shape]
            .. " "
            .. token.number
    end
    return string.upper(token.color) .. "\n" .. string.upper(token.shape) .. " " .. token.number
end

function View.mount(playerGui, Layout, Rules, callbacks)
    local previous = playerGui:FindFirstChild("RuleStackUI")
    if previous then
        previous:Destroy()
    end
    local screen = Instance.new("ScreenGui")
    screen.Name = "RuleStackUI"
    screen.ResetOnSpawn = false
    screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.DisplayOrder = 10
    local background = create("Frame", screen, "Background")
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.fromRGB(18, 23, 40)
    local scroll = create("ScrollingFrame", background, "SafeViewport")
    scroll.Size = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.ClipsDescendants = true
    local content = create("Frame", scroll, "Puzzle")
    content.BackgroundTransparency = 1
    local title = label(content, "Title", "RULE STACK", 23)
    local stats = label(content, "Stats", "Connecting to your board...", 14)
    local preview = label(content, "Preview", "Tap the token, then a cell. Place to confirm.", 14)
    local token = button(content, "NextToken", "WAITING")
    local action = button(content, "PlaceOrRestart", "PLACE")
    action.BackgroundColor3 = Color3.fromRGB(103, 72, 201)
    local ruleScroll = create("ScrollingFrame", content, "ActiveRules")
    ruleScroll.BackgroundColor3 = panel
    ruleScroll.ScrollBarThickness = 4
    ruleScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    ruleScroll.ClipsDescendants = true
    ruleScroll.CanvasSize = UDim2.fromOffset(0, 192)
    local cards = {}
    for index = 1, 4 do
        local card = label(ruleScroll, "Rule" .. index, "", 14)
        rect(card, 8, (index - 1) * 48, 180, 48)
        cards[index] = card
    end
    local cells, lookup = {}, {}
    local strokes = {}
    for cell = 1, 16 do
        local object = button(content, "Cell" .. cell, tostring(cell))
        object.TextSize = 14
        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Thickness = 2
        stroke.Color = panel
        stroke.Parent = object
        strokes[cell] = stroke
        cells[cell], lookup[object] = object, cell
        object.Activated:Connect(function()
            callbacks.select(cell)
        end)
        object.MouseEnter:Connect(function()
            callbacks.hover(cell)
        end)
    end
    token.Activated:Connect(callbacks.arm)
    token.InputBegan:Connect(callbacks.dragStart)
    action.Activated:Connect(callbacks.action)

    local function resize()
        local width, height = scroll.AbsoluteSize.X, scroll.AbsoluteSize.Y
        if width <= 0 or height <= 0 then
            return
        end
        local layout = Layout.measure(width - 16, height - 16)
        content.Size = UDim2.fromOffset(layout.contentWidth, layout.contentHeight)
        content.Position = UDim2.fromOffset(math.max(8, (width - layout.contentWidth) / 2), 8)
        scroll.CanvasSize = UDim2.fromOffset(0, layout.contentHeight + 16)
        rect(title, 0, 0, layout.boardSize, 24)
        rect(stats, 0, 26, layout.boardSize, 22)
        for cell = 1, 16 do
            local row, column = Rules.coordinates(cell)
            rect(
                cells[cell],
                (column - 1) * (layout.cell + 6),
                56 + (row - 1) * (layout.cell + 6),
                layout.cell,
                layout.cell
            )
        end
        local ruleWidth
        if layout.landscape then
            local side = layout.boardSize + 16
            rect(token, side, 0, 240, 56)
            rect(action, side, 62, 240, 52)
            rect(preview, side, 120, 240, 64)
            ruleWidth = 240
            rect(ruleScroll, side, 190, ruleWidth, layout.contentHeight - 190)
        else
            rect(preview, 0, layout.boardSize + 62, layout.boardSize, 48)
            rect(token, 0, layout.boardSize + 116, layout.boardSize - 102, 52)
            rect(action, layout.boardSize - 96, layout.boardSize + 116, 96, 52)
            ruleWidth = layout.boardSize
            rect(ruleScroll, 0, layout.boardSize + 174, ruleWidth, 72)
        end
        for _, card in cards do
            card.Size = UDim2.fromOffset(ruleWidth - 20, 48)
        end
    end
    scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
    screen.Parent = playerGui
    resize()

    local view = {}
    function view.dragging(active)
        scroll.ScrollingEnabled = not active
    end
    -- InputObject.Position and this hit-test share GUI-inset coordinates; do not subtract a fixed top bar.
    -- https://create.roblox.com/docs/reference/engine/classes/BasePlayerGui
    function view.cellAt(position)
        for _, object in playerGui:GetGuiObjectsAtPosition(position.X, position.Y) do
            if lookup[object] then
                return lookup[object]
            end
        end
        return nil
    end
    function view.message(text)
        preview.Text = text
    end
    function view.render(state, selected, pending, armed, hovered)
        if not state then
            return
        end
        stats.Text =
            string.format("%d pts | Breaks %d/2 | %d/16", state.score, state.strikes, state.placed)
        local playing = state.status == "playing"
        action.Text = if pending then "WAIT..." elseif playing then "PLACE" else "RESTART"
        action.Active = not pending and (not playing or selected ~= nil)
        action.AutoButtonColor = action.Active
        action.BackgroundTransparency = if action.Active then 0 else 0.55
        token.Active = playing and not pending
        token.Text = if state.nextToken
            then tokenText(state.nextToken, false)
            elseif state.status == "won" then "BOARD COMPLETE!"
            else "RUN ENDED"
        token.BackgroundColor3 = if state.nextToken then palette[state.nextToken.color] else panel
        token.TextColor3 = if state.nextToken and state.nextToken.color == "yellow"
            then Color3.fromRGB(20, 25, 40)
            else ink
        for cell = 1, 16 do
            local placed = state.board[cell]
            cells[cell].BackgroundColor3 = if placed then palette[placed.color] else panel
            cells[cell].TextColor3 = if placed and placed.color == "yellow"
                then Color3.fromRGB(20, 25, 40)
                else ink
            cells[cell].Text = if placed then tokenText(placed, true) else tostring(cell)
            cells[cell].Active = playing and not pending
            strokes[cell].Color = panel
            if playing and (cell == selected or cell == hovered) then
                local legal = #Rules.violations(
                        state.board,
                        state.nextToken,
                        cell,
                        state.active
                    ) == 0
                strokes[cell].Color = if legal
                    then Color3.fromRGB(104, 241, 186)
                    else Color3.fromRGB(255, 119, 133)
            end
        end
        for index, card in cards do
            card.Text = if state.active[index]
                then tostring(index) .. ". " .. Rules.text[state.active[index]]
                else tostring(index)
                    .. ". Arrives after "
                    .. tostring((index - 1) * 4)
                    .. " placements."
            card.TextTransparency = if state.active[index] then 0 else 0.4
        end
        if not playing then
            preview.Text = (if state.status == "won" then "YOU WIN! " else "TRY AGAIN. ")
                .. state.reason
        elseif pending then
            preview.Text = "Waiting for the server..."
        elseif selected then
            local errors = Rules.violations(state.board, state.nextToken, selected, state.active)
            preview.Text = if #errors == 0
                then "Cell " .. selected .. " is legal. Tap PLACE."
                else errors[1] .. " Placing costs one break."
        elseif armed then
            preview.Text = "Choose a cell. Drag outside the board to cancel."
        else
            preview.Text = "Tap the token, then a cell. Place to confirm."
        end
    end
    return view
end
return View
