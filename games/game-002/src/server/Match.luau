--!strict
return function(Rules, Bot)
    local Match = {}
    Match.__index = Match

    local function count(values)
        local total = 0
        for _ in values do
            total += 1
        end
        return total
    end
    local function humanRecord(id, name, joinedRound)
        return {
            id = id,
            name = name,
            bot = false,
            score = 0,
            played = 0,
            connected = true,
            joinedRound = joinedRound,
        }
    end
    local function validIntent(intent)
        if type(intent) ~= "table" then
            return false
        end
        local action = intent.action
        if action ~= "sync" and action ~= "choose" and action ~= "ready" then
            return false
        end
        for key in intent do
            if
                key ~= "action"
                and not (action ~= "sync" and (key == "matchId" or key == "roundId"))
                and not (action == "choose" and key == "choiceId")
            then
                return false
            end
        end
        if action ~= "sync" then
            if
                type(intent.matchId) ~= "string"
                or #intent.matchId > 80
                or type(intent.roundId) ~= "string"
                or #intent.roundId > 80
            then
                return false
            end
        end
        if
            action == "choose" and (type(intent.choiceId) ~= "number" or intent.choiceId % 1 ~= 0)
        then
            return false
        end
        return true
    end

    function Match.new(newId, nextSeed)
        return setmetatable({
            newId = newId,
            nextSeed = nextSeed,
            humans = {},
            records = {},
            phase = "paused",
            revision = 0,
            now = 0,
            deadline = 0,
            round = 0,
            roster = {},
            rosterSet = {},
            choices = {},
            ready = {},
            winners = {},
            history = {},
            legal = {},
            counts = {},
            delta = {},
            matchId = "",
            roundId = "",
        }, Match)
    end
    function Match:_changed()
        self.revision += 1
    end
    function Match:_startMatch(at)
        self.matchId, self.roundId = self.newId(), ""
        self.seed = self.nextSeed()
        self.round, self.phase, self.deadline = 0, "starting", at + 1
        self.records, self.history, self.ready, self.winners = {}, {}, {}, {}
        self.roster, self.rosterSet, self.choices, self.counts, self.delta = {}, {}, {}, {}, {}
        self.choiceDeadline, self.resultsDeadline = 0, 0
        self.modifier = Rules.schedule[1]
        self.legal = Rules.legal(math.max(4, count(self.humans)))
        for id, name in self.humans do
            self.records[id] = humanRecord(id, name, 1)
        end
        self:_changed()
    end
    function Match:_beginRound(at)
        self.round += 1
        self.roundId = self.matchId .. ":r" .. self.round
        self.phase, self.deadline, self.choiceDeadline = "choosing", at + 6, at + 6
        self.modifier = Rules.schedule[self.round]
        self.roster, self.rosterSet, self.choices, self.counts, self.delta = {}, {}, {}, {}, {}
        for id in self.humans do
            table.insert(self.roster, id)
        end
        table.sort(self.roster)
        local humans = #self.roster
        for _, record in self.records do
            if record.bot then
                record.connected = false
            end
        end
        self.legal = Rules.legal(math.max(4, humans))
        for bot = 1, math.max(0, 4 - humans) do
            local id = "bot:" .. bot
            if not self.records[id] then
                self.records[id] = {
                    id = id,
                    name = "Bot " .. bot,
                    bot = true,
                    score = 0,
                    played = 0,
                    connected = true,
                    joinedRound = self.round,
                }
            end
            self.records[id].connected = true
            table.insert(self.roster, id)
            self.choices[id] = Bot.choose(
                (self.seed + self.round * 7919 + bot * 104729) % 2147483646,
                table.clone(self.legal),
                self.modifier,
                Rules.copyHistory(self.history)
            )
        end
        for _, id in self.roster do
            self.rosterSet[id] = true
        end
        self:_changed()
    end
    function Match:_resolve(at)
        local result = Rules.resolve(self.roster, self.choices, self.legal, self.modifier)
        self.counts, self.delta = result.counts, result.awards
        for _, id in self.roster do
            local record = self.records[id]
            record.score += result.awards[id]
            if self.choices[id] then
                record.played += 1
            end
        end
        table.insert(
            self.history,
            { modifier = self.modifier, counts = table.clone(result.counts) }
        )
        self.phase, self.deadline = "reveal", at + 2
        self:_changed()
    end
    function Match:_results(at)
        self.phase, self.deadline, self.resultsDeadline = "results", at + 6, at + 6
        self.ready = {}
        self.winners = Rules.winners(self.records)
        self:_changed()
    end
    function Match:_refreshReady(now)
        local all = count(self.humans) > 0
        for id in self.humans do
            if not self.ready[id] then
                all = false
            end
        end
        if all then
            self.deadline = math.min(self.deadline, self.resultsDeadline, now + 1)
        else
            self.deadline = self.resultsDeadline
        end
    end
    function Match:advance(now)
        assert(
            type(now) == "number" and now == now and math.abs(now) < math.huge,
            "Finite server clock required"
        )
        self.now = math.max(self.now, now)
        -- Bound catch-up work after a server hitch. Later ticks continue overdue phases.
        for _ = 1, 64 do
            if self.phase == "paused" or self.now < self.deadline then
                break
            end
            local at = self.deadline
            if self.phase == "starting" or self.phase == "intermission" then
                self:_beginRound(at)
            elseif self.phase == "choosing" then
                self:_resolve(at)
            elseif self.phase == "reveal" then
                if self.round == 8 then
                    self:_results(at)
                else
                    self.phase, self.deadline = "intermission", at + 1
                    self:_changed()
                end
            elseif self.phase == "results" then
                self:_startMatch(at)
            else
                error("Unknown match phase")
            end
        end
    end
    function Match:join(id, name, now)
        self:advance(now)
        if self.humans[id] then
            return true
        end
        if count(self.humans) >= 16 then
            return false
        end
        self.humans[id] = name
        if self.phase == "paused" then
            self:_startMatch(self.now)
        else
            if not self.records[id] then
                self.records[id] = humanRecord(id, name, self.round + 1)
            end
            self.records[id].connected, self.records[id].name = true, name
            self.ready[id] = nil
            if self.phase == "results" then
                self:_refreshReady(self.now)
            end
            self:_changed()
        end
        return true
    end
    function Match:leave(id, now)
        self:advance(now)
        if not self.humans[id] then
            return
        end
        self.humans[id], self.ready[id] = nil, nil
        local record = self.records[id]
        if record then
            record.connected = false
            -- Never retain people who left without entering any round.
            if record.played == 0 and not self.rosterSet[id] then
                self.records[id] = nil
            end
        end
        if count(self.humans) == 0 then
            self.phase, self.matchId, self.roundId = "paused", "", ""
            self.round, self.deadline, self.seed = 0, 0, nil
            self.records, self.history, self.ready, self.winners = {}, {}, {}, {}
            self.roster, self.rosterSet, self.choices, self.counts, self.delta = {}, {}, {}, {}, {}
        elseif self.phase == "results" then
            self:_refreshReady(self.now)
        end
        self:_changed()
    end
    function Match:apply(id, intent, now)
        if not self.humans[id] then
            return "not_connected"
        end
        if not validIntent(intent) then
            return "malformed"
        end
        self:advance(now)
        if intent.action == "sync" then
            return "synced"
        end
        if intent.matchId ~= self.matchId or intent.roundId ~= self.roundId then
            return "stale"
        end
        if intent.action == "ready" then
            if self.phase ~= "results" then
                return "not_results"
            end
            if self.ready[id] then
                return "duplicate"
            end
            self.ready[id] = true
            self:_refreshReady(self.now)
            self:_changed()
            return "ready"
        end
        if not self.rosterSet[id] then
            return "not_participating"
        end
        if intent.choiceId < 1 or intent.choiceId > #self.legal then
            return "out_of_range"
        end
        if self.phase ~= "choosing" or self.now >= self.choiceDeadline then
            return "late"
        end
        if self.choices[id] then
            return "duplicate"
        end
        self.choices[id] = intent.choiceId
        self:_changed()
        return "locked"
    end
    function Match:snapshot(viewer)
        if not self.humans[viewer] then
            return nil
        end
        local reveal = self.phase == "reveal" or self.phase == "results"
        local winners, standings = {}, {}
        for _, id in self.winners do
            winners[id] = true
        end
        for id, record in self.records do
            table.insert(standings, {
                id = id,
                name = record.name,
                bot = record.bot,
                score = record.score,
                played = record.played,
                connected = record.connected,
                joinedRound = record.joinedRound,
                active = self.rosterSet[id] == true,
                choiceId = if reveal and self.rosterSet[id]
                    then self.choices[id] or false
                    else false,
                points = if reveal then self.delta[id] or 0 else 0,
                winner = winners[id] == true,
            })
        end
        table.sort(standings, function(a, b)
            return if a.score == b.score then a.id < b.id else a.score > b.score
        end)
        local ownRank, lastScore, rank = 0, -1, 0
        for index, record in standings do
            if record.score ~= lastScore then
                rank, lastScore = index, record.score
            end
            record.rank = rank
            if record.id == viewer then
                ownRank = rank
            end
        end
        local readyCount = 0
        for id in self.humans do
            if self.ready[id] then
                readyCount += 1
            end
        end
        local nextChoiceAt = self.deadline
        if self.phase == "choosing" then
            nextChoiceAt += if self.round == 8 then 9 else 3
        elseif self.phase == "reveal" then
            nextChoiceAt += if self.round == 8 then 7 else 1
        elseif self.phase == "results" then
            nextChoiceAt += 1
        end
        return {
            revision = self.revision,
            phase = self.phase,
            matchId = self.matchId,
            roundId = self.roundId,
            round = self.round,
            deadline = self.deadline,
            nextChoiceAt = nextChoiceAt,
            modifier = self.modifier,
            symbols = table.clone(self.legal),
            lockedCount = count(self.choices),
            rosterCount = #self.roster,
            humanCount = count(self.humans),
            readyCount = readyCount,
            counts = if reveal then table.clone(self.counts) else {},
            standings = standings,
            winners = table.clone(self.winners),
            you = {
                id = viewer,
                score = self.records[viewer].score,
                rank = ownRank,
                participating = self.rosterSet[viewer] == true,
                choiceId = self.choices[viewer] or false,
                ready = self.ready[viewer] == true,
                joinedRound = self.records[viewer].joinedRound,
            },
        }
    end
    return Match
end
