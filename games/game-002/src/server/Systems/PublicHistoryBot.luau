--!strict
-- No match object, current choices, player identities, or hidden state enter this policy.
return function(SeededRandom)
    local PublicHistoryBot = {}
    function PublicHistoryBot.choose(seed, legal, strategy, history)
        assert(#legal > 0, "At least one legal choice required")
        assert(
            strategy == "frequent" or strategy == "rare",
            "Known public-frequency strategy required"
        )
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
            local weight = if strategy == "frequent"
                then frequency[id] + 1
                else maximum - frequency[id] + 1
            weights[id] = weight
            total += weight
        end
        local pick = SeededRandom.new(seed)(total) - 1
        for _, id in legal do
            pick -= weights[id]
            if pick < 0 then
                return id
            end
        end
        error("A bot must have a legal choice")
    end
    return table.freeze(PublicHistoryBot)
end
