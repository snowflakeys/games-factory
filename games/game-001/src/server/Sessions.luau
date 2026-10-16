--!strict
return function(Run, Generator)
    local Sessions = {}
    Sessions.__index = Sessions

    local function validIntent(intent)
        if type(intent) ~= "table" then
            return false
        end
        local action = intent.action
        if action ~= "sync" and action ~= "place" and action ~= "restart" then
            return false
        end
        for key in intent do
            if
                key ~= "action"
                and not (action ~= "sync" and (key == "runId" or key == "turn"))
                and not (action == "place" and key == "cell")
            then
                return false
            end
        end
        if action ~= "sync" then
            if
                type(intent.runId) ~= "string"
                or #intent.runId > 64
                or type(intent.turn) ~= "number"
                or intent.turn % 1 ~= 0
            then
                return false
            end
        end
        return true
    end

    function Sessions.new(newId, nextSeed)
        return setmetatable({ players = {}, newId = newId, nextSeed = nextSeed }, Sessions)
    end

    function Sessions:join(playerId, now)
        if not self.players[playerId] then
            self.players[playerId] = {
                run = Run.new(self.newId(), Generator.generate(self.nextSeed())),
                budget = 8,
                updated = now,
            }
        end
        return Run.snapshot(self.players[playerId].run)
    end

    function Sessions:remove(playerId)
        self.players[playerId] = nil
    end

    function Sessions:handle(playerId, intent, now)
        local entry = self.players[playerId]
        if not entry then
            return nil
        end
        entry.budget = math.min(8, entry.budget + math.max(0, now - entry.updated) * 4)
        entry.updated = math.max(now, entry.updated)
        if entry.budget < 1 then
            -- Drop excess traffic. Client timeout does a read-only sync, never repeats placement.
            return nil
        end
        entry.budget -= 1
        local code, errors = "malformed", {}
        if validIntent(intent) then
            if intent.action == "sync" then
                code = "synced"
            elseif intent.action == "place" then
                code, errors = Run.place(entry.run, intent)
            elseif intent.action == "restart" then
                if intent.runId ~= entry.run.id or intent.turn ~= entry.run.turn then
                    code = "stale"
                elseif entry.run.status == "playing" then
                    code = "not_finished"
                else
                    entry.run = Run.new(self.newId(), Generator.generate(self.nextSeed()))
                    code = "restarted"
                end
            end
        end
        return { code = code, errors = errors, state = Run.snapshot(entry.run) }
    end

    return Sessions
end
