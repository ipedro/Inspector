# Snapshot Disk Path — Design Spec

**Date:** 2026-04-17
**Approach:** Replace inline base64 PNG payloads with file-path references (Approach C).

## Problem

The Inspector MCP bridge `snapshot` tool currently returns rendered PNGs as base64-encoded strings inside the JSON response. A full-screen retina snapshot on an iPhone Pro (402×874 pt × 3x = 1206×2622 px) produces roughly 372 KB of PNG bytes, which base64 inflates to ≈496 k characters. Claude Code's inline tool-result budget caps at ≈25 k tokens, so the payload is saved to a side file and the agent is forced into a multi-step recovery dance: read the side file, `jq -r '.pngBase64'`, `base64 -D > /tmp/x.png`, `Read` the PNG.

The pipeline works but the cost is carried on every full-screen capture. We need a default that doesn't explode the response.

Root cause: the bridge transports PNG bytes through the JSON channel. Every other option inherits the base64 × render-scale product.

## Design

### Contract change

The MCP `snapshot` tool response stops carrying bytes. Instead it carries a host-absolute file path that the agent can hand to its local file-reading tool (Claude Code `Read`, Codex equivalent).

Before:

```json
{"handle":"X","mimeType":"image/png","pngBase64":"iVBORw0…","size":{…},"scale":3}
```

After:

```json
{"handle":"X","mimeType":"image/png","pngPath":"/Users/pedro/Library/Developer/CoreSimulator/Devices/<UDID>/data/Containers/Data/Application/<APP-UUID>/tmp/inspector-snapshots/<uuid>.png","size":{…},"deviceScale":3,"createdAt":"2026-04-17T13:03:29Z"}
```

Validated empirically (G35): Claude Code `Read` accepts simulator sandbox paths and renders PNG inline.

### File lifecycle

- **Directory:** `NSTemporaryDirectory()/inspector-snapshots/`, created lazily on first snapshot. This resolves to a real macOS host path inside the simulator's Core Simulator data dir (readable by the host).
- **Filename:** `<UUID>.png`, one file per snapshot call. No reuse, no race on concurrent calls.
- **Rotation:** ring buffer by file modification time. New config setting `InspectorConfiguration.snapshotArtifactMaxCount: Int = 32` (independent of the existing `snapshotMaxCount`, which caches pinned hierarchy snapshots and has no interaction with render artifacts — see G11 below). On each snapshot call, if the directory count exceeds the limit, oldest files are removed best-effort.
- **First call after a previous run:** the directory persists across process restarts (it lives under the simulator app sandbox, which survives app relaunch). The first snapshot call after relaunch prunes any leftover files above the limit as part of the normal rotation pass — no dedicated boot-time sweep.
- **Shutdown and reset cleanup:** `Inspector.stop()` removes the whole `inspector-snapshots/` directory. Note `Inspector.stop()` is also invoked from the Example app's "Reset App" command (`Inspector.stop(); Inspector.start()`), so any mid-session handle/path a client cached becomes invalid after reset. Clients consume paths immediately.
- **Directory path constant:** the subdirectory name `"inspector-snapshots"` is a module-private constant shared between the renderer (for write) and the cleanup helper (for removal). Resolution of the parent uses `NSTemporaryDirectory()` at call time; no path caching.
- **Crash / system wipe:** acceptable data loss. Paths are ephemeral and documented as such.

### Per-layer changes

#### `Sources/InspectorMCPWire/InspectorMCPWire.swift`

`InspectorMCPSnapshotResult`:
- Replace `pngBase64: String` with `pngPath: String`.
- Rename `scale: Double` to `deviceScale: Double`. Reserves the `scale` name for a future request-side parameter without a collision.
- Add `createdAt: Date` (ISO8601 via existing `JSONEncoder.dateEncodingStrategy = .iso8601`).

No other wire types change. The error enum `InspectorMCPSnapshotUnavailableReason` stays fixed; disk write failures reuse `.captureFailed` (see G40).

#### `Sources/Inspector/Bridge/InspectorBridgeTypes.swift`

`InspectorBridgeSnapshotArtifact`:
- Replace `pngData: Data` with `pngURL: URL`.
- Add `createdAt: Date`.
- Rename `scale` to `deviceScale` to match the wire.

