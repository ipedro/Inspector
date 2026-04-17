# MCP `inspect` Tool Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a fourth MCP tool `inspect` that pipes a handle to `Inspector.inspect(_ view:)` so agents can open the Inspector UI focused on any live view.

**Architecture:** Purely additive over v2. New `inspect` case on `InspectorMCPOperation`, new request/result wire types, new route `POST /inspect` on the HTTP transport, new `inspect(_:)` method on the bridge service that reuses `performOnMain` + `lookupRecord` + `validate` and fires `Inspector.sharedInstance.inspect(view)` on main. MCP server session exposes the tool with `readOnlyHint: false` + `idempotentHint: false`; stacking is intentional v1 behavior.

**Tech Stack:** Swift 5/6, SwiftPM, XCTest, UIKit (simulator-only code gated by `#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)`).

**Spec:** `docs/superpowers/specs/2026-04-17-mcp-inspect-tool-design.md`

---

## File Structure

### Sources (modified)

| File | Responsibility |
|---|---|
| `Sources/InspectorMCPWire/InspectorMCPWire.swift` | Add `InspectorMCPOperation.inspect`, `InspectorMCPInspectRequest`, `InspectorMCPInspectResult`, `InspectorMCPBridgeEndpoint.inspectPath`. |
| `Sources/Inspector/Bridge/InspectorBridgeTypes.swift` | Add `InspectorBridgeOperation.inspect`. |
| `Sources/Inspector/Bridge/InspectorBridgeService.swift` | Add `inspect(_:)` method on `InspectorMCPBridgeService`; add `Inspector.bridgeInspect(_:)` static in the existing `package extension Inspector` block. |
| `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift` | Add `POST /inspect` route wiring `bridgeInspectResult(for:)`; append `.inspect` to `healthResponse().operations`. |
| `Sources/InspectorMCPServer/InspectorMCPServerSession.swift` | Extend `toolDefinition` with optional annotations; add `inspect` entry in `toolsListResult()`; dispatch `case "inspect"` in `handleToolCall`. |
| `Sources/InspectorMCPServer/InspectorMCPBridgeClient.swift` | Add `inspect(_:)` to the `InspectorMCPBridgeClient` protocol + `InspectorMCPHTTPBridgeClient` conformance. |

### Tests (modified / added)

| File | Impact |
|---|---|
| `Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift` | + 2 round-trip tests for request and result; + assertion that `.inspect` is in `allCases`. |
| `Tests/InspectorTests/InspectorBridgeServiceTests.swift` | + 4 tests: happy path, staleHandle, deallocated view → staleHandle, non-UIView reference → unsupportedTarget. |
| `Tests/InspectorTests/InspectorMCPTransportTests.swift` | + 2 tests: POST /inspect success envelope; /health advertises `inspect`. |
| `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift` | Update `MockBridgeClient` with `inspect` stub; + 2 tests: `tools/list` includes the inspect tool with non-read-only annotations; `tools/call inspect` forwards to the bridge client and surfaces bridge errors. |

### Plugin docs (modified)

| File | Change |
|---|---|
| `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md` | Add `inspect` to the "Use the tools effectively" section. Document stacking + `presented: true = dispatch accepted`. |
| `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md` | New "Driving the Inspector UI" section with the `query → inspect` recipe. |
| `Plugins/inspector-mcp/README.md` | Under Versions, append v2.1 line for the additive tool. |

---

## Test Command Reference

All runs go through `xcodebuild test`. `swift test` is still broken in this repo (unrelated `@testable import` issue on `InspectorMCPServer` executable target — tracked as follow-up).

Wire + Server tests run on macOS via the package-generated `InspectorMCPServer` scheme:

```bash
xcodebuild test \
  -scheme InspectorMCPServer \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:<TestBundle>/<TestClass>/<testMethod>
```

Bridge + Transport + Configuration tests run on the iOS Simulator via the `Example` scheme:

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' \
  -only-testing:InspectorTests/<TestClass>/<testMethod>
