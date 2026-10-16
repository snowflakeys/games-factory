--!strict
local Rules = require("../src/shared/Rules")
local Layout = require("../src/shared/Layout")
local SeededRandom = require("../src/server/Systems/SeededRandom")
local TokenBucket = require("../src/server/Systems/TokenBucket")
local Generator = require("../src/server/Generator")(Rules, SeededRandom)
local Run = require("../src/server/Run")(Rules)
local Sessions = require("../src/server/Sessions")(Run, Generator, TokenBucket)
local checks = 0
local function expect(condition, message)
    assert(condition, message)
    checks += 1
end
local function token(color, shape, number)
    return { color = color or "green", shape = shape or "circle", number = number or 2 }
end
local function legal(board, item, cell, id)
    return #Rules.violations(board, item, cell, { id }) == 0
end
local function intent(run, cell)
    return { action = "place", runId = run.id, turn = run.turn, cell = cell }
end
local function fingerprint(puzzle)
    local parts =
        { tostring(puzzle.seed), tostring(puzzle.version), table.concat(puzzle.order, ",") }
    for turn = 1, 16 do
        local item = puzzle.tokens[turn]
        table.insert(parts, item.color .. item.shape .. item.number .. ":" .. puzzle.witness[turn])
    end
    return table.concat(parts, "|")
end
-- Golden outputs captured from the pre-extraction implementation, independent of shared code.
for _, fixture in require("./generator-v1-fixtures") do
    expect(
        fingerprint(Generator.generate(fixture.seed)) == fixture.fingerprint,
        "Original seeded puzzle preserved"
    )
end
local function unchanged(run, before, message)
    local after = Run.snapshot(run)
    expect(
        after.turn == before.turn
            and after.revision == before.revision
            and after.score == before.score
            and after.placed == before.placed
            and after.strikes == before.strikes
            and after.status == before.status,
        message
    )
    for cell = 1, 16 do
        expect((after.board[cell] ~= false) == (before.board[cell] ~= false), message .. " board")
    end
end

-- Each predicate, boundary and symmetric pair, independent of the generator.
local board = Rules.emptyBoard()
board[6] = token("red")
for cell = 1, 16 do
    local row, column = Rules.coordinates(cell)
    local edge = row == 1 or row == 4 or column == 1 or column == 4
    local corner = (row == 1 or row == 4) and (column == 1 or column == 4)
    if cell ~= 6 then
        expect(
            legal(board, token("red"), cell, "red_touch")
                == (math.abs(row - 2) + math.abs(column - 2) ~= 1),
            "Red orthogonal only"
        )
        expect(legal(board, token("blue"), cell, "blue_corner") == not corner, "Blue corner")
        expect(legal(board, token("yellow", "star"), cell, "star_edge") == edge, "Star edge")
        expect(
            legal(board, token("green", "circle", 1), cell, "odd_left") == (column <= 2),
            "Odd left"
        )
        expect(legal(board, token("green", "circle", 4), cell, "odd_left"), "Even anywhere")
    end
end
for _, pair in { { "yellow", "green" }, { "green", "yellow" } } do
    board = Rules.emptyBoard()
    board[5] = token(pair[1])
    expect(not legal(board, token(pair[2]), 8, "yellow_green"), "Row colors reject in either order")
    expect(legal(board, token(pair[2]), 1, "yellow_green"), "Row colors allow another row")
    board[8] = token(pair[2])
    expect(not Rules.validBoard(board, { "yellow_green" }), "Whole board detects incompatible rule")
