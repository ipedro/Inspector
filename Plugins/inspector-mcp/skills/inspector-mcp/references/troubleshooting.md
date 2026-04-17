# Troubleshooting

Use this when the MCP bridge behaves unexpectedly — connection fails, snapshots stall, the client can't see the server after a code change.

## `/mcp` reports "Failed to reconnect to inspector" even though the bridge is up

Symptoms:
- `curl -s http://127.0.0.1:49321/health` returns a valid `active` response.
- The iOS Example app is running in the simulator.
- Claude Code's `/mcp` slash command keeps printing "Failed to reconnect to inspector." on every attempt.

Root cause, confirmed empirically: Claude Code caches the "failed" state of a server in the current session. `/mcp` alone prints that cached status; it does not force a fresh respawn of the wrapper. The bridge itself stays live inside the simulator app (its `NWListener` is bound to `127.0.0.1:49321` for the app's lifetime), so direct `curl /health` and manual wrapper invocations both succeed while the MCP client stays convinced it cannot reconnect.

Fix, in order:

1. `/reload-plugins` — forces Claude Code to reload every plugin MCP manifest and spawn a fresh wrapper process. This is the actual unblocker in most cases.
2. If step 1 still fails, look for stale local state before trying again:
   ```bash
   curl -s --max-time 2 http://127.0.0.1:49321/health
   pgrep -fa "InspectorMCPServer launch"
   pgrep -fa "xcodebuild.*Example"
   ```
   Kill any stray processes from earlier manual wrapper tests or abandoned xcodebuild runs:
   ```bash
   pgrep -f "InspectorMCPServer launch" | xargs -n1 kill
   pgrep -f "xcodebuild.*Example" | xargs -n1 kill
   ```
   Then rerun `/reload-plugins`.

Do not assume stale processes alone are the blocker — Claude Code's client-side cache is the more common culprit. In the debugging session that produced this note, zombie `InspectorMCPServer` and `xcodebuild` processes were present, killed, and `/mcp` still reported "Failed to reconnect" on subsequent attempts; only `/reload-plugins` actually restored the connection.

## Cold reconnect times out

Symptoms:
- Running `/mcp` immediately after an Inspector upgrade fails while the simulator app is still the old build.
- `./Tools/mcp/run-inspector-mcp.sh` invocation silently triggers a full `xcodebuild` of the Example app, which can exceed Claude Code's MCP connect timeout.

Workaround: warm the cache manually before asking Claude to reconnect:

```bash
./Tools/mcp/run-inspector-mcp.sh < /dev/null
```

That will build `InspectorMCPServer`, launch the Example app, and bring up the bridge. Once `curl /health` returns `active`, run `/mcp` reconnect — the wrapper's next invocation attaches in under a second because the launcher's initial health poll succeeds.

Then clean up the warm-up process before Claude's own spawn, per the "stale process" section above.

## Bridge shows `status: disabled` or `notStarted`

- `disabled` — the consumer app's `InspectorConfiguration.enableMCPBridge` is `false`. Enable it in the app's startup (`Inspector.setConfiguration(...)` before `Inspector.start()`). See the sibling `inspector-mcp-consumer` skill.
- `notStarted` — the app opted into the bridge but `Inspector.start()` hasn't been called yet. The launcher waits up to 15 seconds; if it still reports `notStarted`, check that the app code path actually reaches `Inspector.start()` on launch.

## `Read pngPath` returns an empty or corrupt image

Paths returned by `snapshot` live inside the simulator app sandbox under `NSTemporaryDirectory()/inspector-snapshots/`. Two cases cause the file to disappear out from under the reader:

1. **Ring-buffer eviction.** The renderer prunes files above `InspectorConfiguration.snapshotArtifactMaxCount` (default 32) on every snapshot. If an agent holds a `pngPath` for longer than a few tens of snapshots, the file may be gone. Consume paths immediately; don't cache across calls.
2. **`Inspector.stop()` or "Reset App" commands.** Both wipe the whole `inspector-snapshots/` directory. A path captured before a reset is invalid after.

If the path is gone, issue a fresh `query` → `snapshot` instead of retrying the stale path.

## `snapshot` returns `captureFailed`

The renderer funnels disk I/O and render failures through `InspectorSnapshotUnavailableReason.captureFailed`. The specific cause is logged to the app's `os_log` stream (filter on subsystem/category or just search for `inspector:` in Console.app). Common cases:

- `NSTemporaryDirectory()` is full or read-only — unusual in simulator but possible if the host disk is saturated.
- The snapshot view couldn't render its hierarchy (usually because the view is detached from a window). Confirm the handle still resolves with `resolve` first.

## Stale handle (`staleHandle`) after a screen change

Handles are tied to a `PinnedSnapshot` of the hierarchy. UIKit teardown invalidates them. There is no host-side remap; re-issue `query` to get a fresh handle, then retry `resolve` or `snapshot`.
