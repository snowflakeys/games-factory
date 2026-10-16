--!strict
local checks = 0
local function expect(value, message)
    assert(value, message)
    checks += 1
end
local Random = require("../SeededRandom")
-- Published Park-Miller states for an initial state of 1 (seed 0).
local draw = Random.new(0)
for _, state in { 16807, 282475249, 1622650073, 984943658, 1144108930 } do
    expect(draw(2147483647) == state + 1, "Known generator vector")
end
local a, b = Random.new(-2.7), Random.new(-2.7)
for index = 1, 1000 do
    local maximum = index % 17 + 1
    local value = a(maximum)
    expect(value == b(maximum) and value >= 1 and value <= maximum, "Replay and inclusive range")
end
local original = { "a", "b", "c", "d", "e" }
local shuffled = Random.shuffled(original, Random.new(123))
expect(table.concat(original) == "abcde", "Shuffle never mutates caller")
local seen = {}
for _, value in shuffled do
    expect(not seen[value] and table.find(original, value), "Shuffle is a permutation")
    seen[value] = true
end
expect(#Random.shuffled({}, Random.new(0)) == 0, "Empty shuffle")
for _, seed in { 0 / 0, math.huge, -math.huge, "seed" } do
    expect(not pcall(Random.new, seed), "Invalid seed rejected")
end
for _, maximum in { 0, -1, 1.5, math.huge, 2147483648 } do
    expect(not pcall(Random.new(1), maximum), "Invalid bound rejected")
end
print("PASS: SeededRandom 1.0.0, " .. checks .. " assertions")