end
board = Rules.emptyBoard()
board[2] = token("green", "triangle")
expect(not legal(board, token("red", "triangle"), 14, "triangle_column"), "Triangle same column")
expect(legal(board, token("red", "triangle"), 15, "triangle_column"), "Triangle different column")
expect(legal(board, token("red", "star"), 14, "triangle_column"), "Other shape same column")
expect(#Rules.violations(board, token(), 2, {}) == 1, "Occupied cell illegal")
expect(#Rules.violations(board, token(), 17, {}) == 1, "Outside board illegal preview")
expect(#Rules.available(Rules.emptyBoard(), token(), {}) == 16, "Available all cells")
expect(
    #Rules.available(Rules.emptyBoard(), token("red", "star", 1), { "star_edge", "odd_left" }) == 6,
    "Combined rule intersection"
)

local seen, fallbackCount, maxAttempts, exhausted = {}, 0, 0, 0
for seed = 1, 1000 do
    local puzzle = Generator.generate(seed)
    expect(Generator.validate(puzzle), "Validated full witness seed " .. seed)
    expect(
        fingerprint(puzzle) == fingerprint(Generator.generate(seed)),
        "Deterministic seed replay " .. seed
    )
    expect(puzzle.generation.attempts <= Generator.maxAttempts, "Generation attempt bound")
    maxAttempts = math.max(maxAttempts, puzzle.generation.attempts)
    if puzzle.generation.fallback then
        fallbackCount += 1
        expect(puzzle.seed == Generator.fallbackSeed, "Fallback uses known seed")
    end
    for _, id in puzzle.order do
        seen[id] = true
    end
    local run = Run.new("seed-" .. seed, puzzle)
    for turn = 1, 16 do
        expect(
            #run.active == math.min(4, 1 + math.floor((turn - 1) / 4)),
            "Rule activates at accepted 4/8/12"
        )
        expect(Rules.validBoard(run.board, run.active), "Existing board compatible at stage")
        local code = Run.place(run, intent(run, puzzle.witness[turn]))
        expect(code == "accepted", "Witness move accepted seed " .. seed .. " turn " .. turn)
        expect(run.score == turn * 10 and run.strikes == 0, "Witness scoring")
    end
    expect(run.status == "won" and run.score == 160, "Exact victory")
    local before = Run.snapshot(run)
    expect(Run.place(run, intent(run, 1)) == "finished", "Terminal result immutable")
    unchanged(run, before, "Terminal cannot score again")
    if seed <= 100 and Generator.generate(seed, 1).generation.fallback then
        exhausted += 1
    end
end
for _, id in Rules.ids do
    expect(seen[id], "All six predicates appear in generated runs")
end
expect(exhausted > 0, "Real bounded-attempt exhaustion exercised")
local forced = Generator.generate(999, 0)
expect(
    forced.generation.fallback and forced.generation.attempts == 0,
    "Zero budget uses fallback immediately"
)
expect(fingerprint(forced) == fingerprint(Generator.fallback()), "Versioned literal fallback")
local corrupted = Generator.fallback()
corrupted.witness[2] = corrupted.witness[1]
expect(not Generator.validate(corrupted), "Witness validator rejects repeated cell")
corrupted = Generator.fallback()
corrupted.tokens[1].shape = "star"
expect(not Generator.validate(corrupted), "Witness validator rejects unsafe pre-activation token")
expect(not pcall(function()
    Generator.generate(0 / 0)
end), "NaN seed rejected")

-- Alternative legal player choices can lose to a dead end but never break new rules.
local branchLosses = 0
for seed = 1, 200 do
    local run = Run.new("branch", Generator.generate(seed))
    while run.status == "playing" do
        local options = Rules.available(run.board, run.puzzle.tokens[run.placed + 1], run.active)
        expect(#options > 0, "Playing state always has a move")
        local cell = options[(seed + run.placed * 7) % #options + 1]
        expect(Run.place(run, intent(run, cell)) == "accepted", "Alternative legal path accepted")
        expect(
            Rules.validBoard(run.board, run.active),
            "New rules compatible with arbitrary earlier legal choices"
        )
        if run.status == "lost" then
            branchLosses += 1
            expect(
                #Rules.available(run.board, run.puzzle.tokens[run.placed + 1], run.active) == 0,
                "Dead-end loss justified by actual search"
            )
        end
    end
end
expect(branchLosses > 0, "Player-created dead ends covered")

local run = Run.new("validation", Generator.fallback())
local malformed = {
    false,
    "hello",
    42,
    {},
    { action = "place" },
    { runId = run.id, turn = 1, cell = "1" },
    { runId = run.id, turn = 1, cell = 1.5 },
    { runId = run.id, turn = 1, cell = 0 / 0 },
    { runId = run.id, turn = 1, cell = math.huge },
    { runId = run.id, turn = math.huge, cell = 1 },
    { runId = run.id, turn = "1", cell = 1 },
    { runId = run.id, turn = 1, cell = 1, score = 99999 },
    { runId = run.id, turn = 1, cell = 0 },
    { runId = run.id, turn = 1, cell = 17 },
    { runId = "old-run", turn = 1, cell = 1 },
    { runId = run.id, turn = 0, cell = 1 },
    { runId = run.id, turn = 2, cell = 1 },
}
for _, bad in malformed do
    if type(bad) == "table" and bad.runId then
        bad.action = "place"
    end
    local before = Run.snapshot(run)
    local code = Run.place(run, bad)
    expect(
        code ~= "accepted" and code ~= "illegal",
        "Transport-invalid input is not a puzzle strike"
    )
    unchanged(run, before, "Malformed/stale/out-of-range cannot mutate")
end
local first = intent(run, 1)
expect(Run.place(run, first) == "accepted", "First legal placement")
local before = Run.snapshot(run)
expect(Run.place(run, first) == "stale", "Duplicate accepted request rejected")
unchanged(run, before, "Duplicate no rewards/strikes")
local strike = intent(run, 1)
expect(
    Run.place(run, strike) == "illegal" and run.strikes == 1 and run.score == 10,
    "Occupied cell costs one strike, no score"
)
before = Run.snapshot(run)
expect(Run.place(run, strike) == "stale", "Duplicate illegal request rejected")
unchanged(run, before, "Duplicate no second strike")
expect(
    Run.place(run, intent(run, 1)) == "illegal" and run.status == "lost" and run.strikes == 2,
    "Two distinct illegal placements lose"
)
expect(run.score == 10, "Strike loss preserves earned score")
local snapshot = Run.snapshot(run)
expect(
    snapshot.puzzle == nil
        and snapshot.seed == nil
        and snapshot.witness == nil
        and snapshot.tokens == nil,
    "Snapshot never exposes hidden puzzle"
)
snapshot.board[1].color = "blue"
snapshot.active[1] = "odd_left"
expect(
    run.board[1].color == "green" and run.active[1] == "red_touch",
    "Snapshot has no mutable aliases"
)

local serial = 0
local sessions = Sessions.new(function()
    serial += 1
    return "run-" .. serial
end, function()
    return 1
end)
local a = sessions:join(100, 0)
local b = sessions:join(200, 0)
expect(a.runId ~= b.runId, "Independent player run IDs")
local underlying = sessions.players[100].run
local cell = underlying.puzzle.witness[1]
local response = sessions:handle(100, intent(underlying, cell), 1)
expect(
    response.code == "accepted" and response.state.score == 10,
    "Session delegates authoritative placement"
)
expect(sessions.players[200].run.score == 0, "Other player's board unaffected")
expect(sessions:join(100, 2).score == 10, "Join/respawn rehydrates existing run")
expect(
    sessions:handle(100, { action = "sync" }, 2).state.score == 10,
    "Read-only sync retains board"
)
local oldId = underlying.id
expect(
    sessions:handle(100, { action = "restart", runId = oldId, turn = underlying.turn }, 3).code
        == "not_finished",
    "Restart only after outcome"
)
expect(
    sessions:handle(100, { action = "restart", runId = oldId, turn = 0 }, 4).code == "stale",
    "Stale restart rejected"
)
sessions:handle(100, intent(underlying, cell), 5)
sessions:handle(100, intent(underlying, cell), 6)
local restartIntent = { action = "restart", runId = oldId, turn = underlying.turn }
response = sessions:handle(100, restartIntent, 7)
expect(
    response.code == "restarted"
        and response.state.runId ~= oldId
        and response.state.score == 0
        and response.state.strikes == 0
        and response.state.status == "playing",
    "Fresh run on restart"
)
local newId = response.state.runId
expect(
    sessions:handle(100, restartIntent, 8).code == "stale",
    "Duplicate restart cannot reset fresh run"
)
expect(sessions.players[100].run.id == newId, "Duplicate restart preserves fresh ID")
expect(
    sessions:handle(100, { action = "place", runId = oldId, turn = 1, cell = 2 }, 9).code == "stale",
    "Late prior-run placement"
)
sessions:remove(100)
expect(sessions:handle(100, { action = "sync" }, 10) == nil, "Disconnect has no active run")
expect(sessions:join(100, 10).runId ~= newId, "Reconnect begins new ephemeral run")
local rateRun = sessions.players[100].run
before = Run.snapshot(rateRun)
for _ = 1, 8 do
    expect(
        sessions:handle(100, false, 10).code == "malformed",
        "Invalid traffic counts against limit"
    )
end
for _ = 1, 100 do
    expect(
        sessions:handle(100, intent(rateRun, rateRun.puzzle.witness[1]), 10) == nil,
        "Over-rate placement dropped"
    )
end
unchanged(rateRun, before, "Over-rate has no score/strike impact")
expect(sessions:handle(200, { action = "sync" }, 10) ~= nil, "Rate limit isolated per player")
expect(
    sessions:handle(100, { action = "sync" }, 10.25).code == "synced",
    "Limiter refills and timeout sync can recover"
)

-- Session-level schema checks cover sync and restart as well as placement.
for index, bad in
    {
        { action = "sync", score = 10 },
        { action = "restart" },
        { action = "restart", runId = rateRun.id, turn = rateRun.turn, cell = 1 },
        { action = "restart", runId = rateRun.id, turn = 0 / 0 },
        { action = "award", score = 160 },
        { action = "place", runId = string.rep("x", 65), turn = 1, cell = 1 },
    }
do
    before = Run.snapshot(rateRun)
    expect(
        sessions:handle(100, bad, 11 + index).code == "malformed",
        "All action schemas validated"
    )
    unchanged(rateRun, before, "Malformed action no state change")
end
-- Independent solo runs at the factory's preferred 16+ population.
for player = 1, 20 do
    sessions:join(1000 + player, 20)
    local personal = sessions.players[1000 + player].run
    response = sessions:handle(1000 + player, intent(personal, personal.puzzle.witness[1]), 21)
    expect(
        response.state.score == 10 and response.state.placed == 1,
        "20 concurrent isolated sessions"
    )
end
before = Run.snapshot(rateRun)
expect(
    Run.place(rateRun, { action = "award", runId = rateRun.id, turn = rateRun.turn, cell = 1 })
        == "malformed",
    "Pure run checks semantic action"
)
unchanged(rateRun, before, "Wrong semantic action cannot mutate")

for _, size in
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
    local layout = Layout.measure(size[1] - 16, size[2] - 16)
    expect(layout.cell >= 48, "Board target >=48px")
    expect(layout.contentWidth + 16 <= size[1], "Content fits safe width")
    expect(layout.boardSize == layout.cell * 4 + 18, "Four cells plus three gutters")
end
print(
    string.format(
        "PASS: %d Rule Stack assertions; 1000 deterministic seed/witness replays; 200 alternative paths.",
        checks
    )
)
print(
    string.format(
        "GENERATOR v%d: normal-budget fallback %d/1000; max attempts %d/%d; single-attempt exhaustion %d/100; zero-budget fallback PASS; player dead ends %d/200.",
        Generator.version,
        fallbackCount,
        maxAttempts,
        Generator.maxAttempts,
        exhausted,
        branchLosses
    )
)
print(
    "NOT VERIFIED: Roblox services/input/rendering, Studio emulator, physical phones, latency feel or fun."
)
