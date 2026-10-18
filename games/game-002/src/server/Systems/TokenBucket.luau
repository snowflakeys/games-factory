--!strict
-- Pure per-session token bucket; callers own identity, lifetime, and the trusted clock.
local TokenBucket = {}
TokenBucket.__index = TokenBucket
local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end
function TokenBucket.new(capacity, refill, now)
    assert(
        finite(capacity) and capacity >= 1 and finite(refill) and refill > 0 and finite(now),
        "Valid bucket configuration and time required"
    )
    return setmetatable(
        { capacity = capacity, refill = refill, budget = capacity, updated = now },
        TokenBucket
    )
end
function TokenBucket:take(now)
    if not finite(now) then
        return false
    end
    self.budget =
        math.min(self.capacity, self.budget + math.max(0, now - self.updated) * self.refill)
    self.updated = math.max(now, self.updated)
    if self.budget < 1 then
        return false
    end
    self.budget -= 1
    return true
end
return TokenBucket
