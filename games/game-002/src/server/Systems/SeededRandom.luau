--!strict
-- Seeded replay utility, not cryptographic randomness. All arithmetic is exact in doubles.
local SeededRandom = {}
function SeededRandom.new(seed)
    assert(
        type(seed) == "number" and seed == seed and math.abs(seed) < math.huge,
        "Finite seed required"
    )
    local state = math.floor(seed) % 2147483646 + 1
    return function(maximum)
        assert(
            type(maximum) == "number"
                and maximum % 1 == 0
                and maximum >= 1
                and maximum <= 2147483647,
            "Positive bounded integer maximum required"
        )
        state = (state * 16807) % 2147483647
        return state % maximum + 1
    end
end
function SeededRandom.shuffled(values, random)
    local copy = table.clone(values)
    for index = #copy, 2, -1 do
        local other = random(index)
        copy[index], copy[other] = copy[other], copy[index]
    end
    return copy
end
return table.freeze(SeededRandom)
