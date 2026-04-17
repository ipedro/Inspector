# MCP `inspect` Tool — Design Spec

**Date:** 2026-04-17
**Approach:** Add a fourth MCP tool that pipes a handle directly to `Inspector.inspect(_ view:)` on the main thread. Purely additive on top of the v2 read-only bridge.

## Problem

The Inspector MCP bridge today exposes only `query`, `resolve`, and `snapshot`. An agent that discovers a view via `query` cannot then ask the bridge to *open the Inspector UI* focused on that view. The only ways to reach Inspector's UI live in the consumer app — long-press on a view, shake the device, or tap a custom command the app wires up. None of those are reachable from an MCP client, which breaks the interactive inspection loop.

The Swift API for this already exists: `Inspector.inspect(_ view: UIView, animated: Bool = true)` at `Sources/Inspector/Inspector.swift:216`. It delegates to `Manager+ElementInspectorCoordinatorDelegate.startElementInspectorCoordinator(for:panel:from:animated:)` which presents a fresh `ElementInspectorCoordinator` modal over the current key window's top view controller. The bridge owns the handle → `ViewHierarchyElementReference` → `_underlyingObject` chain and already funnels calls through a main-thread queue (`performOnMain`). A new MCP tool is pure glue — no new rendering, no new state, no new cache, no protocol change.

Root cause: the bridge was scoped as "read-only v1" for shipping speed. The constraint was correct for `snapshot`/`query`/`resolve` but artificial for `inspect`, which is a thin dispatch call.

## Design

### Contract

New tool `inspect`.

Request:

```json
{"handle": "HANDLE"}
```

Response:

```json
{"handle": "HANDLE", "presented": true}
```

`presented: true` means the `Inspector.sharedInstance.inspect(view)` call was dispatched onto the main queue successfully. It does **not** mean the modal has finished animating in — the bridge does not block on UIKit presentation. Agents that need to verify UI state should follow up with a fresh `query` or `snapshot`.

Errors reuse the existing `InspectorMCPTransportError` envelope with the existing `InspectorMCPWireErrorCode` cases:

- `disabled` — `Inspector.setConfiguration(.config(enableMCPBridge: false))` or no bridge
- `notStarted` — `Inspector.start()` not yet called
- `staleHandle` — the handle is unknown, expired, or its underlying object was deallocated (validated by `lookupRecord` + `validate`)
- `unsupportedTarget` — the resolved reference's `_underlyingObject` is not a `UIView` (defensive; the reference protocol allows non-view elements in principle)
- `internalFailure(message:)` — unexpected

### Stacking and idempotency

`Inspector.inspect` presents a new modal every call. The bridge does **not** dismiss any existing `ElementInspectorCoordinator` before presenting a new one. Consecutive `inspect` calls stack modals — acceptable for v1 because Inspector's UI has a native back affordance and because the bridge must not enforce UX policy that belongs inside Inspector itself.

If the user later decides stacked modals are unacceptable, the fix lives in Inspector's presentation logic (coordinator replaces itself when started for a different element), not in the bridge. A future `dismiss` MCP tool is deferred to its own spec.

### Concurrency

All four MCP operations serialize on `performOnMain(.inspect)` in `InspectorMCPBridgeService`. The `inspect` implementation resolves the handle synchronously on main, then calls `Inspector.sharedInstance.inspect(view)` on main as well. Because `inspect` delegates to `startElementInspectorCoordinator` which calls `present(_:animated:completion:)`, the modal starts animating on the current run loop and finishes asynchronously; the bridge returns as soon as the presentation call has been dispatched.

### Per-layer changes

#### `Sources/InspectorMCPWire/InspectorMCPWire.swift`

Add the new enum case to `InspectorMCPOperation` (line 13):

```swift
public enum InspectorMCPOperation: String, Codable, CaseIterable {
    case query
    case resolve
    case snapshot
    case inspect
}
```

Add the request/response types next to `InspectorMCPSnapshotRequest`:

```swift
public struct InspectorMCPInspectRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}

public struct InspectorMCPInspectResult: Codable, Equatable {
    public let handle: String
    public let presented: Bool

    public init(handle: String, presented: Bool) {
        self.handle = handle
        self.presented = presented
    }
}
```

No new `InspectorMCPWireErrorCode` or `InspectorMCPTransportErrorDetails` cases — all error paths reuse existing ones.

#### `Sources/Inspector/Bridge/InspectorBridgeTypes.swift`

Extend `InspectorBridgeOperation`:

```swift
enum InspectorBridgeOperation {
    case query
    case resolve
    case snapshot
    case inspect
}
```

No new artifact type. `inspect` has no payload besides the confirmation bool, which is built directly in the HTTP transport layer.

#### `Sources/Inspector/Bridge/InspectorBridgeService.swift`

Add an `inspect(_ handle:)` method on `InspectorMCPBridgeService` next to `snapshot(_:afterScreenUpdates:)`:

