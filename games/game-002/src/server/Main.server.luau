--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoundState = require(ReplicatedStorage.Shared.RoundState)

assert(RoundState.canTransition("Waiting", "Intermission"), "Round-state scaffold failed")
print("Server scaffold initialized. Implement the core loop after Snow approves the spec.")
