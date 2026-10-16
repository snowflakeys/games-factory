--!strict
-- Pure envelope/correlation mechanics. Caller owns authorization, privacy, and intent validation.
local PrivateRequests = { maximumId = 2147483647 }
PrivateRequests.__index = PrivateRequests
function PrivateRequests.validPacket(packet)
    if
        type(packet) ~= "table"
        or type(packet.requestId) ~= "number"
        or packet.requestId % 1 ~= 0
        or packet.requestId < 1
        or packet.requestId > PrivateRequests.maximumId
        or type(packet.intent) ~= "table"
    then
        return false
    end
    for key in packet do
        if key ~= "requestId" and key ~= "intent" then
            return false
        end
    end
    return true
end
function PrivateRequests.new(timeout)
    assert(
        type(timeout) == "number" and timeout > 0 and timeout < math.huge,
        "Positive finite timeout required"
    )
    return setmetatable({ serial = 0, pending = nil, timeout = timeout }, PrivateRequests)
end
function PrivateRequests:packet(intent, now, context)
    assert(
        self.serial < PrivateRequests.maximumId,
        "Request IDs exhausted; replace the connection before sending"
    )
    self.serial += 1
    self.pending = {
        id = self.serial,
        retryAt = now + self.timeout,
        context = if context then table.clone(context) else nil,
    }
    return { requestId = self.serial, intent = intent }
end
function PrivateRequests:receive(response, context)
    local matched = response.kind == "ack"
        and self.pending ~= nil
        and response.requestId == self.pending.id
    if matched then
        self.pending = nil
    end
    if self.pending and self.pending.context then
        for key, value in self.pending.context do
            if not context or context[key] ~= value then
                self.pending = nil
                break
            end
        end
    end
    return matched
end
function PrivateRequests:expired(now)
    return self.pending ~= nil and now >= self.pending.retryAt
end
return PrivateRequests
