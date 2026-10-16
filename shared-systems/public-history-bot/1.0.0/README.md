# PublicHistoryBot 1.0.0

Source: Don't Match Me's deterministic bots. Dependency: injected SeededRandom **1.0.0**.

Construct with `require(PublicHistoryBot)(SeededRandom)`, then call `choose(seed, legalIds, strategy, history)`. The legal IDs must be a nonempty, unique ordered array. History is an array of public resolved rounds containing `counts[id]`, with nonnegative integer counts in the normal participant range. Do not pass current choices, match state, identities or private snapshots. The caller supplies validated inputs and commits the bot choice before accepting human submissions.

`strategy="frequent"` weights each ID by its historical count plus one; `"rare"` weights it by maximum historical frequency minus its frequency plus one. Both keep unseen options possible and make one seeded weighted draw. Returns a legal ID without changing the supplied history/array. Don't Match Me maps PAIRS to frequent and other approved modifiers to rare in its own adapter; game modifiers and scoring are not shared here.

Pure Luau, no services. Lune: `lune run tests/run.luau`. Tests cover controlled weighted intervals, seeded legality/replay, opposite strategies, caller isolation, one option and invalid strategy/empty inputs. This is a bounded policy, not a claim about competitive difficulty or fun.
