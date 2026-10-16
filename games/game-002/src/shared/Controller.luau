--!strict
-- Pure client request/ack state. A broadcast never impersonates a private acknowledgement.
local Controller = {}
Controller.__index = Controller
local messages = {
    malformed = "Input rejected. Try again.",
    stale = "Round refreshed. Pick in the current round.",
    not_participating = "You join the next round.",
    out_of_range = "Choose one of the visible symbols.",
    late = "Time is up. Wait for the next pick.",
    not_results = "Play again is available after the match.",
    duplicate = "Your first choice stays locked.",
}
function Controller.new()
    return setmetatable(
        { state = nil, serial = 0, pending = nil, notice = "", noticeUntil = 0 },
        Controller
    )
end
function Controller:_packet(intent, now)
    self.serial += 1
    local packet = { requestId = self.serial, intent = intent }
    self.pending =
        { id = self.serial, retryAt = now + 3, matchId = intent.matchId, roundId = intent.roundId }
    return packet
end
function Controller:sync(now)
    return self:_packet({ action = "sync" }, now)
end
function Controller:request(action, choiceId, now)
    local state = self.state
    if not state or self.pending then
        return nil
    end
    if action == "choose" then
        if
            state.phase ~= "choosing"
            or not state.you.participating
            or state.you.choiceId
            or now >= state.deadline
        then
            return nil
        end
    elseif action == "ready" then
        if state.phase ~= "results" or state.you.ready then
            return nil
        end
    else
        return nil
    end
    local intent = { action = action, matchId = state.matchId, roundId = state.roundId }
    if action == "choose" then
        intent.choiceId = choiceId
    end
    return self:_packet(intent, now)
end
function Controller:receive(response, now)
    local incoming = response.state
    if not self.state or incoming.revision >= self.state.revision then
        self.state = incoming
    end
    local matched = response.kind == "ack"
        and self.pending
        and response.requestId == self.pending.id
    if matched then
        self.pending = nil
        if messages[response.code] then
            self.notice, self.noticeUntil = messages[response.code], now + 3
        end
    end
    if
        self.pending
        and self.pending.matchId
        and (
            self.pending.matchId ~= self.state.matchId
            or self.pending.roundId ~= self.state.roundId
        )
    then
        self.pending = nil
    end
end
function Controller:poll(now)
    if self.pending and now >= self.pending.retryAt then
        self.notice, self.noticeUntil = "Refreshing your private acknowledgement...", now + 3
        return self:sync(now)
    end
    return nil
end
return Controller
