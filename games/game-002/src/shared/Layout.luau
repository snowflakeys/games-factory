--!strict
local Layout = {}
function Layout.measure(width, height, symbolCount)
    local landscape = width >= 500 and width > height
    local left = math.min(360, width - (if landscape then 252 else 24))
    local columns = if symbolCount > 4 then 3 else 2
    return {
        landscape = landscape,
        left = left,
        columns = columns,
        cellWidth = math.floor((left - (columns - 1) * 8) / columns),
        cellHeight = 72,
        gridY = if landscape then 108 else 142,
        width = if landscape then left + 248 else left,
        height = math.max(if landscape then 276 else 480, height),
    }
end
return table.freeze(Layout)
