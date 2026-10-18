# SeededRandom 1.0.0

Source: Rule Stack's bounded puzzle generator and Don't Match Me's public-history bots.

`SeededRandom.new(seed)` returns `draw(maximum)`, producing an integer in `[1, maximum]`. A finite seed is floored and normalized as `floor(seed) % 2147483646 + 1`. Each draw advances Park–Miller by multiplier 16807/modulus 2147483647, then reduces to the requested range. Bounds must be integers from 1 to 2147483647. This preserves both games' original seeded streams. It is a replay utility with modulo bias, not cryptographic randomness.

`SeededRandom.shuffled(array, draw)` returns a shallow shuffled copy using Fisher–Yates; neither caller array nor its values are changed. Draw ownership is explicit, with no global random state.

Pure Luau, no dependencies/services. Lune: `lune run tests/run.luau` from this directory. Tests cover reference vectors, range/replay, permutation, caller isolation and invalid inputs. Studio runtime remains an owner check.