```

Destination `iPhone 17 Pro, OS=26.4.1` is the bootable simulator on this Mac.

---

## Task 1: Wire — add `inspect` operation, request, result, endpoint path

**Files:**
- Modify: `Sources/InspectorMCPWire/InspectorMCPWire.swift`
- Test: `Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift`

- [ ] **Step 1: Write the failing tests**

Append to `Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift`:

```swift
func testInspectOperationIsInAllCases() {
    XCTAssertTrue(InspectorMCPOperation.allCases.contains(.inspect),
                  "InspectorMCPOperation.inspect must be a declared case")
}

func testInspectRequestRoundTrips() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let request = InspectorMCPInspectRequest(handle: "HANDLE-1")

    let data = try encoder.encode(request)
    let decoded = try decoder.decode(InspectorMCPInspectRequest.self, from: data)

    XCTAssertEqual(decoded.handle, "HANDLE-1")
}

func testInspectResultRoundTrips() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let result = InspectorMCPInspectResult(handle: "HANDLE-2", presented: true)

    let data = try encoder.encode(result)
    let decoded = try decoder.decode(InspectorMCPInspectResult.self, from: data)

    XCTAssertEqual(decoded.handle, "HANDLE-2")
    XCTAssertTrue(decoded.presented)
}

func testInspectPathMatchesRouteConstant() {
    XCTAssertEqual(InspectorMCPBridgeEndpoint.inspectPath, "/inspect")
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test \
  -scheme InspectorMCPServer \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testInspectOperationIsInAllCases \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testInspectRequestRoundTrips \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testInspectResultRoundTrips \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testInspectPathMatchesRouteConstant
```

Expected: compile errors — unknown case `.inspect`, unknown type `InspectorMCPInspectRequest`/`InspectorMCPInspectResult`, unknown member `inspectPath`.

- [ ] **Step 3: Add the wire additions**

In `Sources/InspectorMCPWire/InspectorMCPWire.swift`, at line 7 (after `queryPath`/`resolvePath`/`snapshotPath` constants), add:

```swift
    public static let inspectPath = "/inspect"
```

Replace the `InspectorMCPOperation` enum at line 13 with:

```swift
public enum InspectorMCPOperation: String, Codable, CaseIterable {
    case query
    case resolve
    case snapshot
    case inspect
}
```

Immediately after the `InspectorMCPSnapshotRequest` struct (which ends around line 115), add:

```swift
public struct InspectorMCPInspectRequest: Codable, Equatable {
    public let handle: String

    public init(handle: String) {
        self.handle = handle
    }
}
```

Immediately after the `InspectorMCPSnapshotResult` struct (which ends around line 199), add:

```swift
public struct InspectorMCPInspectResult: Codable, Equatable {
    public let handle: String
    public let presented: Bool

    public init(handle: String, presented: Bool) {
        self.handle = handle
        self.presented = presented
    }
}
```

- [ ] **Step 4: Run the tests**

Same command as Step 2. Expected: PASS all four.

- [ ] **Step 5: Commit**

```bash
git add Sources/InspectorMCPWire/InspectorMCPWire.swift Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift
git commit -m "feat(mcp): wire inspect request/result/operation/path"
```

---

## Task 2: Bridge — `InspectorBridgeOperation.inspect`

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorBridgeService.swift` (enum near line 27)

No dedicated test — the enum is internal telemetry read by `performOnMain` observers; usage compiles transitively with Task 3.

- [ ] **Step 1: Add the case**

In `Sources/Inspector/Bridge/InspectorBridgeService.swift`, locate the `InspectorBridgeOperation` enum (around line 27). Replace it with:

```swift
enum InspectorBridgeOperation {
    case query
    case resolve
    case snapshot
    case inspect
}
```

- [ ] **Step 2: Confirm the module still compiles**

```bash
xcodebuild build-for-testing \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorBridgeService.swift
git commit -m "chore(bridge): declare InspectorBridgeOperation.inspect"
```

---

## Task 3: Bridge service — `inspect(_:)` method + static `Inspector.bridgeInspect(_:)`

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorBridgeService.swift` (service method + `package extension Inspector`)
- Test: `Tests/InspectorTests/InspectorBridgeServiceTests.swift`

- [ ] **Step 1: Write the failing tests**

Append to `Tests/InspectorTests/InspectorBridgeServiceTests.swift`. Adapt `makeLiveReference()` to the helper already present in the file (the renderer ring-buffer test added in the disk-path PR uses one named like that; reuse or copy its idiom).

```swift
func testBridgeInspectReturnsHandleForLiveView() throws {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    window.makeKeyAndVisible()
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    window.addSubview(view)
    let element = ViewHierarchyElement(with: view)
    let handle = InspectorBridgeHandle(rawValue: UUID().uuidString)

    let service = makeBridgeService(
        snapshotProvider: { makeSnapshot(root: element, handle: handle, reference: element) }
    )

    let returned = try service.inspect(handle)
    XCTAssertEqual(returned, handle)

    addTeardownBlock { window.isHidden = true }
}

func testBridgeInspectRejectsUnknownHandle() {
    let service = makeBridgeService(snapshotProvider: { nil })
    let handle = InspectorBridgeHandle(rawValue: "UNKNOWN")

    XCTAssertThrowsError(try service.inspect(handle)) { error in
        XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
    }
}

func testBridgeInspectRejectsDeallocatedView() {
    let handle = InspectorBridgeHandle(rawValue: UUID().uuidString)
    let element: ViewHierarchyElement = {
        let view = UIView()
        return ViewHierarchyElement(with: view) // view deallocates here
    }()
    let service = makeBridgeService(
        snapshotProvider: { makeSnapshot(root: element, handle: handle, reference: element) }
    )

    XCTAssertThrowsError(try service.inspect(handle)) { error in
        XCTAssertEqual(error as? InspectorBridgeError, .staleHandle)
    }
}

func testBridgeInspectRejectsNonViewReference() {
    let handle = InspectorBridgeHandle(rawValue: UUID().uuidString)
    let nonViewElement = NonViewMockElement() // see helper below
    let service = makeBridgeService(
        snapshotProvider: { makeSnapshot(root: nonViewElement, handle: handle, reference: nonViewElement) }
    )

    XCTAssertThrowsError(try service.inspect(handle)) { error in
        XCTAssertEqual(error as? InspectorBridgeError, .unsupportedTarget)
    }
}
```

Add the mock at the bottom of the test file:

```swift
private final class NonViewMockElement: ViewHierarchyElementReference {
    // Mirror the minimal surface the test path exercises. Use existing
    // `ViewHierarchyElement` as a reference; only `_underlyingObject`
    // needs to be non-UIView. Fill the remaining protocol requirements
    // with simple fixed values matching the other mocks in this file.
    var _underlyingObject: AnyObject? { NSObject() }
    // ... other required members (reuse the pattern from existing
    // `RecordingSnapshotRenderer` fixture or copy a no-op stub).
}
```

If the `ViewHierarchyElementReference` protocol has too many required members for a quick stub, use `class NonViewMockElement: ViewHierarchyElement` subclass that overrides `_underlyingObject` to return `NSObject()` instead of a `UIView`.

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' \
  -only-testing:InspectorTests/InspectorBridgeServiceTests/testBridgeInspectReturnsHandleForLiveView \
  -only-testing:InspectorTests/InspectorBridgeServiceTests/testBridgeInspectRejectsUnknownHandle \
  -only-testing:InspectorTests/InspectorBridgeServiceTests/testBridgeInspectRejectsDeallocatedView \
  -only-testing:InspectorTests/InspectorBridgeServiceTests/testBridgeInspectRejectsNonViewReference
```

Expected: compile errors — `service.inspect(_:)` doesn't exist.

- [ ] **Step 3: Add the service method**

In `Sources/Inspector/Bridge/InspectorBridgeService.swift`, right after the existing `snapshot(_:afterScreenUpdates:)` method (around line 172), add:

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

In the same file's `package extension Inspector` block (around line 439), add alongside `bridgeSnapshot`:

```swift
    static func bridgeInspect(_ handle: InspectorBridgeHandle) throws -> InspectorBridgeHandle {
        try sharedInspectorMCPBridgeService.inspect(handle)
    }
```

- [ ] **Step 4: Run the tests**

Same command as Step 2. Expected: PASS all four.

- [ ] **Step 5: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorBridgeService.swift Tests/InspectorTests/InspectorBridgeServiceTests.swift
git commit -m "feat(bridge): inspect(_:) dispatches Inspector.inspect on main"
```

---

## Task 4: HTTP transport — `POST /inspect` + health operations

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift`
- Test: `Tests/InspectorTests/InspectorMCPTransportTests.swift`

- [ ] **Step 1: Write the failing tests**

Append to `Tests/InspectorTests/InspectorMCPTransportTests.swift`:

```swift
func testHealthAdvertisesInspectOperation() throws {
    let payload = try healthResponsePayload() // existing helper; returns [String: Any]
    let operations = try XCTUnwrap(payload["operations"] as? [String])
    XCTAssertTrue(operations.contains("inspect"),
                  "health should advertise the inspect operation")
}

func testInspectReturnsPresentedEnvelopeForLiveHandle() throws {
    // Reuse whatever helper drives /query or /snapshot end-to-end in
    // this file. Pattern: GET a snapshot that pins a handle, POST to
    // /inspect with that handle, decode the envelope.
    let handle = try liveHandleFromBridge() // existing helper

    let payload = try inspectResponsePayload(handle: handle)
    guard let result = payload["result"] as? [String: Any] else {
        return XCTFail("missing result envelope")
    }
    XCTAssertEqual(result["handle"] as? String, handle)
    XCTAssertEqual(result["presented"] as? Bool, true)
}
```

If the existing `InspectorMCPTransportTests.swift` does not expose helpers like `healthResponsePayload()` / `liveHandleFromBridge()` / the envelope helper, copy the idiom from the existing snapshot envelope test (`testSnapshotReturnsPNGFilePathEnvelope`): POST JSON, parse the envelope, assert fields. Keep the test-local pattern.

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' \
  -only-testing:InspectorTests/InspectorMCPTransportTests/testHealthAdvertisesInspectOperation \
  -only-testing:InspectorTests/InspectorMCPTransportTests/testInspectReturnsPresentedEnvelopeForLiveHandle
```

Expected: FAIL — transport has no `/inspect` route and health does not list `inspect`.

- [ ] **Step 3: Add the `/inspect` route**

In `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift`, locate the `route(_:)` function (around line 203). Add a new case right after the snapshot route (after the closing brace of the snapshot block, around line 249):

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

Immediately after the existing `bridgeSnapshotResult(for:)` method (around line 332), add:

```swift
    private func bridgeInspectResult(for request: InspectorMCPInspectRequest) throws -> InspectorMCPInspectResult {
        _ = try Inspector.bridgeInspect(.init(rawValue: request.handle))
        return InspectorMCPInspectResult(handle: request.handle, presented: true)
    }
```

Update `healthResponse()` at the bottom of the function (around line 294) — replace the `operations:` argument value:

```swift
        operations: [.query, .resolve, .snapshot, .inspect]
```

- [ ] **Step 4: Run the tests**

Same command as Step 2. Expected: PASS both.

- [ ] **Step 5: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift Tests/InspectorTests/InspectorMCPTransportTests.swift
git commit -m "feat(transport): POST /inspect route + health advertises inspect"
```

---

## Task 5: Bridge client — `inspect(_:)` on protocol + `InspectorMCPHTTPBridgeClient`

**Files:**
- Modify: `Sources/InspectorMCPServer/InspectorMCPBridgeClient.swift`

This task must land before Task 6 — Task 6's session dispatch and `MockBridgeClient.inspect(_:)` both require the protocol method to exist.

- [ ] **Step 1: Add the protocol method**

In `Sources/InspectorMCPServer/InspectorMCPBridgeClient.swift`, at line 8 (right after the `snapshot` signature in the `InspectorMCPBridgeClient` protocol), add:

```swift
    func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError>
```

- [ ] **Step 2: Add the HTTP implementation**

In the same file, locate the `snapshot(_:)` method on `InspectorMCPHTTPBridgeClient` (around line 93). Immediately after its closing brace, add:

```swift
    func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError> {
        try await sendToolRequest(
            path: InspectorMCPBridgeEndpoint.inspectPath,
            body: request
        )
    }
```

- [ ] **Step 3: Run the full server test suite to verify integration**

```bash
xcodebuild test \
  -scheme InspectorMCPServer \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:InspectorMCPServerTests 2>&1 | tail -10
```

Expected: all tests pass, including the three added in Task 5.

- [ ] **Step 4: Commit**

```bash
git add Sources/InspectorMCPServer/InspectorMCPBridgeClient.swift
git commit -m "feat(mcp): bridge client inspect(_:) over /inspect"
```

---

## Task 6: MCP server session — expose `inspect` tool

**Files:**
- Modify: `Sources/InspectorMCPServer/InspectorMCPServerSession.swift`
- Test: `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift`

- [ ] **Step 1: Write the failing tests**

Append to `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift`:

```swift
func testToolsListIncludesInspectToolWithNonReadOnlyAnnotations() async throws {
    let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
    let request = #"{"jsonrpc":"2.0","id":1,"method":"tools/list"}"#
    let response = try await XCTUnwrap(session.handleMessage(Data(request.utf8)))
    let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
    let result = try XCTUnwrap(object?["result"] as? [String: Any])
    let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
    let inspectTool = try XCTUnwrap(tools.first { ($0["name"] as? String) == "inspect" })

    let description = try XCTUnwrap(inspectTool["description"] as? String)
    XCTAssertTrue(description.contains("Inspector UI"),
                  "description should explain the tool drives Inspector UI")

    let annotations = try XCTUnwrap(inspectTool["annotations"] as? [String: Any])
    XCTAssertEqual(annotations["readOnlyHint"] as? Bool, false,
                   "inspect drives UI state, must not claim readOnly")
    XCTAssertEqual(annotations["idempotentHint"] as? Bool, false,
                   "consecutive inspect calls stack modals, must not claim idempotent")
    XCTAssertEqual(annotations["destructiveHint"] as? Bool, false)

    let schema = try XCTUnwrap(inspectTool["inputSchema"] as? [String: Any])
    let properties = try XCTUnwrap(schema["properties"] as? [String: Any])
    XCTAssertNotNil(properties["handle"])
    let required = try XCTUnwrap(schema["required"] as? [String])
    XCTAssertEqual(required, ["handle"])
}

func testToolsCallInspectForwardsToBridgeClient() async throws {
    let mock = MockBridgeClient(
        inspectResult: .success(InspectorMCPInspectResult(handle: "HANDLE", presented: true))
    )
    let session = InspectorMCPServerSession(bridgeClient: mock)
    let request = #"{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"inspect","arguments":{"handle":"HANDLE"}}}"#

    let response = try await XCTUnwrap(session.handleMessage(Data(request.utf8)))
    let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
    let result = try XCTUnwrap(object?["result"] as? [String: Any])

    XCTAssertEqual(result["isError"] as? Bool, false)
    let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
    XCTAssertEqual(structured["handle"] as? String, "HANDLE")
    XCTAssertEqual(structured["presented"] as? Bool, true)
}

func testToolsCallInspectSurfacesStaleHandleError() async throws {
    let mock = MockBridgeClient(
        inspectResult: .failure(.init(code: .staleHandle, message: "Handle has expired", details: .empty))
    )
    let session = InspectorMCPServerSession(bridgeClient: mock)
    let request = #"{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"inspect","arguments":{"handle":"STALE"}}}"#

    let response = try await XCTUnwrap(session.handleMessage(Data(request.utf8)))
    let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
    let result = try XCTUnwrap(object?["result"] as? [String: Any])

    XCTAssertEqual(result["isError"] as? Bool, true)
    let structured = try XCTUnwrap(result["structuredContent"] as? [String: Any])
    XCTAssertEqual(structured["code"] as? String, "staleHandle")
}
```

Update the existing `MockBridgeClient` fixture in the same file so the `init` accepts an `inspectResult` with a sensible default. Adapt the existing init pattern:

```swift
init(
    queryResult: Result<InspectorMCPQueryResult, InspectorMCPTransportError> = .success(
        InspectorMCPQueryResult(expiresAt: Date(timeIntervalSince1970: 0), nodes: [])
    ),
    resolveResult: Result<InspectorMCPNode, InspectorMCPTransportError>? = nil,
    snapshotResult: Result<InspectorMCPSnapshotResult, InspectorMCPTransportError>? = nil,
    inspectResult: Result<InspectorMCPInspectResult, InspectorMCPTransportError> = .success(
        InspectorMCPInspectResult(handle: "MOCK-HANDLE", presented: true)
    )
) {
    self.queryResult = queryResult
    self.resolveResult = resolveResult ?? /* existing default */
    self.snapshotResult = snapshotResult ?? /* existing default */
    self.inspectResult = inspectResult
}

func inspect(_ request: InspectorMCPInspectRequest) async throws -> Result<InspectorMCPInspectResult, InspectorMCPTransportError> {
    inspectResult
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test \
  -scheme InspectorMCPServer \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:InspectorMCPServerTests/InspectorMCPServerTests/testToolsListIncludesInspectToolWithNonReadOnlyAnnotations \
  -only-testing:InspectorMCPServerTests/InspectorMCPServerTests/testToolsCallInspectForwardsToBridgeClient \
  -only-testing:InspectorMCPServerTests/InspectorMCPServerTests/testToolsCallInspectSurfacesStaleHandleError
```

Expected: compile errors — `MockBridgeClient` init has no `inspectResult`, `inspect` method missing on protocol.

- [ ] **Step 3: Extend `toolDefinition` with optional annotations**

In `Sources/InspectorMCPServer/InspectorMCPServerSession.swift`, replace the existing `toolDefinition(name:description:schema:)` (around line 148) with:

```swift
    private func toolDefinition(
        name: String,
        description: String,
        schema: [String: Any],
        annotations: [String: Any] = [
            "readOnlyHint": true,
            "destructiveHint": false,
            "idempotentHint": true,
            "openWorldHint": true
        ]
    ) -> [String: Any] {
        [
            "name": name,
            "description": description,
            "inputSchema": schema,
            "annotations": annotations
        ]
    }
```

- [ ] **Step 4: Add the `inspect` tool entry**

In the same file, extend `toolsListResult()` (ends around line 146) by adding a fourth entry after the `snapshot` tool entry:

```swift
            ,
            toolDefinition(
                name: "inspect",
                description: "Open the Inspector UI focused on the given handle. Stacks on top of any currently-presented Inspector session.",
                schema: [
                    "type": "object",
                    "additionalProperties": false,
                    "properties": [
                        "handle": [
                            "type": "string",
                            "description": "Opaque handle returned by query or resolve."
                        ]
                    ],
                    "required": ["handle"]
                ],
                annotations: [
                    "readOnlyHint": false,
                    "destructiveHint": false,
                    "idempotentHint": false,
                    "openWorldHint": true
                ]
            )
```

- [ ] **Step 5: Dispatch the `inspect` tool call**

Still in `InspectorMCPServerSession.swift`, extend `handleToolCall(named:arguments:)` by adding a new case before the `default:` line (around line 207):

```swift
        case "inspect":
            let request = try JSONObject.decode(
                InspectorMCPInspectRequest.self,
                from: arguments
            )
            let result = try await bridgeClient.inspect(request)
            return try toolResult(
                for: result,
                successText: { inspectResult in
                    "Presented Inspector UI for handle \(inspectResult.handle)."
                }
            )
```

- [ ] **Step 6: Run the tests**

Same command as Step 2. Expected: PASS all three.

- [ ] **Step 7: Commit**

```bash
git add Sources/InspectorMCPServer/InspectorMCPServerSession.swift Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift
git commit -m "feat(mcp): expose inspect tool with non-read-only annotations"
```

---

## Task 7: Plugin skill + docs update

**Files:**
- Modify: `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md`
- Modify: `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md`
- Modify: `Plugins/inspector-mcp/README.md`

No tests — documentation only.

- [ ] **Step 1: Extend `SKILL.md`**

In `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md`, in "Step 5: Use the tools effectively", add `inspect` to the "Tool order matters" list and extend the narrative with:

```markdown
For interactive sessions, chain `query → inspect` to open the Inspector UI focused on a view:

```json
{"handle":"<handle returned by query>"}
```

Response: `{"handle":"...", "presented": true}`. `presented: true` means the Inspector UI dispatch was accepted; the modal animates in asynchronously. Consecutive `inspect` calls stack modals — Inspector's native back affordance dismisses them.
```

In the "Breaking changes" section, append:

```markdown
- **v2.1 (2026-04-17)** — New `inspect` tool. No breaking changes; additive over v2. Reconnect clients to pick up the new schema.
```

- [ ] **Step 2: Add "Driving the Inspector UI" to `inspection-patterns.md`**

In `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md`, append at the end:

```markdown
## Driving the Inspector UI

Call `inspect` to open the Inspector UI focused on a specific view. Typical recipe:

1. `query` → pick a handle
2. (optional) `resolve` to confirm the node is still the one you want
3. `inspect(handle)` → Inspector presents the element panel for that view

`inspect` semantics:
- Returns `{handle, presented:true}` as soon as the dispatch hits the main thread.
- Does NOT wait for the modal animation to finish; follow with `query`/`snapshot` if the next action depends on UI-settled state.
- Consecutive calls stack modals. Use Inspector's native back affordance to unwind.
- Stale handles → `staleHandle` error. Re-query before retrying.
- Non-UIView references → `unsupportedTarget`. Resolve to a concrete view first.
```

- [ ] **Step 3: Update `Plugins/inspector-mcp/README.md`**

In the "Versions" section, insert right below the `v2` line:

```markdown
- **v2.1 (2026-04-17)** — Adds `inspect` tool. Open the Inspector UI focused on a handle. Additive, no breaking changes.
```

- [ ] **Step 4: Commit**

```bash
git add Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md \
        Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md \
        Plugins/inspector-mcp/README.md
git commit -m "docs(inspector-mcp): document inspect tool (v2.1)"
```

---

## Post-plan verification

After all 7 tasks land:

- [ ] Build both targets cleanly:

```bash
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
swift build --target Inspector --sdk "$SDK" --triple arm64-apple-ios26.4-simulator
swift build --product InspectorMCPServer
```

- [ ] Run the full affected test surface end-to-end:

```bash
xcodebuild test \
  -scheme InspectorMCPServer \
  -destination 'platform=macOS,arch=arm64' \
  -only-testing:InspectorMCPWireTests \
  -only-testing:InspectorMCPServerTests

xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1' \
  -only-testing:InspectorTests/InspectorBridgeServiceTests \
  -only-testing:InspectorTests/InspectorMCPTransportTests
```

- [ ] Live dogfood via MCP:
  1. In Claude Code or Codex, reconnect the `inspector` MCP (`/reload-plugins` if `/mcp` fails).
  2. Confirm `curl /health | jq .operations` includes `"inspect"`.
  3. `mcp__inspector__query classNameContains=UIStackView` — pick one returned handle.
  4. Call `mcp__inspector__inspect {handle}` — Inspector UI opens focused on that view in the Simulator.
  5. Call `inspect` again with a different handle — verify stacking is visible (intended v1 behavior).
  6. Call `inspect` with a fabricated handle string — verify the `staleHandle` error surfaces back as the `tools/call` `isError: true` envelope.
