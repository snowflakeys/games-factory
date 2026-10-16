--!strict
local checks = 0
local function expect(value, message)
    assert(value, message)
    checks += 1
end
local Bucket = require("../TokenBucket")
for _, settings in { { 8, 4 }, { 6, 3 } } do
    local capacity, rate = settings[1], settings[2]
    local bucket = Bucket.new(capacity, rate, 10)
    for _ = 1, capacity do
        expect(bucket:take(10), "Full configured burst")
    end
    expect(not bucket:take(10), "Burst exhausted")
    expect(not bucket:take(9), "Backward clock grants no credit")
    expect(not bucket:take(10 + 0.5 / rate), "Partial token waits")
    expect(bucket:take(10 + 1 / rate), "Exact token deadline")
    expect(not bucket:take(10 + 1 / rate), "Same token cannot be spent twice")
    for _ = 1, capacity do
        expect(bucket:take(1000), "Idle refill capped at burst")
    end
    expect(not bucket:take(1000), "No excess credit beyond cap")
    for _, bad in { 0 / 0, math.huge, -math.huge } do
        expect(
            not bucket:take(bad) and bucket.updated == 1000,
            "Invalid clock cannot poison bucket"
        )
    end
    expect(Bucket.new(capacity, rate, 10):take(10), "Independent session budget")
end
expect(not pcall(Bucket.new, 0, 1, 0), "Invalid capacity")
expect(not pcall(Bucket.new, 1, 0, 0), "Invalid refill")
print("PASS: TokenBucket 1.0.0, " .. checks .. " assertions")
