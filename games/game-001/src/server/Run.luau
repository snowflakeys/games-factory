--!strict
return function(Rules)
    local Run = {}

    function Run.new(id, puzzle)
        return {
            id = id,
            puzzle = puzzle,
            board = Rules.emptyBoard(),
            placed = 0,
            turn = 1,
            score = 0,
            strikes = 0,
            status = "playing",
            reason = "",
            active = Rules.active(puzzle.order, 0),
            revision = 0,
        }
    end

    function Run.snapshot(run)
        return {
            runId = run.id,
            turn = run.turn,
            revision = run.revision,
            board = Rules.copyBoard(run.board),
            active = table.clone(run.active),
            nextToken = if run.status == "playing"
                then Rules.copyToken(run.puzzle.tokens[run.placed + 1])
                else false,
            score = run.score,
            placed = run.placed,
            strikes = run.strikes,
            status = run.status,
            reason = run.reason,
        }
    end

    function Run.place(run, intent)
        if
            type(intent) ~= "table"
            or intent.action ~= "place"
            or type(intent.runId) ~= "string"
            or type(intent.turn) ~= "number"
            or intent.turn % 1 ~= 0
            or type(intent.cell) ~= "number"
            or intent.cell % 1 ~= 0
        then
            return "malformed", {}
        end
        for key in intent do
            if key ~= "runId" and key ~= "turn" and key ~= "cell" and key ~= "action" then
                return "malformed", {}
            end
        end
        if intent.cell < 1 or intent.cell > 16 then
            return "out_of_range", {}
        end
        if intent.runId ~= run.id or intent.turn ~= run.turn then
            return "stale", {}
        end
        if run.status ~= "playing" then
            return "finished", {}
        end
        local errors =
            Rules.violations(run.board, run.puzzle.tokens[run.placed + 1], intent.cell, run.active)
        -- Advance the intent counter even for a strike so retries can never strike twice.
        run.turn += 1
        run.revision += 1
        if #errors > 0 then
            run.strikes += 1
            if run.strikes == 2 then
                run.status, run.reason = "lost", "Two rule breaks. Try a fresh board!"
            end
            return "illegal", errors
        end
        run.board[intent.cell] = Rules.copyToken(run.puzzle.tokens[run.placed + 1])
        run.placed += 1
        run.score = run.placed * 10
        if run.placed == 16 then
            run.status, run.reason = "won", "All 16 cells filled!"
        else
            local nextActive = Rules.active(run.puzzle.order, run.placed)
            -- Safe-prefix generation guarantees this for arbitrary accepted player moves.
            assert(
                Rules.validBoard(run.board, nextActive),
                "New rule contradicts earlier placements"
            )
            run.active = nextActive
            if #Rules.available(run.board, run.puzzle.tokens[run.placed + 1], run.active) == 0 then
                run.status, run.reason = "lost", "The next token has no legal cell. Try a new path!"
            end
        end
        return "accepted", {}
    end

    return table.freeze(Run)
end
