--!strict

local RoundState = require("../src/shared/RoundState")

local phases: { RoundState.Phase } = { "Waiting", "Intermission", "Playing", "Results" }
local expectedNext: { [RoundState.Phase]: RoundState.Phase } = {
    Waiting = "Intermission",
    Intermission = "Playing",
    Playing = "Results",
    Results = "Waiting",
}

local checks = 0

for _, currentPhase in phases do
    for _, nextPhase in phases do
        local expected = expectedNext[currentPhase] == nextPhase
        assert(
            RoundState.canTransition(currentPhase, nextPhase) == expected,
            "Incorrect transition permission"
        )

        local succeeded, result = pcall(function()
            return RoundState.transition(currentPhase, nextPhase)
        end)

        assert(
            succeeded == expected,
            "Illegal transitions must fail and legal transitions must succeed"
        )
        if expected then
            assert(result == nextPhase, "A legal transition must return the requested phase")
        else
            assert(
                string.find(tostring(result), "Illegal round transition", 1, true),
                "Expected a clear rejection"
            )
        end
        checks += 3
    end
end

local phase: RoundState.Phase = "Waiting"
for _ = 1, 3 do
    phase = RoundState.transition(phase, "Intermission")
    phase = RoundState.transition(phase, "Playing")
    phase = RoundState.transition(phase, "Results")
    phase = RoundState.transition(phase, "Waiting")
    assert(phase == "Waiting", "Each full cycle must return to Waiting")
    checks += 1
end

print(string.format("PASS: %d round-state checks", checks))
