# PrivateRequests 1.0.0

Source: Don't Match Me's pure controller and private server protocol.

`validPacket(packet)` accepts exactly `{requestId, intent}` with an integer ID from 1 to 2147483647 and a table intent. It does not validate the intent's game-specific schema or authorize the sender.

`new(timeoutSeconds)` creates a per-connection tracker. `tracker:packet(intent, now, context?)` allocates a fresh ID and replaces the pending request. Optional context is shallow-copied; use scalar identity/version fields. `tracker:receive(response, currentContext)` returns true and clears the gate only for `kind="ack"` with the pending ID. Broadcasts/stale acks cannot clear it. A pending action is discarded if its context fields differ from the authoritative context. `tracker:expired(now)` checks the inclusive timeout boundary without sending anything.

On timeout the caller must replace the pending action with a fresh read-only sync, never replay a mutation. The game controller owns input gating, snapshot revision ordering, error text and context selection. Send acknowledgements only to the requesting player and build their personalized snapshot server-side. Correlation alone does not provide privacy or authorization. Clock values and received responses are trusted adapter inputs. IDs never wrap: after exhausting the space, replace the connection/tracker rather than aliasing a prior request.

Pure Luau, no dependencies/services. Lune: `lune run tests/run.luau`. Tests cover strict envelopes/ID bounds, copied context, broadcasts, stale/matching acks, timeout/read-only recovery and obsolete contexts. Actual RemoteEvent behavior remains an owner check.
