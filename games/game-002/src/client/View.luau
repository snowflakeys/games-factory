--!strict
local View = {}
local ink = Color3.fromRGB(39, 38, 58)
local paper = Color3.fromRGB(255, 246, 231)
local accent = Color3.fromRGB(208, 77, 58)
local teal = Color3.fromRGB(26, 117, 107)
local fills = {
    Color3.fromRGB(219, 235, 250),
    Color3.fromRGB(255, 231, 165),
    Color3.fromRGB(238, 222, 250),
    Color3.fromRGB(207, 239, 224),
    Color3.fromRGB(255, 219, 208),
    Color3.fromRGB(248, 212, 231),
}
local function create(kind, parent, name)
    local object = Instance.new(kind)
    object.Name, object.BorderSizePixel, object.Parent = name, 0, parent
    return object
end
local function rect(object, x, y, width, height)
    object.Position, object.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, height)
end
local function label(parent, name, text, size)
    local object = create("TextLabel", parent, name)
    object.BackgroundTransparency, object.TextColor3 = 1, ink
    object.Font, object.TextSize, object.Text = Enum.Font.GothamMedium, size, text
    object.TextWrapped, object.TextXAlignment = true, Enum.TextXAlignment.Left
    return object
end
local function button(parent, name, text)
    local object = create("TextButton", parent, name)
    object.BackgroundColor3, object.TextColor3 = Color3.fromRGB(255, 255, 255), ink
    object.Font, object.TextSize, object.Text = Enum.Font.GothamBold, 16, text
    object.TextWrapped, object.Selectable, object.AutoButtonColor = true, true, true
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(0, 12), object
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness, stroke.Color, stroke.Parent = 2, ink, object
    return object, stroke
end