```swift
func inspect(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
    try performOnMain(.inspect) {
        try self.ensureActive()
        self.cleanupExpiredSnapshots()

        let (_, record) = try self.lookupRecord(for: handle)
        try self.validate(record: record, handle: handle)

        guard let view = record.reference._underlyingObject as? UIView else {
            throw InspectorBridgeError.unsupportedTarget
        }

        Inspector.sharedInstance.inspect(view)
        return handle
    }
}
```

Returning the handle (rather than `Void`) keeps the signature symmetrical with `resolve` and `snapshot` and lets the HTTP transport echo it back without a second lookup.

Add a public static entry point in the existing `package extension Inspector` block (around line 448):

```swift
static func bridgeInspect(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
    try sharedInspectorMCPBridgeService.inspect(handle)
}
```

#### `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift`

Add the fourth route to `route(_:)`:

```swift
case ("POST", InspectorMCPBridgeEndpoint.inspectPath):
    let payload: InspectorMCPInspectRequest = try decode(
        request.body,
        allowedKeys: ["handle"]
    )

    do {
        return try jsonResponse(
            InspectorMCPSuccessEnvelope(result: try bridgeInspectResult(for: payload))
        )
    } catch let error as InspectorBridgeError {
        return try jsonResponse(InspectorMCPFailureEnvelope(error: transportError(for: error)))
    }
```

And the mapper:

```swift
private func bridgeInspectResult(for request: InspectorMCPInspectRequest) throws -> InspectorMCPInspectResult {
    _ = try Inspector.bridgeInspect(.init(rawValue: request.handle))
    return InspectorMCPInspectResult(handle: request.handle, presented: true)
}
```

Extend the advertised operations in `healthResponse()`:

```swift
operations: [.query, .resolve, .snapshot, .inspect]
```

Add the endpoint path constant to `InspectorMCPBridgeEndpoint`:

```swift
static let inspectPath = "/inspect"
```

#### `Sources/InspectorMCPServer/InspectorMCPServerSession.swift`

Append the `inspect` entry to the `tools/list` payload, keeping the style of `query` / `resolve` / `snapshot`:

```swift
[
    "name": "inspect",
    "description": "Open the Inspector UI focused on the given handle. Stacks on top of any currently-presented Inspector session.",
    "inputSchema": [
        "type": "object",
        "properties": [
            "handle": [
                "type": "string",
                "description": "Opaque handle returned by query or resolve."
            ]
        ],
        "required": ["handle"]
    ],
    "annotations": [
        "readOnlyHint": false,
        "destructiveHint": false,
        "openWorldHint": true,
        "idempotentHint": false
    ]
]
```

Two annotation differences from the other three tools: `readOnlyHint: false` (this tool drives UI state) and `idempotentHint: false` (stacking means two calls produce two modals). That's useful signal for agents and is free to emit.

Route the new tool through the bridge client in `tools/call`, alongside `query`/`resolve`/`snapshot`.

#### `Sources/InspectorMCPServer/InspectorMCPBridgeClient.swift`

Add to the protocol:

```swift
func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError>
```

And to `InspectorMCPHTTPBridgeClient` — follow the pattern of the existing `snapshot` method (POST JSON to `/inspect`, decode the envelope):

```swift
func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError> {
    try await post(path: "/inspect", body: request)
}
```

### Plugin docs

- `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md` — add `inspect` alongside `query`/`resolve`/`snapshot` in step 5 of the workflow. Document the stacking caveat and the `presented: true = dispatch accepted` semantics.
- `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md` — add a short "Driving the Inspector UI" section with the `query → inspect` recipe.
- `Plugins/inspector-mcp/README.md` — under Versions, append a note for the additive tool (no breaking change).

## Testing

All test runners go through `xcodebuild test` against either the `Example` scheme (Simulator-gated) or the `InspectorMCPServer` scheme (macOS host), matching the runner split we already established.

**Wire** (`Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift`):

- `testInspectRequestRoundTrips` — encode + decode the request.
- `testInspectResultRoundTrips` — encode + decode the result with `presented: true`.
- `testInspectOperationIsPartOfCaseIterable` — assert `.inspect` is in `InspectorMCPOperation.allCases`.

**Bridge service** (`Tests/InspectorTests/InspectorBridgeServiceTests.swift`):

- `testInspectReturnsHandleOnSuccess` — with a live UIView reference, call `inspect(handle)`, assert it returns the same handle.
- `testInspectDispatchesOntoInspectorOnMain` — use a test double for `Inspector.sharedInstance.inspect(_:)` (or spy via a manager stub) to assert it was invoked with the matching `UIView`. If a test double is awkward, assert via `isInspecting(_ view:)` after a short run-loop pump.
- `testInspectRejectsStaleHandle` — unknown handle → `InspectorBridgeError.staleHandle`.
- `testInspectRejectsDeallocatedView` — reference whose `_underlyingObject` is nil → `.staleHandle` (same path as `resolve`/`snapshot`).
- `testInspectRejectsNonViewReference` — mock reference whose `_underlyingObject` is a non-UIView → `.unsupportedTarget`.

