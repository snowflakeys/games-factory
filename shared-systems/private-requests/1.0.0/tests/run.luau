--!strict
local checks = 0
local function expect(value, message)
    assert(value, message)
    checks += 1
end
local Requests = require("../PrivateRequests")
local tracker = Requests.new(3)
local context = { session = "a", turn = 1 }
local packet = tracker:packet({ action = "choose", choice = 2 }, 10, context)
context.turn = 2
expect(
    Requests.validPacket(packet) and tracker.pending.context.turn == 1,
    "Envelope and copied context"
)
expect(
    not tracker:receive(
        { kind = "state", requestId = packet.requestId },
        { session = "a", turn = 1 }
    ),
    "Broadcast is no acknowledgement"
)
expect(tracker.pending ~= nil and not tracker:expired(12.99), "Gate remains before timeout")
expect(tracker:expired(13), "Exact timeout boundary")
local sync = tracker:packet({ action = "sync" }, 13)
expect(
    sync.requestId ~= packet.requestId and sync.intent.action == "sync",
    "Caller replaces with read-only sync"
)
expect(
    not tracker:receive({ kind = "ack", requestId = packet.requestId }, {}),
    "Stale ack cannot unlock recovery"
)
expect(tracker.pending.id == sync.requestId, "Recovery gate retained")
expect(tracker:receive({ kind = "ack", requestId = sync.requestId }, {}), "Matching private ack")
expect(tracker.pending == nil and not tracker:expired(100), "Matching ack releases gate")
tracker:packet({ action = "choose" }, 20, { session = "a", turn = 1 })
tracker:receive({ kind = "state" }, { session = "a", turn = 2 })
expect(tracker.pending == nil, "New authoritative context discards obsolete action")
for _, bad in
    {
        false,
        {},
        { requestId = 0, intent = {} },
        { requestId = 1.5, intent = {} },
        { requestId = 0 / 0, intent = {} },
        { requestId = math.huge, intent = {} },
        { requestId = 2147483648, intent = {} },
        { requestId = 1, intent = {}, score = 99 },
        { requestId = 1, intent = false },
    }
do
    expect(not Requests.validPacket(bad), "Malformed exact envelope rejected")
end
expect(Requests.validPacket({ requestId = 2147483647, intent = {} }), "Largest ID accepted")
tracker.serial = Requests.maximumId
expect(not pcall(function()
    tracker:packet({}, 0)
end), "No ID reuse after exhaustion")
print("PASS: PrivateRequests 1.0.0, " .. checks .. " assertions")
