--!strict
-- Dependency injection keeps this module runnable in both Lune and Roblox.
return function(Rules)
    local Generator = { version = 1, fallbackSeed = 104729, maxAttempts = 8, tokenAttempts = 24 }

    -- Park-Miller arithmetic is exact inside double's integer precision on both runtimes.
    local function randomSource(seed)
        local state = math.floor(seed) % 2147483646 + 1
        return function(maximum)
            state = (state * 16807) % 2147483647
            return state % maximum + 1
        end
    end

    local function shuffled(values, random)
        local copy = table.clone(values)
        for index = #copy, 2, -1 do
            local other = random(index)
            copy[index], copy[other] = copy[other], copy[index]
        end
        return copy
    end

    -- Until a rule arrives, omit its triggering attribute. Thus ANY earlier player
    -- choices, not only the witness, remain compatible when the rule is activated.
    local function safeBeforeActivation(token, order, count)
        for index = count + 1, 4 do
            local id = order[index]
            if
                (id == "red_touch" and token.color == "red")
                or (id == "star_edge" and token.shape == "star")
                or (id == "blue_corner" and token.color == "blue")
                or (id == "yellow_green" and token.color == "yellow")
                or (id == "odd_left" and token.number % 2 == 1)
                or (id == "triangle_column" and token.shape == "triangle")
            then
                return false
            end
        end
        return true
    end

    function Generator.validate(puzzle)
        if #puzzle.tokens ~= 16 or #puzzle.witness ~= 16 or #puzzle.order ~= 4 then
            return false
        end
        local seenRules = {}
        for _, id in puzzle.order do
            if not Rules.text[id] or seenRules[id] then
                return false
            end
            seenRules[id] = true
        end
        local board = Rules.emptyBoard()
        for turn = 1, 16 do
            local active = Rules.active(puzzle.order, turn - 1)
            local token, cell = puzzle.tokens[turn], puzzle.witness[turn]
            if
                not safeBeforeActivation(token, puzzle.order, #active)
                or not Rules.validBoard(board, active)
                or #Rules.violations(board, token, cell, active) > 0
            then
                return false
            end
            board[cell] = token
            if not Rules.validBoard(board, Rules.active(puzzle.order, turn)) then
                return false
            end
        end
        return true
    end

    local function attempt(seed, random)
        local order = shuffled(Rules.ids, random)
        while #order > 4 do
            table.remove(order)
        end
        local cells = {}
        for cell = 1, 16 do
            cells[cell] = cell
        end
        local puzzle = {
            seed = seed,
            version = Generator.version,
            order = order,
            witness = shuffled(cells, random),
            tokens = {},
        }
        local board = Rules.emptyBoard()
        for turn = 1, 16 do
            local active = Rules.active(order, turn - 1)
            local chosen = nil
            for _ = 1, Generator.tokenAttempts do
                local token = {
                    color = Rules.colors[random(4)],
                    shape = Rules.shapes[random(3)],
                    number = random(4),
                }
                if
                    safeBeforeActivation(token, order, #active)
                    and #Rules.violations(board, token, puzzle.witness[turn], active) == 0
                then
                    chosen = token
                    break
                end
            end
            if not chosen then
                return nil
            end
            puzzle.tokens[turn] = chosen
            board[puzzle.witness[turn]] = chosen
        end
        return if Generator.validate(puzzle) then puzzle else nil
    end

    -- Versioned, literal known-solvable seed. No random retry or search in fallback.
    function Generator.fallback()
        local puzzle = {
            seed = Generator.fallbackSeed,
            version = 1,
            order = { "red_touch", "star_edge", "blue_corner", "odd_left" },
            witness = {},
            tokens = {},
        }
        for cell = 1, 16 do
            puzzle.witness[cell] = cell
            puzzle.tokens[cell] = { color = "green", shape = "circle", number = 2 }
        end
        puzzle.tokens[5] = { color = "yellow", shape = "star", number = 4 }
        puzzle.tokens[9] = { color = "red", shape = "triangle", number = 2 }
        puzzle.tokens[13] = { color = "yellow", shape = "star", number = 1 }
        puzzle.tokens[14] = { color = "blue", shape = "triangle", number = 3 }
        assert(Generator.validate(puzzle), "Versioned fallback must remain solvable")
        return puzzle
    end

    function Generator.generate(seed, attemptLimit)
        assert(
            type(seed) == "number" and seed == seed and math.abs(seed) < math.huge,
            "Finite seed required"
        )
        local limit = math.clamp(attemptLimit or Generator.maxAttempts, 0, Generator.maxAttempts)
        local random = randomSource(seed)
        for attemptNumber = 1, limit do
            local puzzle = attempt(seed, random)
            if puzzle then
                puzzle.generation =
                    { requestedSeed = seed, attempts = attemptNumber, fallback = false }
                return puzzle
            end
        end
        local puzzle = Generator.fallback()
        puzzle.generation = { requestedSeed = seed, attempts = limit, fallback = true }
        return puzzle
    end

    return table.freeze(Generator)
end