Type is `public`. Source-level break is acceptable because the bridge is v1, simulator-gated (`#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)`), and the only known consumers are inside this repo. No deprecation shim.

#### `Sources/Inspector/Bridge/InspectorBridgeService.swift`

`InspectorBridgeSnapshotRenderer.snapshot(for:handle:afterScreenUpdates:)`:
1. Render `UIImage` as today.
2. Write `image.pngData()` to `NSTemporaryDirectory()/inspector-snapshots/<UUID>.png`.
3. Enforce ring buffer via a new private helper `pruneArtifacts(dir:limit:)` that sorts by `ContentModificationDateKey` and removes the oldest above the limit.
4. Return `InspectorBridgeSnapshotArtifact(handle:, pngURL:, size:, deviceScale:, createdAt:)`.

On write failure, log via `os_log(.error, "…", url, error)` and throw `InspectorBridgeError.snapshotUnavailable(.captureFailed)`.

**Concurrency note:** the renderer runs on the main thread via the existing `performOnMain(.snapshot)` serialization in `InspectorMCPBridgeService`. Disk I/O (`image.pngData()` + `Data.write(to:)` + directory listing for prune) happens on the main thread. Writes of a 370 KB PNG typically complete in tens of milliseconds on simulator; this is intentional — the synchronous path keeps error ordering deterministic and avoids introducing a dispatch hop that would complicate `throws` semantics. The bridge is simulator-only dev tooling, so brief main-thread blocks during a snapshot are acceptable.

**Config injection:** the renderer reads `snapshotArtifactMaxCount` via the same pattern `InspectorMCPBridgeService` uses for `snapshotMaxCount` (see `InspectorBridgeService.swift:431`): `Inspector.sharedInstance.configuration.snapshotArtifactMaxCount`, wrapped in a closure provider for testability — mirror the existing `snapshotLimitProvider` injection so tests can override the limit.

`InspectorMCPBridgeService.snapshot(_:afterScreenUpdates:)` signature unchanged; it still delegates to the renderer.

Add a new static helper `InspectorMCPBridgeService.cleanupArtifactsDirectory()` called from `Inspector.stop()` to remove the whole directory. Implementation reads the same module-private directory constant the renderer writes to.

#### `Sources/Inspector/Inspector.swift`

`Inspector.stop()` invokes `InspectorMCPBridgeService.cleanupArtifactsDirectory()` before existing teardown.

#### `Sources/Inspector/Configuration/InspectorConfiguration.swift`

Add `var snapshotArtifactMaxCount: Int = 32`. No impact on `snapshotMaxCount` (hierarchy handle cache) or `snapshotExpiration` (handle TTL).

#### `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift`

`bridgeSnapshotResult(for:)`:
- Map `artifact.pngURL.path` to `pngPath`.
- Map `artifact.deviceScale` to `deviceScale`.
- Map `artifact.createdAt` to `createdAt`.

No changes to `allowedKeys` for the `/snapshot` request (no new request fields).

#### `Sources/InspectorMCPServer/InspectorMCPServerSession.swift`

- Bump `serverInfo.version` from `"1.0.0"` to `"2.0.0"` in the `initialize` response.
- Update the `snapshot` tool description to: `Capture a PNG snapshot for a handle. Returns an absolute host file path — use the Read tool on pngPath to load image bytes.` (153 chars)
- Add `description` strings to every property in the `snapshot` tool's JSON schema:
  - `handle`: `Opaque handle returned by query or resolve.`
  - `afterScreenUpdates`: `Whether to flush pending view updates before capture. Default true.`