**HTTP transport** (`Tests/InspectorTests/InspectorMCPTransportTests.swift`):

- `testInspectReturnsPresentedEnvelope` — POST `/inspect` with a valid live handle; assert `payload.result.presented == true` and `payload.result.handle` matches the request.
- `testInspectHealthAdvertisesInspect` — the existing health test extended to assert `"inspect"` is in the `operations` list.
- `testInspectRejectsMalformedBody` — POST with unknown keys returns 400 malformed.

**MCP server session** (`Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift`):

- `testToolsListIncludesInspect` — `tools/list` includes the inspect tool with the expected description, `handle` property, and `readOnlyHint: false`.
- `testToolsCallInspectForwardsToBridge` — `tools/call inspect` with a mock `InspectorMCPBridgeClient` invokes its `inspect(_:)` method and returns the wire result in the structured content envelope.
- `testToolsCallInspectSurfacesBridgeErrors` — bridge returns `staleHandle` → JSON-RPC result has `isError: true` with the error code in `structuredContent.error.code`.

### Test runner matrix

| Bundle | Runner |
|---|---|
| `InspectorMCPWireTests`, `InspectorMCPServerTests` | `xcodebuild test -scheme InspectorMCPServer -destination 'platform=macOS,arch=arm64' -only-testing:<bundle>/...` |
| `InspectorBridgeServiceTests`, `InspectorMCPTransportTests` | `xcodebuild test -project Example/Example.xcodeproj -scheme Example -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' -only-testing:InspectorTests/...` |

## Breaking changes

None. Purely additive:

- `InspectorMCPOperation.inspect` is a new enum case; existing decoders that read `operations` accept the string. Older clients that switch on `InspectorMCPOperation` without a default will not compile against the new wire module — but the wire module is internal to this repo, so no external clients exist yet.
- `InspectorMCPInspectRequest` / `InspectorMCPInspectResult` are new types.
- `InspectorBridgeError.unsupportedTarget` already exists; nothing changes there.
- `InspectorMCPServer.serverInfo.version` stays at `2.0.0`. The additive tool does not justify a bump; release notes mention "adds `inspect` tool" as a minor capability increase.

Release notes in `Plugins/inspector-mcp/README.md` and `SKILL.md` add a v2.1 line describing the new capability but no "restart your client" callout: existing v2 clients keep working, and new clients that want the `inspect` tool reconnect to get the refreshed `tools/list`.

## Gaps evaluated

- **Stacking vs replacement**: the bridge does nothing. UX fix lives in Inspector's presentation logic. Decided during brainstorming; a future `dismiss` tool is a separate spec.
- **Ack semantics**: `presented: true` = dispatch accepted. Does not mean animation completed. Agents poll `query`/`snapshot` if they need UI-settled verification.
- **Handle lifetime**: `inspect` validates via the same `lookupRecord` + `validate` as `resolve`/`snapshot`. Stale handle → `staleHandle` error. No TTL surprise beyond what the existing three tools already expose.
- **Non-UIView references**: the `ViewHierarchyElementReference` protocol allows non-view elements (e.g., `UIWindow`, `UIViewController`). `Inspector.inspect` requires a `UIView`. `unsupportedTarget` covers windows and controllers specifically — for view controllers the caller should resolve down to a view first. Documented in the SKILL.
- **Re-entrancy**: `performOnMain` recursion is already safe (the guard at the top of `performOnMain` checks `Thread.isMainThread` and reuses the thread).
- **Error paths surface via structured content**: `tools/call inspect` wraps bridge errors in `isError: true` with `structuredContent.error`. Matches the existing `snapshot`/`query` behavior verified by `testToolsCallMapsBridgeDomainErrorsToToolResults`.

## Non-goals / deferred

- **`dismiss` MCP tool** — needed only if stacking becomes painful; not in scope here.
- **Coordinator tracking** — to turn stacking into replacement. Deferred; lives in Inspector's presentation logic.
- **AX-tree keyboard internals** — orthogonal; see the recent `filtersSystemKeyboardWindows` work. A future `accessibilityQuery` tool could walk the accessibility tree to reach remote-process keyboard internals, but it is a distinct bridge feature.
- **`panel:` parameter** — `Inspector.inspect` accepts a panel hint internally via `startElementInspectorCoordinator(..., panel: .default, ...)`. Exposing panel selection in the request is a natural v2.2 addition; skipped here to keep the first slice minimal.
- **Inspector UI behavior polish** — any "replace instead of stack", animation tweaks, or new affordances are owned by Inspector itself and tracked separately.