function View.mount(playerGui, Rules, Layout, callbacks)
    local old = playerGui:FindFirstChild("DontMatchMeUI")
    if old then
        old:Destroy()
    end
    local screen = Instance.new("ScreenGui")
    screen.Name, screen.ResetOnSpawn = "DontMatchMeUI", false
    screen.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
    screen.ZIndexBehavior, screen.DisplayOrder = Enum.ZIndexBehavior.Sibling, 10
    local background = create("Frame", screen, "Paper")
    background.Size, background.BackgroundColor3 = UDim2.fromScale(1, 1), paper
    local scroll = create("ScrollingFrame", background, "SafeViewport")
    scroll.Size, scroll.BackgroundTransparency = UDim2.fromScale(1, 1), 1
    scroll.ScrollingDirection, scroll.ScrollBarThickness, scroll.ClipsDescendants =
        Enum.ScrollingDirection.Y, 4, true
    local content = create("Frame", scroll, "Party")
    content.BackgroundTransparency = 1
    local title = label(content, "Title", "DON'T MATCH ME", 23)
    title.Font = Enum.Font.GothamBold
    local phase = label(content, "RoundClock", "CONNECTING...", 15)
    local rule = label(content, "RuleExplanation", "Pick secretly. Reveal together.", 14)
    local score = label(content, "YourScore", "Your score will appear here.", 14)
    local notice = label(content, "Feedback", "Loading the match...", 14)
    local ready = button(content, "PlayAgain", "PLAY AGAIN")
    ready.BackgroundColor3, ready.TextColor3 = accent, Color3.fromRGB(255, 255, 255)
    ready.Activated:Connect(callbacks.ready)
    local standings = create("ScrollingFrame", content, "Standings")
    standings.BackgroundColor3, standings.ScrollingDirection =
        Color3.fromRGB(255, 255, 255), Enum.ScrollingDirection.Y
    standings.ScrollBarThickness, standings.ClipsDescendants = 4, true
    local buttons, names, glyphs, strokes, rows = {}, {}, {}, {}, {}
    for id, symbol in Rules.symbols do
        local object, stroke = button(content, "Symbol" .. id, "")
        object.BackgroundColor3 = fills[id]
        local glyph = label(object, "Shape", symbol.glyph, 32)
        glyph.Font, glyph.TextXAlignment = Enum.Font.ArialBold, Enum.TextXAlignment.Center
        local name = label(object, "Name", symbol.name, 13)
        name.Font, name.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
        object.Activated:Connect(function()
            callbacks.choose(id)
        end)
        buttons[id], names[id], glyphs[id], strokes[id] = object, name, glyph, stroke
    end
    local current, rowWidth, lastCount = nil, 200, 0
    local function resize()
        local width, height = scroll.AbsoluteSize.X, scroll.AbsoluteSize.Y
        if width <= 0 or height <= 0 then
            return
        end
        local number = if current then #current.symbols else 4
        local layout = Layout.measure(width - 16, height - 16, number)
        content.Size = UDim2.fromOffset(layout.width, layout.height)
        content.Position = UDim2.fromOffset(math.max(8, (width - layout.width) / 2), 8)
        scroll.CanvasSize = UDim2.fromOffset(0, layout.height + 16)
        rect(title, 0, 0, layout.left, 26)
        rect(phase, 0, 30, layout.left, 24)
        rect(rule, 0, 58, layout.left, 44)
        if layout.landscape then
            local side = layout.left + 16
            rect(score, side, 0, 232, 26)
            rect(notice, side, 32, 232, 48)
            rect(ready, side, 86, 232, 48)
            rect(standings, side, 142, 232, layout.height - 142)
            rowWidth = 232
        else
            rect(score, 0, 112, layout.left, 24)
            rect(notice, 0, 300, layout.left, 48)
            rect(ready, 0, 354, layout.left, 48)
            rect(standings, 0, 410, layout.left, layout.height - 410)
            rowWidth = layout.left
        end
        for id, object in buttons do
            local column, row = (id - 1) % layout.columns, math.floor((id - 1) / layout.columns)
            rect(
                object,
                column * (layout.cellWidth + 8),
                layout.gridY + row * 80,
                layout.cellWidth,
                72
            )
            rect(glyphs[id], 4, 2, layout.cellWidth - 8, 42)
            rect(names[id], 2, 44, layout.cellWidth - 4, 26)
        end
        for _, row in rows do
            row.frame.Size = UDim2.fromOffset(rowWidth - 8, 52)
            row.name.Size = UDim2.new(1, -70, 0, 24)
            row.score.Position = UDim2.new(1, -66, 0, 0)
            row.detail.Size = UDim2.new(1, -12, 0, 22)
        end
    end
    scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
    screen.Parent = playerGui
    resize()
    local view = {}
    function view.render(state, pending, now, message)
        current = state
        if not state then
            return
        end
        if lastCount ~= #state.symbols then
            lastCount = #state.symbols
            resize()
        end
        local seconds = math.max(0, math.ceil(state.deadline - now))
        local active = state.phase == "choosing"
        if active then
            phase.Text = string.format(
                "ROUND %d/8  ·  %s  ·  %ds",
                state.round,
                string.upper(state.modifier),
                seconds
            )
        elseif state.phase == "reveal" then
            phase.Text = "REVEAL  ·  ROUND " .. state.round .. "/8"
        elseif state.phase == "results" then
            phase.Text = "MATCH COMPLETE  ·  " .. seconds .. "s"
        else
            phase.Text = "NEXT PICK IN " .. math.max(0, math.ceil(state.nextChoiceAt - now)) .. "s"
        end
        rule.Text = Rules.text[state.modifier]
        score.Text = string.format(
            "YOU: %d pts  ·  #%d%s",
            state.you.score,
            state.you.rank,
            if state.you.joinedRound > 8
                then " · NEXT MATCH"
                elseif state.you.joinedRound > 1 then " · joined R" .. state.you.joinedRound
                else ""
        )
        ready.Text = if pending
            then "WAITING..."
            elseif state.phase == "results" then (if state.you.ready
                then "READY! "
                else "PLAY AGAIN  ") .. state.readyCount .. "/" .. state.humanCount
            else "8 ROUNDS · NO ELIMINATION"
        ready.Active = state.phase == "results" and not state.you.ready and not pending
        ready.AutoButtonColor = ready.Active
        ready.BackgroundTransparency = if ready.Active then 0 else 0.65
        for id, object in buttons do
            object.Visible = table.find(state.symbols, id) ~= nil
            object.Active = active
                and state.you.participating
                and not state.you.choiceId
                and not pending
                and seconds > 0
            object.AutoButtonColor = object.Active
            object.BackgroundTransparency = if active
                    and not object.Active
                    and not state.you.choiceId
                then 0.35
                else 0
            strokes[id].Color = if state.you.choiceId == id then teal else ink
            strokes[id].Thickness = if state.you.choiceId == id then 4 else 2
            names[id].Text = Rules.symbols[id].name
                .. (if state.counts[id] then " · " .. state.counts[id] else "")
        end
        if state.phase == "results" then
            local winners = {}
            for _, row in state.standings do
                if row.winner then
                    table.insert(winners, row.name .. (if row.bot then " (BOT)" else ""))
                end
            end
            rule.Text = if #winners == 0
                then "No qualifying picks. Try another match!"
                else (if #winners > 1 then "SHARED WIN: " else "WINNER: ") .. table.concat(
                    winners,
                    ", ",
                    1,
                    math.min(2, #winners)
                ) .. (if #winners > 2
                    then " +" .. (#winners - 2) .. " others (see scores)"
                    else "")
            notice.Text = "Final scores below. Play again or wait " .. seconds .. "s."
        elseif message and message ~= "" then
            notice.Text = message
        elseif pending then
            notice.Text = "Waiting for your private server acknowledgement..."
        elseif state.you.choiceId and active then
            notice.Text = Rules.symbols[state.you.choiceId].name
                .. " LOCKED  ·  "
                .. state.lockedCount
                .. "/"
                .. state.rosterCount
                .. " picked. Reveal in "
                .. seconds
                .. "s."
        elseif active and state.you.participating then
            notice.Text = "TAP ONE SYMBOL  ·  "
                .. state.lockedCount
                .. "/"
                .. state.rosterCount
                .. " picked. Your pick stays secret."
        elseif state.phase == "reveal" then
            notice.Text = "Choices revealed. Check everyone's points below."
        else
            notice.Text = "You join the next pick in "
                .. math.max(0, math.ceil(state.nextChoiceAt - now))
                .. "s."
        end
        standings.CanvasSize = UDim2.fromOffset(0, #state.standings * 56)
        for index, item in state.standings do
            local row = rows[index]
            if not row then
                local frame = create("Frame", standings, "Player" .. index)
                frame.BackgroundColor3 = paper
                local name = label(frame, "Name", "", 14)
                name.Font = Enum.Font.GothamBold
                name.TextWrapped, name.TextTruncate = false, Enum.TextTruncate.AtEnd
                local points = label(frame, "Score", "", 14)
                points.TextXAlignment = Enum.TextXAlignment.Right
                local detail = label(frame, "Detail", "", 12)
                rect(name, 6, 0, rowWidth - 78, 24)
                points.Position, points.Size = UDim2.new(1, -66, 0, 0), UDim2.fromOffset(60, 24)
                rect(detail, 6, 26, rowWidth - 20, 22)
                row = { frame = frame, name = name, score = points, detail = detail }
                rows[index] = row
            end
            rect(row.frame, 4, (index - 1) * 56, rowWidth - 8, 52)
            row.frame.Visible = true
            row.frame.BackgroundTransparency = if item.id == state.you.id then 0 else 0.6
            row.name.Text = item.rank .. ". " .. item.name
            row.score.Text = item.score .. " pts"
            local role = if item.bot then "BOT" else "PLAYER"
            local pick = if item.choiceId
                then Rules.symbols[item.choiceId].name .. "  +" .. item.points
                elseif state.phase == "reveal" and item.active then "NO PICK"
                elseif not item.active then "joins later / inactive"
                else "pick is hidden"
            row.detail.Text = (if item.winner then "WINNER · " else "")
                .. role
                .. " · "
                .. pick
                .. (if not item.connected then " · left" else "")
        end
        for index = #state.standings + 1, #rows do
            rows[index].frame.Visible = false
        end
    end
    return view
end
return View
