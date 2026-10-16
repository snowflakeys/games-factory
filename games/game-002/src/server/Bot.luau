--!strict
-- Map approved game modifiers to the pinned public-frequency policy.
return function(PublicHistoryBot)
    local Bot = {}
    function Bot.choose(seed, legal, modifier, history)
        return PublicHistoryBot.choose(
            seed,
            legal,
            if modifier == "pairs" then "frequent" else "rare",
            history
        )
    end
    return table.freeze(Bot)
end
