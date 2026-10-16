--!strict
local Rules = require("../src/shared/Rules")
local SeededRandom = require("../src/server/Systems/SeededRandom")
local TokenBucket = require("../src/server/Systems/TokenBucket")
local PrivateRequests = require("../src/shared/Systems/PrivateRequests")
local PublicHistoryBot = require("../src/server/Systems/PublicHistoryBot")(SeededRandom)
local Bot = require("../src/server/Bot")(PublicHistoryBot)
local Match = require("../src/server/Match")(Rules, Bot)
local Protocol = require("../src/server/Protocol")(TokenBucket, PrivateRequests)
local Controller = require("../src/shared/Controller")(PrivateRequests)
local Layout = require("../src/shared/Layout")
local checks = 0
local function expect(value, message)
    assert(value, message)
    checks += 1
end
-- Golden bot outputs captured from the pre-extraction implementation.
for _, fixture in require("./bot-v1-fixtures") do
    local legal = {}
    for id = 1, fixture.size do
        table.insert(legal, id)
    end
    local history = { { counts = { [1] = 3, [2] = 1, [3] = 0, [4] = 2, [5] = 1, [6] = 0 } } }
    for seed, expected in fixture.picks do
        expect(
            Bot.choose(seed, legal, fixture.modifier, history) == expected,
            "Original seeded bot preserved"
        )
    end
end
local function newMatch(players, seed, customBot)
    local serial = 0
    local Type = if customBot then require("../src/server/Match")(Rules, customBot) else Match
    local engine = Type.new(function()
        serial += 1
        return "match-" .. serial
    end, function()
        return seed or 1
    end)
    for player = 1, players do
        expect(engine:join("u:" .. player, "Player " .. player, 0), "Player joins")
    end
    engine:advance(1)
    return engine
end
local function choice(engine, id)
    return { action = "choose", matchId = engine.matchId, roundId = engine.roundId, choiceId = id }
end
local function ready(engine)
    return { action = "ready", matchId = engine.matchId, roundId = engine.roundId }
end
local function totalScores(engine)
    local total = 0
    for _, record in engine.records do
        total += record.score
    end
    return total
end
local function copyChoices(engine)
    return table.clone(engine.choices)
end
-- Independent per-person oracle: compare that person's group's size to every other group.
local function oracle(roster, choices, legal, modifier, player)
    local pick = choices[player]
    if not table.find(legal, pick) then
        return 0
    end
    local function frequency(symbol)
        local n = 0
        for _, id in roster do
            if choices[id] == symbol then
                n += 1
            end
        end
        return n
    end
    local size = frequency(pick)
    if modifier == "unique" then
        return if size == 1 then 1 else 0
    elseif modifier == "pairs" then
        return if size == 2 then 1 else 0
    end
    local another = false
    for _, symbol in legal do
        local n = frequency(symbol)
        if n > 0 then
            if symbol ~= pick then
                another = true
            end
            if n < size then
                return 0
            end
        end
    end
    return if another then 2 else 0
end

-- Every four-person combination of four symbols or a missing pick, for all rules.
local four = { "u:1", "u:2", "u:3", "u:4" }
for encoded = 0, 624 do
    local remaining, picks = encoded, {}
    for _, id in four do
        local symbol = remaining % 5
        remaining = math.floor(remaining / 5)
        if symbol ~= 0 then
            picks[id] = symbol
        end
    end
    picks.impostor = 1
    for _, modifier in { "unique", "pairs", "minority" } do
        local result = Rules.resolve(four, picks, { 1, 2, 3, 4 }, modifier)
        expect(result.awards.impostor == nil, "Nonmember never scores")
        for _, id in four do
            expect(
                result.awards[id] == oracle(four, picks, { 1, 2, 3, 4 }, modifier, id),
                "Exhaustive independent score oracle"
            )
        end
    end
