--!strict
local checks = 0
local function expect(value, message)
    assert(value, message)
    checks += 1
end
local Random = require("../../../seeded-random/1.0.0/SeededRandom")
local Bot = require("../PublicHistoryBot")(Random)
local history = { { counts = { [1] = 3, [2] = 1 } }, { counts = { [1] = 2, [3] = 1 } } }
-- Verify weighted interval boundaries with a controlled random source, independently of seeds.
local requested = 0
local controlled = require("../PublicHistoryBot")({
    new = function()
        return function(maximum)
            expect(maximum == 11, "Frequent weights sum to 6+2+2+1")
            return requested
        end
    end,
})
for position, expected in { 1, 1, 1, 1, 1, 1, 2, 2, 3, 3, 4 } do
    requested = position
    expect(
        controlled.choose(0, { 1, 2, 3, 4 }, "frequent", history) == expected,
        "Weighted interval selection"
    )
end
local frequent, rare = {}, {}
for seed = 1, 1000 do
    for _, strategy in { "frequent", "rare" } do
        local choice = Bot.choose(seed, { 1, 2, 3, 4 }, strategy, history)
        expect(
            choice >= 1
                and choice <= 4
                and choice == Bot.choose(seed, { 1, 2, 3, 4 }, strategy, history),
            "Seeded legal replay"
        )
        local counts = if strategy == "frequent" then frequent else rare
        counts[choice] = (counts[choice] or 0) + 1
    end
end
expect(
    frequent[1] > frequent[4] and rare[1] < rare[4],
    "Strategies use public frequency in opposite directions"
)
expect(history[1].counts[1] == 3 and history[2].counts[1] == 2, "Public history unchanged")
expect(Bot.choose(1, { "only" }, "rare", {}) == "only", "Arbitrary stable IDs and no history")
expect(not pcall(Bot.choose, 1, {}, "rare", {}), "Empty legal set rejected")
expect(not pcall(Bot.choose, 1, { 1 }, "unknown", {}), "Unknown strategy rejected")
print("PASS: PublicHistoryBot 1.0.0, " .. checks .. " assertions")
