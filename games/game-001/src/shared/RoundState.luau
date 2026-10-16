--!strict

export type Phase = "Waiting" | "Intermission" | "Playing" | "Results"

local nextPhases: { [Phase]: Phase } = {
    Waiting = "Intermission",
    Intermission = "Playing",
    Playing = "Results",
    Results = "Waiting",
}

local RoundState = {}

function RoundState.canTransition(currentPhase: Phase, nextPhase: Phase): boolean
    local expectedPhase = nextPhases[currentPhase]
    return expectedPhase ~= nil and expectedPhase == nextPhase
end

function RoundState.transition(currentPhase: Phase, nextPhase: Phase): Phase
    assert(
        RoundState.canTransition(currentPhase, nextPhase),
        string.format("Illegal round transition: %s -> %s", currentPhase, nextPhase)
    )
    return nextPhase
end

return table.freeze(RoundState)
