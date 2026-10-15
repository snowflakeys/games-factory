# Shared systems

Reusable systems live here. The **Universal Blocks Engine** is reserved for this directory; no engine implementation or tested version exists yet.

Create a shared system only when it serves an approved core loop. Do not build speculative infrastructure.

## Compatibility and pinning

- Every game records each shared dependency in its own `shared-systems.lock.json`.
- Pin an immutable version or commit, or vendor a copy into the game. For copied modules, record the source version/commit and copied paths.
- Do not use an unversioned live path that makes editing a shared module silently change older games.
- Never alter a shared module in a way that breaks games depending on its existing version. Make incompatible changes in a new version and leave the old version available.
- Upgrades are explicit per-game changes. Record the reason, update the pin, and run the affected game's required checks.
- Each implemented module needs a small usage/contract document and relevant logic tests. Avoid introducing an engine or dependency before it is needed.

The empty directory and this reservation are not evidence that the Universal Blocks Engine is available.
