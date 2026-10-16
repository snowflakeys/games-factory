--!strict
-- Dimensions are logical GUI pixels inside the safe-area rectangle.
local Layout = {}
function Layout.measure(width, height)
    local landscape = width >= 480 and width > height
    local boardSize = math.min(
        360,
        width - (if landscape then 280 else 24),
        height - (if landscape then 92 else 258)
    )
    boardSize = math.max(210, boardSize)
    local cell = math.floor((boardSize - 18) / 4)
    boardSize = cell * 4 + 18
    local contentWidth = if landscape then boardSize + 256 else boardSize
    return {
        landscape = landscape,
        boardSize = boardSize,
        cell = cell,
        contentWidth = contentWidth,
        contentHeight = if landscape then math.max(boardSize + 64, 300) else boardSize + 246,
    }
end
return table.freeze(Layout)