end
expect(
    Rules.resolve(
        four,
        { ["u:1"] = 1, ["u:2"] = 1, ["u:3"] = 2, ["u:4"] = 2 },
        { 1, 2 },
        "minority"
    ).awards["u:1"] == 2,
    "Tied minority groups all score"
)
expect(
    Rules.resolve(
        four,
        { ["u:1"] = 1, ["u:2"] = 1, ["u:3"] = 1, ["u:4"] = 1 },
        { 1, 2 },
        "minority"
    ).awards["u:1"] == 0,
    "Only one group earns no minority points"
)
expect(
    Rules.resolve(four, { ["u:1"] = 9 }, { 1, 2 }, "unique").awards["u:1"] == 0,
    "Illegal pure-model pick earns nothing"
)

local simulated, replayed, botWins = 0, 0, 0
local function simulate(players, seed, replay)
    local engine = newMatch(players, seed)
    local trace = {}
    for round = 1, 8 do
        expect(engine.round == round and engine.phase == "choosing", "Eight-round phase sequence")
        expect(#engine.roster == math.max(4, players), "Bots fill to four")
        expect(#engine.legal == (if players > 8 then 6 else 4), "Adaptive symbol count")
        expect(engine.modifier == Rules.schedule[round], "Fixed two-round modifier cadence")
        local before = {}
        for id, record in engine.records do
            before[id] = record.score
        end
        local botPicks = copyChoices(engine)
        local at = engine.deadline - 5.8
        for player = 1, players do
            if (seed + round * 7 + player) % 11 ~= 0 then
                local id = (seed + round * 13 + player * 7) % #engine.legal + 1
                expect(
                    engine:apply("u:" .. player, choice(engine, id), at) == "locked",
                    "Generated legal human choice locks"
                )
            end
        end
        for id, value in botPicks do
            expect(engine.choices[id] == value, "Human submissions cannot revise committed bots")
        end
        for id, record in engine.records do
            expect(record.score == before[id], "No scoring before deadline")
        end
        local expected = {}
        for _, id in engine.roster do
            expected[id] = oracle(engine.roster, engine.choices, engine.legal, engine.modifier, id)
        end
        local deadline = engine.deadline
        engine:advance(deadline)
        expect(engine.phase == "reveal", "Exact deadline resolves to reveal")
        for _, id in engine.roster do
            local record = engine.records[id]
            expect(
                record.score - before[id] == expected[id],
                "Engine resolves exactly the independent expected points"
            )
            expect(
                record.score >= 0 and record.score <= 10,
                "Match score bounded by approved schedule"
            )
            table.insert(trace, id .. ":" .. tostring(engine.choices[id]) .. ":" .. record.score)
        end
        local total = totalScores(engine)
        engine:advance(deadline + 0.01)
        expect(totalScores(engine) == total, "Repeated clock tick never awards twice")
        engine:advance(engine.deadline)
        if round < 8 then
            expect(engine.phase == "intermission", "Two-second reveal then one-second intermission")
            engine:advance(engine.deadline)
        else
            expect(engine.phase == "results", "Round eight finishes match")
        end
        if replay then
            replayed += 1
        else
            simulated += 1
        end
    end
    for _, id in engine.winners do
        expect(engine.records[id].played > 0, "Every winner participated in a resolved round")
        if engine.records[id].bot then
            botWins += 1
        end
        for _, record in engine.records do
            expect(
                record.played == 0 or engine.records[id].score >= record.score,
                "Winner has maximal eligible score"
            )
        end
    end
    table.insert(trace, table.concat(engine.winners, ","))
    return table.concat(trace, "|"), engine
end
for _, players in { 1, 2, 4, 8, 12, 16 } do
    for seedIndex = 1, 210 do
        local seed = players * 100000 + seedIndex
        local signature = simulate(players, seed, false)
        if seedIndex % 21 == 0 then
            local repeated = simulate(players, seed, true)
            expect(signature == repeated, "Deterministic complete match replay")
        end
    end
end
expect(simulated == 10080, "At least ten thousand seeded rounds across all populations")
expect(botWins > 0, "Bot victory covered by simulations")

-- Strict transport/intent rejection, duplicate locks, deadline boundary, privacy and snapshots.
local engine = newMatch(2, 42)
local valid = choice(engine, 1)
local malformed = {
    false,
    8,
    "pick",
    {},
    { action = "choose" },
    { action = "choose", matchId = engine.matchId, roundId = engine.roundId, choiceId = "1" },
    { action = "choose", matchId = engine.matchId, roundId = engine.roundId, choiceId = 1.5 },
    { action = "choose", matchId = engine.matchId, roundId = engine.roundId, choiceId = 0 / 0 },
    { action = "choose", matchId = engine.matchId, roundId = engine.roundId, choiceId = math.huge },
    { action = "choose", matchId = false, roundId = engine.roundId, choiceId = 1 },
    { action = "choose", matchId = engine.matchId, roundId = string.rep("x", 81), choiceId = 1 },
    {
        action = "choose",
        matchId = engine.matchId,
        roundId = engine.roundId,
        choiceId = 1,
        score = 100,
    },
    {
        action = "choose",
        matchId = engine.matchId,
        roundId = engine.roundId,
        choiceId = 1,
        playerId = "u:2",
    },
    {
        action = "choose",
        matchId = engine.matchId,
        roundId = engine.roundId,
        choiceId = 1,
        timestamp = 0,
    },
    { action = "sync", choices = {} },
    { action = "ready", matchId = engine.matchId, roundId = engine.roundId, choiceId = 1 },
    { action = "award", score = 100 },
}
for _, bad in malformed do
    local revision, total, picked = engine.revision, totalScores(engine), engine.choices["u:1"]
    expect(engine:apply("u:1", bad, 1.1) == "malformed", "Malformed intent rejected")
    expect(
        engine.revision == revision
            and totalScores(engine) == total
            and engine.choices["u:1"] == picked,
        "Malformed intent cannot mutate run"
    )
end
expect(
    engine:apply("intruder", valid, 1.1) == "not_connected",
    "Membership cannot be claimed in payload"
)
expect(engine:apply("u:1", choice(engine, 0), 1.1) == "out_of_range", "Zero choice rejected")
expect(
    engine:apply("u:1", choice(engine, 5), 1.1) == "out_of_range",
    "Unavailable fifth choice rejected"
)
local stale = table.clone(valid)
stale.roundId = "old-round"
expect(engine:apply("u:1", stale, 1.1) == "stale", "Old round rejected")
stale = table.clone(valid)
stale.matchId = "old-match"
expect(engine:apply("u:1", stale, 1.1) == "stale", "Old match rejected")
expect(engine:apply("u:1", valid, 1.2) == "locked", "First pick accepted")
local revision = engine.revision
expect(engine:apply("u:1", valid, 1.3) == "duplicate", "Duplicate pick rejected")
expect(engine:apply("u:1", choice(engine, 2), 1.3) == "duplicate", "Cannot switch after locking")
expect(engine.choices["u:1"] == 1 and engine.revision == revision, "No duplicate side effects")
local public = engine:snapshot("u:2")
expect(
    public.you.choiceId == false and public.lockedCount == 3,
    "Viewer sees only own private pick and aggregate count"
)
expect(
    public.seed == nil and public.choices == nil and public.history == nil and public.bots == nil,
    "Hidden state excluded"
)
for _, record in public.standings do
    expect(
        record.choiceId == false and record.points == 0,
        "No unrevealed picks or deltas in standings"
    )
end
local own = engine:snapshot("u:1")
expect(own.you.choiceId == 1, "Private acknowledgement contains own pick")
own.you.score = 999
own.standings[1].score = 999
own.symbols[1] = 99
own.counts[1] = 999
own.winners[1] = "impostor"
expect(
    totalScores(engine) == 0 and engine.legal[1] == 1 and #engine.winners == 0,
    "Snapshots have no mutable aliases"
)
local deadline = engine.deadline
expect(
    engine:apply("u:2", choice(engine, 2), deadline) == "late",
    "Deadline equality rejects the pick"
)
expect(
    engine.phase == "reveal" and engine.choices["u:2"] == nil,
    "Late pick cannot enter the revealed round"
)
public = engine:snapshot("u:2")
expect(#public.counts == 4, "Counts available after reveal")
local observed = false
for _, record in public.standings do
    if record.id == "u:1" then
        observed = record.choiceId == 1
    end
end
expect(observed, "Accepted choices actually reveal at the boundary")
local total = totalScores(engine)
engine:advance(deadline)
expect(totalScores(engine) == total, "Terminal resolution idempotent")

-- Joins, leaves, freeze, bot replacement and same-server ephemeral reconnect.
engine = newMatch(1, 7)
local originalDeadline, originalRoster = engine.deadline, #engine.roster
expect(engine:apply("u:1", choice(engine, 4), 1.1) == "locked", "Departure fixture locks pick")
engine:join("u:2", "Late arrival", 1.2)
expect(
    not engine.rosterSet["u:2"] and #engine.roster == originalRoster,
    "Mid-round arrival waits without changing roster"
)
expect(engine:snapshot("u:2").you.joinedRound == 2, "Late-join label records upcoming round")
expect(
    engine:apply("u:2", choice(engine, 2), 1.3) == "not_participating",
    "Late join cannot enter frozen round"
)
engine:leave("u:1", 1.4)
expect(
    engine.choices["u:1"] == 4 and #engine.roster == 4,
    "Departed accepted choice remains, no mid-round bot replacement"
)
engine:join("u:1", "Reconnected", 1.5)
expect(engine:snapshot("u:1").you.choiceId == 4, "Rejoin rehydrates current committed choice")
expect(engine:apply("u:1", choice(engine, 1), 1.6) == "duplicate", "Reconnect cannot switch choice")
engine:advance(originalDeadline)
local retainedScore = engine.records["u:1"].score
engine:leave("u:1", originalDeadline + 0.1)
engine:join("u:1", "Reconnected again", originalDeadline + 0.2)
expect(
    engine:snapshot("u:1").you.score == retainedScore,
    "Same-match reconnect retains earned score"
)
engine:join("u:3", "Reveal join", originalDeadline + 0.3)
engine:advance(engine.deadline)
engine:join("u:4", "Intermission join", engine.deadline - 0.1)
engine:advance(engine.deadline)
expect(
    #engine.roster == 4 and engine.rosterSet["u:4"] and engine.choices["bot:1"] == nil,
    "Bots disappear only at next roster freeze"
)
local beforeRespawn = engine:snapshot("u:1")
engine:join("u:1", "Duplicate join", engine.now)
expect(
    engine:snapshot("u:1").you.score == beforeRespawn.you.score
        and engine.roundId == beforeRespawn.roundId,
    "Respawn/join is idempotent"
)
for _, id in { "u:1", "u:2", "u:3", "u:4" } do
    engine:leave(id, engine.now)
end
expect(
    engine.phase == "paused" and next(engine.records) == nil and next(engine.choices) == nil,
    "Zero-human pause cleans ephemeral state"
)
local previousId = beforeRespawn.matchId
engine:join("u:1", "Fresh arrival", engine.now + 1)
expect(
    engine.phase == "starting" and engine.matchId ~= previousId and engine.records["u:1"].score == 0,
    "Next arrival starts a fresh match"
)
local full = newMatch(16, 1)
expect(
    not full:join("u:17", "Extra", 1.2) and #full.roster == 16,
    "Sixteen-human capacity enforced"
)

-- Bots see only the public history contract and commit before any human submission.
local calls = 0
local spy = {
    choose = function(seed, legal, modifier, history)
        calls += 1
        expect(type(seed) == "number" and type(modifier) == "string", "Bot seed/rule input types")
        for _, round in history do
            for key in round do
                expect(
                    key == "modifier" or key == "counts",
                    "Bot receives public revealed history only"
                )
            end
        end
        return Bot.choose(seed, legal, modifier, history)
    end,
}
local spyMatch = newMatch(2, 10, spy)
expect(calls == 2, "Two bots precommit at round start")
spyMatch:apply("u:1", choice(spyMatch, 1), 1.2)
spyMatch:apply("u:2", choice(spyMatch, 2), 1.3)
expect(calls == 2, "No bot policy invocation after human choices")
local histories = { { modifier = "unique", counts = { 3, 1, 0, 0 } } }
for seed = 1, 200 do
    local pick = Bot.choose(seed, { 1, 2, 3, 4 }, "unique", histories)
    expect(
        pick >= 1 and pick <= 4 and pick == Bot.choose(seed, { 1, 2, 3, 4 }, "unique", histories),
        "Bot seeded replay and legality"
    )
end
expect(histories[1].counts[1] == 3, "Bot leaves public history unchanged")

-- Complete zero-score ties, all misses, and bots winning without a human pick.
local function finishUniform(players, pick)
    local m = newMatch(players, 5)
    for round = 1, 8 do
        if pick then
            for player = 1, players do
                m:apply("u:" .. player, choice(m, pick), m.deadline - 1)
            end
        end
        m:advance(m.deadline)
        m:advance(m.deadline)
        if round < 8 then
            m:advance(m.deadline)
        end
    end
    return m
end
local ties = finishUniform(4, 1)
expect(totalScores(ties) == 0 and #ties.winners == 4, "All-zero eligible humans share victory")
expect(#finishUniform(4, nil).winners == 0, "No human winners without participation")
local botOnly = finishUniform(1, nil)
expect(#botOnly.winners > 0, "Bots can win")
for _, id in botOnly.winners do
    expect(botOnly.records[id].bot, "Nonparticipating human excluded from bot victory")
end
local matchId, resultsAt, automatic = ties.matchId, ties.now, ties.deadline
expect(ties:apply("u:1", ready(ties), resultsAt + 0.1) == "ready", "Ready acknowledged")
expect(ties.deadline == automatic, "One ready does not skip others")
for player = 2, 4 do
    ties:apply("u:" .. player, ready(ties), resultsAt + 0.2)
end
expect(ties.deadline == resultsAt + 1.2, "All ready schedules one-second replay transition")
ties:join("u:5", "Results join", resultsAt + 0.3)
expect(
    ties.ready["u:1"] and not ties.ready["u:5"] and ties.deadline == automatic,
    "Newcomer clears only own readiness; automatic deadline retained"
)
ties:apply("u:5", ready(ties), resultsAt + 0.4)
local fastDeadline = ties.deadline
ties:leave("u:5", resultsAt + 0.5)
expect(ties.deadline == fastDeadline, "Departing ready player cannot postpone replay")
expect(
    ties:apply("u:1", ready(ties), resultsAt + 0.6) == "duplicate" and ties.deadline == fastDeadline,
    "Duplicate readiness cannot extend deadline"
)
local oldReady = ready(ties)
ties:advance(fastDeadline)
expect(ties.phase == "starting" and ties.matchId ~= matchId, "Rematch starts fresh ID")
expect(totalScores(ties) == 0, "New match clears scores")
expect(ties:apply("u:1", oldReady, ties.now) == "stale", "Late previous-match ready rejected")
local auto = finishUniform(4, 1)
local oldAuto = auto.matchId
auto:advance(auto.deadline)
expect(
    auto.matchId ~= oldAuto and auto.phase == "starting",
    "Six-second automatic replay without ready input"
)

-- Protocol limiter applies even to bad envelopes, with per-human budgets and bounded echo IDs.
engine = newMatch(2, 11)
local protocol = Protocol.new(engine)
protocol:join("u:1", 1)
protocol:join("u:2", 1)
local badPackets = {
    false,
    {},
    { requestId = 1 },
    { requestId = "1", intent = {} },
    { requestId = 0 / 0, intent = {} },
    { requestId = math.huge, intent = {} },
    { requestId = 0, intent = {} },
    { requestId = 2147483648, intent = {} },
    { requestId = 1, intent = {}, extra = true },
}
for index, packet in badPackets do
    local response = protocol:handle("u:1", packet, 1 + index)
    expect(
        response.code == "malformed" and response.requestId == 0,
        "Malformed envelope is bounded and rejected"
    )
end
local frozen = engine.revision
for n = 1, 6 do
    local response = protocol:handle("u:1", { requestId = n, intent = { action = "sync" } }, 20)
    expect(response.code == "synced", "Burst six allowed")
end
frozen = engine.revision
for n = 1, 30 do
    expect(
        protocol:handle("u:1", { requestId = n, intent = choice(engine, 1) }, 20) == nil,
        "Over-rate requests dropped"
    )
end
expect(engine.revision == frozen and engine.choices["u:1"] == nil, "Over-rate input cannot mutate")
expect(
    protocol:handle("u:2", { requestId = 1, intent = { action = "sync" } }, 20) ~= nil,
    "Another player has independent budget"
)
expect(
    protocol:handle("u:1", { requestId = 10, intent = { action = "sync" } }, 20.34).code == "synced",
    "Three-per-second refill recovers sync"
)
protocol:leave("u:1")
expect(
    protocol:handle("u:1", { requestId = 20, intent = { action = "sync" } }, 30) == nil,
    "Departed protocol session removed"
)

-- Client request correlation, broadcasts, timeout recovery, stale acks and phase changes.
engine = newMatch(2, 12)
protocol = Protocol.new(engine)
protocol:join("u:1", 1)
local client = Controller.new()
local packet = client:sync(1)
client:receive(protocol:handle("u:1", packet, 1), 1)
expect(client.pending == nil and client.state.phase == "choosing", "Initial sync hydrates client")
packet = client:request("choose", 1, 1.1)
expect(packet and client:request("choose", 2, 1.1) == nil, "In-flight input disabled")
engine:apply("u:2", choice(engine, 2), 1.2)
client:receive({ kind = "state", state = engine:snapshot("u:1") }, 1.2)
expect(
    client.pending ~= nil and client:request("choose", 2, 1.2) == nil,
    "Broadcast cannot impersonate own acknowledgement"
)
local delayedAck = protocol:handle("u:1", packet, 1.3)
expect(client:poll(4.09) == nil, "Timeout not early")
local sync = client:poll(4.1)
expect(
    sync.intent.action == "sync"
        and sync.intent.choiceId == nil
        and sync.requestId ~= packet.requestId,
    "Timeout does read-only sync with fresh correlation ID"
)
client:receive(delayedAck, 4.1)
expect(client.pending ~= nil, "Old acknowledgement cannot clear newer sync")
client:receive(protocol:handle("u:1", sync, 4.1), 4.1)
expect(
    client.pending == nil and client.state.you.choiceId == 1,
    "Read-back safely recovers acknowledged choice"
)
expect(client:request("choose", 3, 4.2) == nil, "Recovered lock cannot choose twice")
local final = finishUniform(2, 1)
protocol = Protocol.new(final)
protocol:join("u:1", final.now)
client:receive({ kind = "state", state = final:snapshot("u:1") }, final.now)
-- Different fixtures can have lower revisions; initialize a realistic fresh controller for results.
client = Controller.new()
client:receive({ kind = "state", state = final:snapshot("u:1") }, final.now)
packet = client:request("ready", nil, final.now + 0.1)
client:receive(delayedAck, final.now + 0.1)
expect(
    client.pending and client.pending.id == packet.requestId,
    "Unrelated old ack cannot clear new in-flight request"
)
client:receive(protocol:handle("u:1", packet, final.now + 0.1), final.now + 0.1)
expect(client.pending == nil and client.state.you.ready, "Ready private acknowledgement")
local waiting = newMatch(1, 3)
client = Controller.new()
client:receive({ kind = "state", state = waiting:snapshot("u:1") }, 1)
client:request("choose", 1, 1.1)
waiting:advance(waiting.deadline)
waiting:advance(waiting.deadline)
waiting:advance(waiting.deadline)
client:receive({ kind = "state", state = waiting:snapshot("u:1") }, waiting.now)
expect(client.pending == nil, "Authoritative round change clears obsolete in-flight choice")
expect(
    client:request("choose", 1, waiting.deadline) == nil,
    "Client deadline boundary blocks expired input"
)

-- Respawn/sync preserves match, score, readiness and private pick in every active phase.
local lifecycle = Match.new(function()
    return "lifecycle"
end, function()
    return 9
end)
lifecycle:join("u:1", "One", 0)
lifecycle:join("u:2", "Two", 0)
local phasesSeen = {}
local function respawn(m)
    local state, respawnRevision = m:snapshot("u:1"), m.revision
    m:join("u:1", "One", m.now)
    local rehydrated = m:snapshot("u:1")
    expect(
        m.revision == respawnRevision
            and rehydrated.phase == state.phase
            and rehydrated.matchId == state.matchId
            and rehydrated.roundId == state.roundId
            and rehydrated.you.score == state.you.score
            and rehydrated.you.choiceId == state.you.choiceId
            and rehydrated.you.ready == state.you.ready,
        "Respawn rehydrates without resetting phase/private state"
    )
    phasesSeen[m.phase] = true
end
respawn(lifecycle)
lifecycle:advance(1)
lifecycle:apply("u:1", choice(lifecycle, 1), 1.2)
respawn(lifecycle)
lifecycle:advance(lifecycle.deadline)
respawn(lifecycle)
local revealed = lifecycle:snapshot("u:1")
local actualCount = lifecycle.counts[1]
revealed.counts[1] = 999
expect(lifecycle.counts[1] == actualCount, "Revealed counts are copied")
lifecycle:advance(lifecycle.deadline)
respawn(lifecycle)
local resultsFixture = finishUniform(4, 1)
resultsFixture:apply("u:1", ready(resultsFixture), resultsFixture.now + 0.1)
respawn(resultsFixture)
local winnersCopy = resultsFixture:snapshot("u:1")
winnersCopy.winners[1] = "impostor"
expect(resultsFixture.winners[1] ~= "impostor", "Results winner array is copied")
for _, phaseName in { "starting", "choosing", "reveal", "intermission", "results" } do
    expect(phasesSeen[phaseName], "Every active phase has respawn coverage")
end
local boundary = newMatch(4, 8)
local endAt = boundary.deadline
expect(
    boundary:apply("u:1", choice(boundary, 1), endAt - 0.000001) == "locked",
    "Pick just before deadline accepted"
)
expect(
    boundary:apply("u:2", choice(boundary, 2), endAt) == "late",
    "Pick exactly at deadline rejected"
)
expect(
    boundary:apply("u:3", choice(boundary, 3), endAt + 0.000001) == "late",
    "Pick just after deadline rejected"
)
expect(
    boundary.records["u:1"].score == 1 and boundary.records["u:2"].score == 0,
    "Only timely choices score"
)
local catchup = newMatch(1, 77)
local previousRevision = catchup.revision
catchup:advance(100000)
expect(
    catchup.revision - previousRevision <= 64,
    "Server-hitch catch-up bounded to 64 transitions per call"
)

for _, safe in
    {
        { 320, 480 },
        { 360, 640 },
        { 568, 300 },
        { 640, 320 },
        { 768, 1024 },
        { 1024, 768 },
        { 1920, 1080 },
    }
do
    for _, symbols in { 4, 6 } do
        local layout = Layout.measure(safe[1] - 16, safe[2] - 16, symbols)
        expect(layout.cellWidth >= 64 and layout.cellHeight >= 64, "Minimum 64px symbol targets")
        expect(layout.width + 16 <= safe[1], "Layout inside safe width")
        expect(layout.gridY + 152 <= layout.height, "Two rows of choices fit content")
    end
end
print(
    string.format(
        "PASS: %d Don't Match Me assertions; %d seeded rounds plus %d replay rounds; 1/2/4/8/12/16 humans; 1,875 exhaustive scoring configurations.",
        checks,
        simulated,
        replayed
    )
)
print(
    "PASS: bot privacy/commitment, exact deadlines, frozen rosters, reconnects, ties, rematches, rate limits and client acknowledgement recovery."
)
print(
    "NOT VERIFIED: actual Roblox services/remotes/input/rendering, Studio/device performance, mobile feel, first-action timing or fun."
)