Per-field descriptions on the response object are not part of the MCP tool schema (that's the input schema); documentation of the response shape lives in the tool description and skill docs.

Add `apiVersion: Int = 2` to `InspectorMCPHealthResponse` (wire addition). Purely diagnostic — no dispatch logic keys on it. Additive wire change: `JSONDecoder` ignores unknown keys by default, so older client decoders of the old `InspectorMCPHealthResponse` type continue to decode successfully against the new JSON. New clients get the value automatically.

#### `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift` (`/health` endpoint)

Update `healthResponse()` to set `apiVersion = 2`.

### Plugin / documentation updates

Same PR updates these so the consumer-visible contract matches the runtime:

- `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md` — snapshot example shows `pngPath` + instruction to use Read on the path. Add a "restart MCP clients after upgrading Inspector" note under a "Breaking changes" heading.
- `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md` — replace the `snapshot` response shape example.
- `Plugins/inspector-mcp/README.md` — version note.
- `Plugins/inspector-mcp/templates/README.md` — no change (registration command is unchanged).

## Testing

Test-driven. One PR, no split. Full inventory of affected test files (all under `Tests/`):

| File | Lines | Impact |
|---|---|---|
| `InspectorMCPWireTests/InspectorMCPWireTests.swift` | 81 | Add 2 new tests; no existing snapshot asserts. |
| `InspectorMCPServerTests/InspectorMCPServerTests.swift` | 225 | Update 1 `MockBridgeClient` default; no existing `pngBase64` assertions. |
| `InspectorTests/InspectorMCPTransportTests.swift` | 242 | Rewrite 1 test (`testSnapshotReturnsBase64PNGEnvelope`); add 2 new tests. |
| `InspectorTests/InspectorBridgeServiceTests.swift` | 613 | Update 2 sites: assertion at `:181` (`XCTAssertFalse(artifact.pngData.isEmpty)`) and fixture at `:607` (`pngData: Data([0x1])` in `InspectorBridgeSnapshotArtifact` init). |
| `InspectorTests/InspectorConfigurationTests.swift` | 93 | Add default assertion for `snapshotArtifactMaxCount`. |
| `InspectorTests/SnapshotCachingTests.swift` | 115 | **Not affected.** Tests `ExpirableStore` / `SnapshotStore` generic value types (verified by `grep pngData` — zero hits). |

### Test isolation

Tests that mutate singleton state (`Inspector.sharedInstance`, the artifact directory on disk) use `setUp`/`tearDown`:
- `setUp`: force a clean `inspector-snapshots/` directory (remove + recreate) to isolate file counts from prior tests.
- `tearDown`: remove the directory. If the test called `Inspector.stop()`, also restart to restore sharedInstance state for subsequent tests in the run.

### New and changed tests

**`InspectorMCPWireTests.swift`**
- `testSnapshotResultDecodesAndEncodesPngPath` — round-trip `{pngPath, deviceScale, createdAt, size, handle, mimeType}`.
- `testHealthResponseDecodesApiVersion` — verify `apiVersion: 2` decode; verify older JSON without `apiVersion` still decodes when the field is optional-with-default.

**`InspectorMCPServerTests.swift`**
- Update `MockBridgeClient` default snapshot response to set `pngPath` to a fixture path.
- Existing tests that construct `InspectorMCPSnapshotResult` stop setting `pngBase64`.

**`InspectorBridgeServiceTests.swift`**
- Line 181 assertion: replace `XCTAssertFalse(artifact.pngData.isEmpty)` with `XCTAssertTrue(FileManager.default.fileExists(atPath: artifact.pngURL.path))` + PNG magic-bytes check.
- Line 607 fixture: the `InspectorBridgeSnapshotArtifact` init moves from `pngData: Data([0x1])` to `pngURL: URL(fileURLWithPath: "/tmp/fixture.png")` (the test doesn't read the file; the URL is just a plausible placeholder).
- If existing tests construct real artifacts through the renderer, ensure `tearDown` cleans the artifacts directory.

**`InspectorConfigurationTests.swift`**
- `testSnapshotArtifactMaxCountDefault` — assert `InspectorConfiguration.config().snapshotArtifactMaxCount == 32` (or at least `>= 1`, mirroring the existing `snapshotMaxCount` test at `:47`).

**`InspectorMCPTransportTests.swift`**
- Replace `testSnapshotReturnsBase64PNGEnvelope` with `testSnapshotReturnsPNGFilePathEnvelope`:
  - Call `/snapshot` via the in-process HTTP transport.
  - Assert `result.pngPath` starts with `/` (absolute).
  - Assert `FileManager.default.fileExists(atPath: result.pngPath)`.
  - Read first 8 bytes of the file, assert PNG magic header `[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]`.
  - Assert `result.deviceScale == UIScreen.main.scale` in the test runner context.
  - Assert `result.createdAt` is recent (within test runtime window).
- New `testSnapshotRingBufferEvictsOldest`:
  - Configure `snapshotArtifactMaxCount = 3`.
  - Take 4 snapshots, each producing a distinct file.
  - Assert the directory has exactly 3 files and the oldest (by mtime) was removed.
- New `testSnapshotCleanupOnStop`:
  - Take 2 snapshots, assert directory populated.
  - Call `Inspector.stop()`.
  - Assert directory is empty (or absent).
  - `tearDown` calls `Inspector.start()` to restore singleton state.

## Breaking changes and migration

Single, atomic break:

- Wire response field `pngBase64` removed; `pngPath` added.
- Wire response field `scale` renamed to `deviceScale`.
- Wire response gains `createdAt`.
- `InspectorBridgeSnapshotArtifact.pngData` removed; `pngURL` added; `scale` renamed to `deviceScale`; `createdAt` added.
- MCP `serverInfo.version` bumps `1.0.0` → `2.0.0`.
- `/health` gains `apiVersion: 2`.

Migration note in release notes and in `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md`:

> **Restart your MCP clients (Codex, Claude Code) after upgrading Inspector.** The snapshot tool response shape changed in v2; clients cache the schema per session, so in-flight sessions keep the old shape until reconnected.

No compatibility shim. Single consumer (Pedro's Codex and Claude Code setups) is updated with the plugin skill refresh.

## Gaps evaluated

All gaps below were evaluated via parallel haiku agents; decisions are baked into the design above.

- **G11 — snapshot cache collision.** Read confirms: `snapshotMaxCount` caches `PinnedSnapshot` (hierarchy reference + handle index) in `InspectorBridgeService`, not rendered PNGs. Every snapshot call renders fresh. No interaction with the new disk-artifact path.
- **G14 — client schema cached in-session.** Low. Documented via release note; no version banner.
- **G16 — simulator sandbox path is long and opaque.** Low. Agents pass paths to their Read tool; length/opacity irrelevant.
- **G17 / G18 / G27 — sandbox volatility (erase, reinstall, iOS tmp cleanup).** Low in interactive dev flow. `createdAt` is shipped in the response for future clients that want TTL validation. Documented as "use immediately".
- **G22 — Swift API break on `InspectorBridgeSnapshotArtifact`.** Low. No deprecation shim; the four known callsites are updated in the same PR.
- **G23 — test churn.** Smaller than feared. One real transport assertion plus one mock default; no split PR needed.
- **G28 — `scale` response semantics.** Renamed to `deviceScale` now, reserving `scale` for a future request parameter without a collision.
- **G30 — MCP tool description steers the agent.** High; baked into the design with exact text above and per-input-field descriptions.
- **G32 — no formal MCP version negotiation.** Low-med. `serverInfo.version` bump plus `/health.apiVersion` are the full response; release note carries the behavioral guarantee.
- **G35 — Claude Code `Read` over simulator sandbox path.** Verified empirically during design. Path inside `~/Library/Developer/CoreSimulator/...` is accepted and rendered inline.
- **G40 — disk write failure mapping.** Reuses `.captureFailed` with an `os_log` diagnostic at the throw site. No new enum case, no wire schema churn.

## Non-goals / deferred

Explicitly out of scope for this change; captured as follow-up issues:

- **Request-side `scale` parameter.** Reduces render latency (O(n²) pixel work at higher scales) and gives clients fidelity control. Deferred because token-bomb — the original motivation — is solved by disk paths, and the `deviceScale` rename reserves the field name. Issue: add later.
- **Adaptive `maxPixels` / `maxBytes` request parameter.** Higher-level abstraction that hides scale math from the client. Also deferred, tracked together with `scale`.
- **Multi-simulator / multi-app support.** The bridge is already constrained to a single booted simulator and a single bundle id on the fixed localhost port. Not in scope here.
- **Cross-host transport (containers, remote simulator).** Disk-path contract assumes client and server share a filesystem namespace. Documented as a known limit; not addressed until a concrete need appears.
- **Pruning directory on server boot.** Optional hygiene: clean `inspector-snapshots/` on `Inspector.start()` to evict stale files from prior runs. Not strictly needed because the ring buffer catches up quickly. Can be added cheaply later.
