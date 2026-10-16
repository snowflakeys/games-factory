--!strict
-- Engine-free envelope validation, per-player rate limiting and private acknowledgements.
local Protocol = {}
Protocol.__index = Protocol
function Protocol.new(match)
    return setmetatable({ match = match, sessions = {} }, Protocol)
end
function Protocol:join(id, now)
    if not self.sessions[id] then
        self.sessions[id] = { budget = 6, updated = now }
    end
end
function Protocol:leave(id)
    self.sessions[id] = nil
end
local function validPacket(packet)
    if
        type(packet) ~= "table"
        or type(packet.requestId) ~= "number"
        or packet.requestId % 1 ~= 0
        or packet.requestId < 1
        or packet.requestId > 2147483647
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
function Protocol:handle(id, packet, now)
    local session = self.sessions[id]
    if not session or not self.match.humans[id] then
        return nil
    end
    session.budget = math.min(6, session.budget + math.max(0, now - session.updated) * 3)
    session.updated = math.max(session.updated, now)
    if session.budget < 1 then
        return nil
    end
    session.budget -= 1
    if not validPacket(packet) then
        return { kind = "ack", requestId = 0, code = "malformed", state = self.match:snapshot(id) }
    end
    local code = self.match:apply(id, packet.intent, now)
    return {
        kind = "ack",
        requestId = packet.requestId,
        code = code,
        state = self.match:snapshot(id),
    }
end
return Protocol
