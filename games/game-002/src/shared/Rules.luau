--!strict
-- Engine-free scoring and public definitions. No services, clocks or private choices.
local Rules = {}
Rules.symbols = {
    { id = 1, name = "CIRCLE", glyph = "●" },
    { id = 2, name = "STAR", glyph = "★" },
    { id = 3, name = "TRIANGLE", glyph = "▲" },
    { id = 4, name = "SQUARE", glyph = "■" },
    { id = 5, name = "DIAMOND", glyph = "◆" },
    { id = 6, name = "HEART", glyph = "♥" },
}
Rules.schedule =
    { "unique", "unique", "pairs", "pairs", "minority", "minority", "unique", "unique" }
Rules.text = {
    unique = "Pick a symbol nobody else picks. Exactly one pick scores 1.",
    pairs = "Find a partner. Exactly two picks on a symbol score 1 each.",
    minority = "The smallest nonempty groups score 2 each. At least two symbols must be picked.",
}

function Rules.legal(participants)
    local ids = {}
    for id = 1, if participants <= 8 then 4 else 6 do
        ids[id] = id
    end
    return ids
end

function Rules.resolve(roster, choices, legal, modifier)
    assert(Rules.text[modifier], "Unknown scoring rule")
    local counts, allowed, awards, reveal = {}, {}, {}, {}
    for _, id in legal do
        allowed[id], counts[id] = true, 0
    end
    for _, player in roster do
        local choice = choices[player]
        if allowed[choice] then
            counts[choice] += 1
        end
    end
    local minimum, groups = math.huge, 0
    for _, count in counts do
        if count > 0 then
            groups += 1
            minimum = math.min(minimum, count)
        end
    end
    for _, player in roster do
        local choice = choices[player]
        local points = 0
        if allowed[choice] then
            if
                (modifier == "unique" and counts[choice] == 1)
                or (modifier == "pairs" and counts[choice] == 2)
            then
                points = 1
            elseif modifier == "minority" and groups >= 2 and counts[choice] == minimum then
                points = 2
            end
        end
        awards[player] = points
        table.insert(
            reveal,
            { id = player, choiceId = if allowed[choice] then choice else false, points = points }
        )
    end
    return { counts = counts, awards = awards, reveal = reveal }
end

function Rules.winners(records)
    local best, winners = -1, {}
    for id, record in records do
        -- A human must actually lock a choice in a completed round to qualify.
        if record.played > 0 then
            if record.score > best then
                best, winners = record.score, { id }
            elseif record.score == best then
                table.insert(winners, id)
            end
        end
    end
    table.sort(winners)
    return winners
end

function Rules.copyHistory(history)
    local copy = {}
    for index, item in history do
        copy[index] = { modifier = item.modifier, counts = table.clone(item.counts) }
    end
    return copy
end

return table.freeze(Rules)
