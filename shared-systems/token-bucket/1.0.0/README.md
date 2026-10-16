# TokenBucket 1.0.0

Source: Rule Stack sessions (burst 8/refill 4 per second) and Don't Match Me protocol (burst 6/refill 3).

`TokenBucket.new(capacity, refillPerSecond, now)` creates a full independent bucket. Capacity is finite and at least 1, refill is positive finite, and initial time is finite. `bucket:take(now)` refills up to capacity and spends one token if available, returning a boolean. Fractional credit is retained; backward time grants no credit and never moves the last update backward. Nonfinite time is rejected without mutation.

The server adapter supplies its own trusted monotonic clock and one bucket per admitted player/session. Call `take` before parsing semantic input so malformed traffic also spends credit. Remove the owning session on leave. This is traffic throttling; game authorization and schema validation remain caller responsibilities.

Pure Luau, no dependencies/services. Lune: `lune run tests/run.luau`. Tests cover both production configurations, bursts, fractional/exact refill, clock rollback, idle cap, invalid clocks and session independence. Actual Roblox remotes need owner testing.
