--!strict
-- Engine-free envelope validation, per-player rate limiting and private acknowledgements.
return function(TokenBucket, PrivateRequests)
    local Protocol = {}
    Protocol.__index = Protocol
    function Protocol.new(match)
        return setmetatable({ match = match, sessions = {} }, Protocol)
    end
    function Protocol:join(id, now)
        if not self.sessions[id] then
            self.sessions[id] = TokenBucket.new(6, 3, now)
        end
    end
    function Protocol:leave(id)
        self.sessions[id] = nil
    end
    function Protocol:handle(id, packet, now)
        local session = self.sessions[id]
        if not session or not self.match.humans[id] then
            return nil
        end
        if not session:take(now) then
            return nil
        end
        if not PrivateRequests.validPacket(packet) then
            return {
                kind = "ack",
                requestId = 0,
                code = "malformed",
                state = self.match:snapshot(id),
            }
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
end
