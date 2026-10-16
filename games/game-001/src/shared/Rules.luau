--!strict
-- Engine-free board model and preview rules. No services, randomness, or hidden solution.
local Rules = {}
Rules.ids =
    { "red_touch", "star_edge", "blue_corner", "yellow_green", "odd_left", "triangle_column" }
Rules.text = {
    red_touch = "Red cannot touch red horizontally or vertically.",
    star_edge = "Stars must be on the outer edge.",
    blue_corner = "Blue cannot occupy a corner.",
    yellow_green = "Yellow and green cannot share a row.",
    odd_left = "Odd numbers must be in the left two columns.",
    triangle_column = "Triangles cannot share a column.",
}
Rules.colors = { "red", "blue", "yellow", "green" }
Rules.shapes = { "circle", "star", "triangle" }

function Rules.coordinates(cell)
    return math.floor((cell - 1) / 4) + 1, (cell - 1) % 4 + 1
end

function Rules.emptyBoard()
    return table.create(16, false)
end

function Rules.copyToken(token)
    return { color = token.color, shape = token.shape, number = token.number }
end

function Rules.copyBoard(board)
    local copy = Rules.emptyBoard()
    for cell = 1, 16 do
        if board[cell] then
            copy[cell] = Rules.copyToken(board[cell])
        end
    end
    return copy
end

-- Exclude one cell when checking an already-placed token during whole-board validation.
function Rules.violations(board, token, cell, active, exclude)
    local errors = {}
    if type(cell) ~= "number" or cell % 1 ~= 0 or cell < 1 or cell > 16 then
        return { "Choose a cell on the board." }
    end
    if board[cell] and exclude ~= cell then
        return { "That cell is already occupied." }
    end
    local row, column = Rules.coordinates(cell)
    local edge = row == 1 or row == 4 or column == 1 or column == 4
    local corner = (row == 1 or row == 4) and (column == 1 or column == 4)
    for _, id in active do
        local broken = false
        if id == "star_edge" then
            broken = token.shape == "star" and not edge
        elseif id == "blue_corner" then
            broken = token.color == "blue" and corner
        elseif id == "odd_left" then
            broken = token.number % 2 == 1 and column > 2
        elseif id == "red_touch" or id == "yellow_green" or id == "triangle_column" then
            for other = 1, 16 do
                local neighbor = board[other]
                if neighbor and other ~= exclude then
                    local otherRow, otherColumn = Rules.coordinates(other)
                    if id == "red_touch" then
                        broken = token.color == "red"
                            and neighbor.color == "red"
                            and math.abs(row - otherRow) + math.abs(column - otherColumn) == 1
                    elseif id == "yellow_green" then
                        broken = row == otherRow
                            and (
                                (token.color == "yellow" and neighbor.color == "green")
                                or (token.color == "green" and neighbor.color == "yellow")
                            )
                    else
                        broken = token.shape == "triangle"
                            and neighbor.shape == "triangle"
                            and column == otherColumn
                    end
                    if broken then
                        break
                    end
                end
            end
        else
            error("Unknown rule: " .. tostring(id))
        end
        if broken then
            table.insert(errors, Rules.text[id])
        end
    end
    return errors
end

function Rules.validBoard(board, active)
    for cell = 1, 16 do
        local token = board[cell]
        if token and #Rules.violations(board, token, cell, active, cell) > 0 then
            return false
        end
    end
    return true
end

function Rules.available(board, token, active)
    local cells = {}
    for cell = 1, 16 do
        if #Rules.violations(board, token, cell, active) == 0 then
            table.insert(cells, cell)
        end
    end
    return cells
end

function Rules.active(order, placed)
    local result = {}
    for index = 1, math.min(4, 1 + math.floor(placed / 4)) do
        result[index] = order[index]
    end
    return result
end

return table.freeze(Rules)
