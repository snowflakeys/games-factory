--!strict
-- Deliberately only public inputs. The match engine commits bots before human input.
local Bot = {}
function Bot.choose(seed, legal, modifier, history)
    local frequency, maximum = {}, 0
    for _, id in legal do
        frequency[id] = 0
        for _, round in history do
            frequency[id] += round.counts[id] or 0
        end
        maximum = math.max(maximum, frequency[id])
    end
    local total, weights = 0, {}
    for _, id in legal do
        local weight = if modifier == "pairs"
            then frequency[id] + 1
            else maximum - frequency[id] + 1
        weights[id] = weight
        total += weight
    end
    local state = math.floor(seed) % 2147483646 + 1
    state = (state * 16807) % 2147483647
    local pick = state % total
    for _, id in legal do
        pick -= weights[id]
        if pick < 0 then
            return id
        end
    end
    error("A bot must have a legal choice")
end
return table.freeze(Bot)
