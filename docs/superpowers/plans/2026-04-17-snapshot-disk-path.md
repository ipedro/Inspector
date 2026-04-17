# Snapshot Disk Path Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace inline base64 PNG payload on the MCP `snapshot` response with a host-absolute file path, eliminating the ~500 kB token-bomb on retina full-screen captures.

**Architecture:** The `InspectorBridgeSnapshotRenderer` writes the rendered PNG to `NSTemporaryDirectory()/inspector-snapshots/<UUID>.png` (inside the simulator app sandbox, which is a host-readable real directory), returns a `pngURL` in the `InspectorBridgeSnapshotArtifact`, and bumps the MCP wire to v2 with `pngPath`, `deviceScale`, `createdAt`, and a new `/health.apiVersion` diagnostic. A ring buffer capped at `InspectorConfiguration.snapshotArtifactMaxCount = 32` rotates oldest files by mtime. `Inspector.stop()` clears the directory.

**Tech Stack:** Swift 5/6, SwiftPM, XCTest, UIKit (simulator-only code gated by `#if INSPECTOR_DEBUGGING && targetEnvironment(simulator)`).

**Spec:** `docs/superpowers/specs/2026-04-17-snapshot-disk-path-design.md`

---

## File Structure

### Sources (modified)

| File | Responsibility |
|---|---|
| `Sources/InspectorMCPWire/InspectorMCPWire.swift` | Wire types: reshape `InspectorMCPSnapshotResult`, add `apiVersion` to `InspectorMCPHealthResponse`. |
| `Sources/Inspector/Bridge/InspectorBridgeTypes.swift` | Reshape `InspectorBridgeSnapshotArtifact` (`pngData`→`pngURL`, `scale`→`deviceScale`, + `createdAt`). |
| `Sources/Inspector/Bridge/InspectorBridgeService.swift` | New module-private dir constant + `cleanupInspectorSnapshotsDirectory()`; renderer writes to disk + prunes; inject `artifactLimitProvider`. |
| `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift` | Map new artifact fields → wire; set `apiVersion = 2` on `/health`. |
| `Sources/Inspector/Configuration/InspectorConfiguration.swift` | New `snapshotArtifactMaxCount: Int = 32`. |
| `Sources/Inspector/Inspector.swift` | Call `cleanupInspectorSnapshotsDirectory()` from `stop()`. |
| `Sources/InspectorMCPServer/InspectorMCPServerSession.swift` | Bump `serverInfo.version` to `2.0.0`; rewrite `snapshot` tool description; add per-property descriptions. |

### Tests (modified / added)

| File | Impact |
|---|---|
| `Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift` | + 2 round-trip tests (`SnapshotResult`, `HealthResponse.apiVersion`). |
| `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift` | Update `MockBridgeClient` default snapshot to use `pngPath`. Add assertions for server version + tool description. |
| `Tests/InspectorTests/InspectorBridgeServiceTests.swift` | Update `:181` assertion to `fileExists`; update `:607` fixture init to use `pngURL`. |
| `Tests/InspectorTests/InspectorConfigurationTests.swift` | + default assertion for `snapshotArtifactMaxCount`. |
| `Tests/InspectorTests/InspectorMCPTransportTests.swift` | Rewrite `testSnapshotReturnsBase64PNGEnvelope` → `testSnapshotReturnsPNGFilePathEnvelope`; + `testSnapshotRingBufferEvictsOldest`; + `testSnapshotCleanupOnStop`. |

### Plugin docs (modified)

| File | Change |
|---|---|
| `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md` | Snapshot example uses `pngPath`; add "Breaking changes" heading with restart note. |
| `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md` | Replace snapshot response example. |
| `Plugins/inspector-mcp/README.md` | Add "v2 — disk-backed PNGs" version note. |

---

## Test Command Reference

**All test runs go through `xcodebuild test` against the `Example` scheme.** `swift test` is not usable in this repo today: `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift` does `@testable import InspectorMCPServer`, which Swift Package Manager rejects for an executable target, and the fallback compile of `Sources/Inspector/**` pulls in UIKit on the host where no UIKit module exists. The Example Xcode project wires every package test target together and runs them on the simulator, where both problems are solved.

Canonical runner:

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:<TestBundle>/<TestClass>/<testMethod>
```

The `<TestBundle>` is the Swift package test target name as bundled into the Example scheme. For this plan the relevant bundles are:

- `InspectorMCPWireTests`
- `InspectorMCPServerTests`
- `InspectorTests` (hosts `InspectorBridgeServiceTests`, `InspectorConfigurationTests`, `InspectorMCPTransportTests`)

Build-only sanity checks:

```bash
# iOS-simulator target build of the Inspector library
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
swift build --target Inspector --sdk "$SDK" --triple arm64-apple-ios26.4-simulator

# Host executable build (fast compile check for the MCP server CLI)
swift build --product InspectorMCPServer
```

**Follow-up (tracked after this plan):** restructure the package so `swift test` works again — most likely by splitting `InspectorMCPServer` into a testable library target plus a thin executable shim. Out of scope for this plan; noted in post-plan verification below.

---

## Task 1: Add `snapshotArtifactMaxCount` to `InspectorConfiguration`

**Files:**
- Modify: `Sources/Inspector/Configuration/InspectorConfiguration.swift`
- Test: `Tests/InspectorTests/InspectorConfigurationTests.swift`

- [ ] **Step 1: Write the failing test**

Add to `InspectorConfigurationTests.swift` after the existing default-config test cluster (near line 48):

```swift
func testDefaultConfigurationSnapshotArtifactMaxCountHasSensibleDefault() {
    let config = InspectorConfiguration.default
    XCTAssertEqual(config.snapshotArtifactMaxCount, 32,
                   "snapshotArtifactMaxCount should default to 32")
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorConfigurationTests/testDefaultConfigurationSnapshotArtifactMaxCountHasSensibleDefault
```

Expected: compile error "value of type 'InspectorConfiguration' has no member 'snapshotArtifactMaxCount'".

- [ ] **Step 3: Add the field**

In `Sources/Inspector/Configuration/InspectorConfiguration.swift`, between `snapshotMaxCount` and `showAllViewSearchQuery` (around line 33):

```swift
public var snapshotArtifactMaxCount: Int = 32
```

- [ ] **Step 4: Run the test**

Same command as Step 2. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Inspector/Configuration/InspectorConfiguration.swift Tests/InspectorTests/InspectorConfigurationTests.swift
git commit -m "feat(mcp): snapshotArtifactMaxCount defaults to 32"
```

---

## Task 2: Add `apiVersion` to `InspectorMCPHealthResponse`

**Files:**
- Modify: `Sources/InspectorMCPWire/InspectorMCPWire.swift:25-48` (`InspectorMCPHealthResponse`)
- Test: `Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift`

- [ ] **Step 1: Write the failing test**

Append to `InspectorMCPWireTests.swift`:

```swift
func testHealthResponseRoundTripsApiVersion() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let response = InspectorMCPHealthResponse(
        status: .active,
        bridgeEnabled: true,
        inspectorStarted: true,
        bundleIdentifier: "com.example",
        operations: [.query, .resolve, .snapshot],
        apiVersion: 2
    )

    let data = try encoder.encode(response)
    let decoded = try decoder.decode(InspectorMCPHealthResponse.self, from: data)

    XCTAssertEqual(decoded.apiVersion, 2)
}

func testHealthResponseDecodesWithoutApiVersionField() throws {
    let legacy = #"{"status":"active","bridgeEnabled":true,"inspectorStarted":true,"bundleIdentifier":"com.example","operations":["query","resolve","snapshot"]}"#
    let decoder = JSONDecoder()
    let decoded = try decoder.decode(InspectorMCPHealthResponse.self, from: Data(legacy.utf8))

    XCTAssertNil(decoded.apiVersion)
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testHealthResponseRoundTripsApiVersion \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testHealthResponseDecodesWithoutApiVersionField
```

Expected: compile error on the init call — "extra argument 'apiVersion'".

- [ ] **Step 3: Add the field**

In `Sources/InspectorMCPWire/InspectorMCPWire.swift`, replace the `InspectorMCPHealthResponse` struct (lines 25–48) with:

```swift
public struct InspectorMCPHealthResponse: Codable, Equatable {
    public let status: InspectorMCPHealthStatus
    public let bridgeEnabled: Bool
    public let inspectorStarted: Bool
    public let bundleIdentifier: String?
    public let operations: [InspectorMCPOperation]
    public let apiVersion: Int?

    public init(
        status: InspectorMCPHealthStatus,
        bridgeEnabled: Bool,
        inspectorStarted: Bool,
        bundleIdentifier: String?,
        operations: [InspectorMCPOperation],
        apiVersion: Int? = nil
    ) {
        self.status = status
        self.bridgeEnabled = bridgeEnabled
        self.inspectorStarted = inspectorStarted
        self.bundleIdentifier = bundleIdentifier
        self.operations = operations
        self.apiVersion = apiVersion
    }
}
```

`Int?` keeps legacy JSON (without the field) decodable.

- [ ] **Step 4: Run tests**

Same commands as Step 2. Expected: PASS both.

- [ ] **Step 5: Commit**

```bash
git add Sources/InspectorMCPWire/InspectorMCPWire.swift Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift
git commit -m "feat(mcp): add optional apiVersion to health response"
```

---

## Task 3: Reshape `InspectorMCPSnapshotResult` wire type

**Files:**
- Modify: `Sources/InspectorMCPWire/InspectorMCPWire.swift:176-196`
- Test: `Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift`
- Modify: `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift` (MockBridgeClient default)

- [ ] **Step 1: Write the failing test**

Append to `InspectorMCPWireTests.swift`:

```swift
func testSnapshotResultRoundTripsNewShape() throws {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let createdAt = ISO8601DateFormatter().date(from: "2026-04-17T10:00:00Z")!
    let result = InspectorMCPSnapshotResult(
        handle: "HANDLE",
        mimeType: "image/png",
        pngPath: "/tmp/inspector-snapshots/abc.png",
        size: .init(width: 402, height: 874),
        deviceScale: 3,
        createdAt: createdAt
    )

    let data = try encoder.encode(result)
    let decoded = try decoder.decode(InspectorMCPSnapshotResult.self, from: data)

    XCTAssertEqual(decoded.pngPath, "/tmp/inspector-snapshots/abc.png")
    XCTAssertEqual(decoded.deviceScale, 3)
    XCTAssertEqual(decoded.createdAt, createdAt)
    XCTAssertEqual(decoded.mimeType, "image/png")
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testSnapshotResultRoundTripsNewShape
```

Expected: compile error — no member `pngPath` / `deviceScale` / `createdAt`.

- [ ] **Step 3: Reshape the wire type**

In `Sources/InspectorMCPWire/InspectorMCPWire.swift`, replace `InspectorMCPSnapshotResult` (lines 176–196) with:

```swift
public struct InspectorMCPSnapshotResult: Codable, Equatable {
    public let handle: String
    public let mimeType: String
    public let pngPath: String
    public let size: InspectorMCPSize
    public let deviceScale: Double
    public let createdAt: Date

    public init(
        handle: String,
        mimeType: String,
        pngPath: String,
        size: InspectorMCPSize,
        deviceScale: Double,
        createdAt: Date
    ) {
        self.handle = handle
        self.mimeType = mimeType
        self.pngPath = pngPath
        self.size = size
        self.deviceScale = deviceScale
        self.createdAt = createdAt
    }
}
```

- [ ] **Step 4: Update MockBridgeClient default**

In `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift`, find every construction of `InspectorMCPSnapshotResult(...)` (grep: `InspectorMCPSnapshotResult(`) and replace with:

```swift
InspectorMCPSnapshotResult(
    handle: "MOCK-HANDLE",
    mimeType: "image/png",
    pngPath: "/tmp/inspector-snapshots/mock.png",
    size: .init(width: 10, height: 10),
    deviceScale: 2,
    createdAt: Date(timeIntervalSince1970: 0)
)
```

Adjust values to match each test site's existing inputs; the important change is the argument labels.

- [ ] **Step 5: Run the new test and the server tests**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorMCPWireTests/InspectorMCPWireTests/testSnapshotResultRoundTripsNewShape \
  -only-testing:InspectorMCPServerTests/InspectorMCPServerTests
```

Expected: PASS all.

- [ ] **Step 6: Commit**

```bash
git add Sources/InspectorMCPWire/InspectorMCPWire.swift Tests/InspectorMCPWireTests/InspectorMCPWireTests.swift Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift
git commit -m "feat(mcp): reshape snapshot wire result (pngPath, deviceScale, createdAt)"
```

---

## Task 4: Reshape `InspectorBridgeSnapshotArtifact`

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorBridgeTypes.swift:68-85`
- Modify: `Tests/InspectorTests/InspectorBridgeServiceTests.swift:181, 605-609`

- [ ] **Step 1: Reshape the bridge artifact type**

In `Sources/Inspector/Bridge/InspectorBridgeTypes.swift`, replace `InspectorBridgeSnapshotArtifact` (lines 68–85) with:

```swift
public struct InspectorBridgeSnapshotArtifact: Hashable, Codable {
    public let handle: InspectorBridgeHandle
    public let pngURL: URL
    public let size: CGSize
    public let deviceScale: CGFloat
    public let createdAt: Date

    public init(
        handle: InspectorBridgeHandle,
        pngURL: URL,
        size: CGSize,
        deviceScale: CGFloat,
        createdAt: Date
    ) {
        self.handle = handle
        self.pngURL = pngURL
        self.size = size
        self.deviceScale = deviceScale
        self.createdAt = createdAt
    }
}
```

- [ ] **Step 2: Update InspectorBridgeServiceTests site at line 181**

Open `Tests/InspectorTests/InspectorBridgeServiceTests.swift`. Replace the existing assertion at line 181 (`XCTAssertFalse(artifact.pngData.isEmpty)`) with:

```swift
XCTAssertTrue(FileManager.default.fileExists(atPath: artifact.pngURL.path),
              "snapshot artifact must exist on disk")

let magic = try Data(contentsOf: artifact.pngURL).prefix(8)
XCTAssertEqual(Array(magic), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
               "snapshot artifact must be a valid PNG file")
```

- [ ] **Step 3: Update InspectorBridgeServiceTests fixture around line 605**

In the same file, replace the stub `snapshot(...)` implementation near line 605 (the one returning `InspectorBridgeSnapshotArtifact(..., pngData: Data([0x1]), ...)`) with:

```swift
return InspectorBridgeSnapshotArtifact(
    handle: handle,
    pngURL: URL(fileURLWithPath: "/tmp/inspector-snapshots/fixture-\(UUID().uuidString).png"),
    size: CGSize(width: 10, height: 10),
    deviceScale: 2,
    createdAt: Date(timeIntervalSince1970: 0)
)
```

The fixture URL is not actually read by callers in this test path; it's a plausible placeholder.

- [ ] **Step 4: Run the affected tests and confirm the suite builds**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorBridgeServiceTests
```

Expected: the assertion at line 181 fails (no file exists yet — renderer has not been wired to write). That's OK: compilation passes, and the assertion will go green in Task 6. Mark this test as `try XCTSkipUnless(false, "pending Task 6")` temporarily if it blocks the build; revert the skip in Task 6.

Actually — write the skip now to keep CI green between commits:

At the top of the affected test method (around line 161), replace its opening line with:

```swift
func testSnapshotReturnsRuntimeSnapshotArtifact() throws {
    try XCTSkipIf(true, "pending Task 6: renderer writes PNG to disk")
```

- [ ] **Step 5: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorBridgeTypes.swift Tests/InspectorTests/InspectorBridgeServiceTests.swift
git commit -m "refactor(mcp): reshape bridge snapshot artifact (pngURL, deviceScale, createdAt)"
```

---

## Task 5: Directory constant + cleanup helper

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorBridgeService.swift` (add file-scope constant + free function, inside `#if` block)
- Test: `Tests/InspectorTests/InspectorBridgeServiceTests.swift`

- [ ] **Step 1: Write the failing test**

Append to `InspectorBridgeServiceTests.swift`:

```swift
func testCleanupInspectorSnapshotsDirectoryRemovesDirectory() throws {
    let fileManager = FileManager.default
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent("inspector-snapshots", isDirectory: true)

    try? fileManager.removeItem(at: url)
    try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    let sentinel = url.appendingPathComponent("sentinel.png")
    try Data([0x89]).write(to: sentinel)
    XCTAssertTrue(fileManager.fileExists(atPath: sentinel.path))

    cleanupInspectorSnapshotsDirectory()

    XCTAssertFalse(fileManager.fileExists(atPath: sentinel.path),
                   "cleanup must remove the inspector-snapshots directory contents")
    XCTAssertFalse(fileManager.fileExists(atPath: url.path),
                   "cleanup must remove the inspector-snapshots directory itself")
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorBridgeServiceTests/testCleanupInspectorSnapshotsDirectoryRemovesDirectory
```

Expected: "use of unresolved identifier 'cleanupInspectorSnapshotsDirectory'".

- [ ] **Step 3: Add the constant + helper**

In `Sources/Inspector/Bridge/InspectorBridgeService.swift`, immediately before the existing `func resetInspectorBridgeState()` (around line 435), add:

```swift
let inspectorSnapshotsDirectoryName = "inspector-snapshots"

func inspectorSnapshotsDirectoryURL() -> URL {
    URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(inspectorSnapshotsDirectoryName, isDirectory: true)
}

func cleanupInspectorSnapshotsDirectory() {
    try? FileManager.default.removeItem(at: inspectorSnapshotsDirectoryURL())
}
```

The constant and helpers use `internal` access (no `public`/`fileprivate`) so the renderer (same module) can share them while staying invisible to consumers.

- [ ] **Step 4: Run the test**

Same command as Step 2. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorBridgeService.swift Tests/InspectorTests/InspectorBridgeServiceTests.swift
git commit -m "feat(mcp): add inspector-snapshots directory constant and cleanup helper"
```

---

## Task 6: Renderer writes PNG to disk + ring-buffer prune

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorBridgeService.swift:33-68` (`InspectorBridgeSnapshotRenderer`)
- Modify: `Sources/Inspector/Bridge/InspectorBridgeService.swift:~420-433` (`sharedInspectorMCPBridgeService` construction — inject artifact limit)
- Test: `Tests/InspectorTests/InspectorBridgeServiceTests.swift` (unskip existing test + new prune test)

- [ ] **Step 1: Update the renderer protocol and struct**

In `Sources/Inspector/Bridge/InspectorBridgeService.swift`, replace the protocol (lines 13–19) and struct (lines 33–68) with:

```swift
protocol InspectorBridgeSnapshotRendering {
    func snapshot(
        for reference: ViewHierarchyElementReference,
        handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool
    ) throws -> InspectorBridgeSnapshotArtifact
}

struct InspectorBridgeSnapshotRenderer: InspectorBridgeSnapshotRendering {
    let artifactLimitProvider: () -> Int
    let dateProvider: () -> Date

    init(
        artifactLimitProvider: @escaping () -> Int = { 32 },
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.artifactLimitProvider = artifactLimitProvider
        self.dateProvider = dateProvider
    }

    func snapshot(
        for reference: ViewHierarchyElementReference,
        handle: InspectorBridgeHandle,
        afterScreenUpdates: Bool
    ) throws -> InspectorBridgeSnapshotArtifact {
        let snapshotView: UIView

        switch InspectorSnapshotCapture.snapshotView(for: reference, afterScreenUpdates: afterScreenUpdates) {
        case let .success(view):
            snapshotView = view
        case let .failure(reason):
            throw InspectorBridgeError.snapshotUnavailable(reason.bridgeReason)
        }

        let bounds = CGRect(origin: .zero, size: snapshotView.bounds.size)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale

        let image = UIGraphicsImageRenderer(size: bounds.size, format: format).image { _ in
            snapshotView.frame = bounds
            snapshotView.drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }

        guard let pngData = image.pngData() else {
            throw InspectorBridgeError.snapshotUnavailable(.captureFailed)
        }

        let directory = inspectorSnapshotsDirectoryURL()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            os_log(.error, "inspector: failed to create snapshots directory at %{public}@: %{public}@",
                   directory.path, String(describing: error))
            throw InspectorBridgeError.snapshotUnavailable(.captureFailed)
        }

        let url = directory.appendingPathComponent("\(UUID().uuidString).png")
        do {
            try pngData.write(to: url, options: .atomic)
        } catch {
            os_log(.error, "inspector: failed to write snapshot PNG to %{public}@: %{public}@",
                   url.path, String(describing: error))
            throw InspectorBridgeError.snapshotUnavailable(.captureFailed)
        }

        pruneInspectorSnapshotsDirectory(limit: artifactLimitProvider())

        return InspectorBridgeSnapshotArtifact(
            handle: handle,
            pngURL: url,
            size: image.size,
            deviceScale: image.scale,
            createdAt: dateProvider()
        )
    }
}

func pruneInspectorSnapshotsDirectory(limit: Int) {
    let directory = inspectorSnapshotsDirectoryURL()
    let fileManager = FileManager.default

    guard
        let entries = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
    else {
        return
    }

    guard entries.count > max(limit, 0) else { return }

    let sorted = entries.sorted { lhs, rhs in
        let lhsDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
        let rhsDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
        return lhsDate < rhsDate
    }

    for url in sorted.prefix(sorted.count - max(limit, 0)) {
        try? fileManager.removeItem(at: url)
    }
}
```

Add an `import os.log` near the top of the file if it's not already imported (check: `grep '^import os' Sources/Inspector/Bridge/InspectorBridgeService.swift` — if empty, add it after the existing `import` lines).

- [ ] **Step 2: Inject the provider into the shared service construction**

In `Sources/Inspector/Bridge/InspectorBridgeService.swift`, locate the `sharedInspectorMCPBridgeService` let (around line 400) and extend its construction to pass the new renderer with the config-backed provider. Replace the existing `snapshotRenderer` default (currently omitted — renderer uses defaults) by constructing it explicitly with:

```swift
snapshotRenderer: InspectorBridgeSnapshotRenderer(
    artifactLimitProvider: {
        Inspector.sharedInstance.configuration.snapshotArtifactMaxCount
    }
)
```

If the `InspectorMCPBridgeService` init doesn't already accept `snapshotRenderer`, it already does — line 105 has `snapshotRenderer: InspectorBridgeSnapshotRendering = InspectorBridgeSnapshotRenderer()`. Update the call at the `sharedInspectorMCPBridgeService` site to pass the custom renderer.

- [ ] **Step 3: Unskip the existing bridge service test**

In `Tests/InspectorTests/InspectorBridgeServiceTests.swift`, remove the `try XCTSkipIf(true, "pending Task 6: …")` line added in Task 4.

- [ ] **Step 4: Write the ring-buffer test**

Append to `InspectorBridgeServiceTests.swift`:

```swift
func testSnapshotRendererPrunesOldestPNGs() throws {
    let fileManager = FileManager.default
    let directory = inspectorSnapshotsDirectoryURL()
    try? fileManager.removeItem(at: directory)

    let renderer = InspectorBridgeSnapshotRenderer(
        artifactLimitProvider: { 3 },
        dateProvider: Date.init
    )
    let reference = try makeTestReference() // existing test helper

    var urls: [URL] = []
    for _ in 0..<4 {
        let artifact = try renderer.snapshot(
            for: reference,
            handle: InspectorBridgeHandle(rawValue: UUID().uuidString),
            afterScreenUpdates: true
        )
        urls.append(artifact.pngURL)
        // Spread mtimes so the ring buffer ordering is deterministic.
        Thread.sleep(forTimeInterval: 0.05)
    }

    let remaining = try fileManager.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: nil
    )
    XCTAssertEqual(remaining.count, 3, "ring buffer must cap at 3 files")
    XCTAssertFalse(fileManager.fileExists(atPath: urls[0].path),
                   "oldest file should have been pruned")
    XCTAssertTrue(fileManager.fileExists(atPath: urls[3].path),
                  "newest file must remain")

    addTeardownBlock {
        try? fileManager.removeItem(at: directory)
    }
}
```

If the file has no `makeTestReference()` helper, substitute the simplest live-reference builder that other tests in this file use (grep for `reference:` patterns in the existing tests near lines 160–200 to find the local idiom).

- [ ] **Step 5: Run the full bridge service test class**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorBridgeServiceTests
```

Expected: PASS all (including the previously skipped artifact-existence test).

- [ ] **Step 6: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorBridgeService.swift Tests/InspectorTests/InspectorBridgeServiceTests.swift
git commit -m "feat(mcp): renderer writes PNG to disk with ring-buffer prune"
```

---

## Task 7: `Inspector.stop()` clears the snapshots directory

**Files:**
- Modify: `Sources/Inspector/Inspector.swift:79-88` (`stop()`)
- Test: `Tests/InspectorTests/InspectorBridgeServiceTests.swift` (new test)

- [ ] **Step 1: Write the failing test**

Append to `InspectorBridgeServiceTests.swift`:

```swift
func testInspectorStopClearsSnapshotsDirectory() throws {
    let fileManager = FileManager.default
    let directory = inspectorSnapshotsDirectoryURL()
    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    let sentinel = directory.appendingPathComponent("sentinel.png")
    try Data([0x89]).write(to: sentinel)

    Inspector.sharedInstance.stop()

    XCTAssertFalse(fileManager.fileExists(atPath: directory.path),
                   "Inspector.stop() must remove the snapshots directory")

    addTeardownBlock {
        Inspector.sharedInstance.start()
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorBridgeServiceTests/testInspectorStopClearsSnapshotsDirectory
```

Expected: FAIL — directory still exists after stop.

- [ ] **Step 3: Hook cleanup into `Inspector.stop()`**

In `Sources/Inspector/Inspector.swift`, inside the existing `#if INSPECTOR_DEBUGGING && targetEnvironment(simulator)` block in `stop()` (currently lines 85–87), extend it to:

```swift
#if INSPECTOR_DEBUGGING && targetEnvironment(simulator)
        resetInspectorBridgeState()
        cleanupInspectorSnapshotsDirectory()
#endif
```

- [ ] **Step 4: Run the test**

Same command as Step 2. Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/Inspector/Inspector.swift Tests/InspectorTests/InspectorBridgeServiceTests.swift
git commit -m "feat(mcp): Inspector.stop() clears the snapshots directory"
```

---

## Task 8: HTTP transport maps new response fields + sets `apiVersion`

**Files:**
- Modify: `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift:275-296` (`healthResponse()`)
- Modify: `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift:319-332` (`bridgeSnapshotResult`)
- Test: `Tests/InspectorTests/InspectorMCPTransportTests.swift` (rewrite snapshot envelope test + add new tests)

- [ ] **Step 1: Rewrite the snapshot envelope test**

In `Tests/InspectorTests/InspectorMCPTransportTests.swift`, locate `testSnapshotReturnsBase64PNGEnvelope` (grep `func testSnapshotReturnsBase64`) and replace the entire test with:

```swift
func testSnapshotReturnsPNGFilePathEnvelope() throws {
    let payload = try snapshotResponsePayload() // existing helper; returns [String: Any]
    guard let result = payload["result"] as? [String: Any] else {
        return XCTFail("missing result envelope")
    }

    let path = try XCTUnwrap(result["pngPath"] as? String)
    XCTAssertTrue(path.hasPrefix("/"), "pngPath must be absolute")
    XCTAssertTrue(FileManager.default.fileExists(atPath: path),
                  "pngPath must resolve to an existing file")

    let magic = try Data(contentsOf: URL(fileURLWithPath: path)).prefix(8)
    XCTAssertEqual(Array(magic), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
                   "artifact must be a valid PNG")

    XCTAssertEqual(result["mimeType"] as? String, "image/png")
    XCTAssertEqual(result["deviceScale"] as? Double, Double(UIScreen.main.scale))

    let createdAtString = try XCTUnwrap(result["createdAt"] as? String)
    let createdAt = try XCTUnwrap(ISO8601DateFormatter().date(from: createdAtString))
    XCTAssertLessThan(Date().timeIntervalSince(createdAt), 5,
                      "createdAt must be recent")
}
```

If the existing `snapshotResponsePayload()` helper doesn't exist, copy/inline whatever the old `testSnapshotReturnsBase64PNGEnvelope` used to get a response (it already drives the transport end-to-end).

- [ ] **Step 2: Add ring-buffer integration test**

Append to `InspectorMCPTransportTests.swift`:

```swift
func testSnapshotRingBufferEvictsOldestViaTransport() throws {
    Inspector.sharedInstance.configuration.snapshotArtifactMaxCount = 3

    let fileManager = FileManager.default
    let directory = inspectorSnapshotsDirectoryURL()
    try? fileManager.removeItem(at: directory)

    var paths: [String] = []
    for _ in 0..<4 {
        let payload = try snapshotResponsePayload()
        let path = try XCTUnwrap((payload["result"] as? [String: Any])?["pngPath"] as? String)
        paths.append(path)
        Thread.sleep(forTimeInterval: 0.05)
    }

    let remaining = try fileManager.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: nil
    )
    XCTAssertEqual(remaining.count, 3)
    XCTAssertFalse(fileManager.fileExists(atPath: paths[0]),
                   "oldest snapshot must have been pruned")

    addTeardownBlock {
        Inspector.sharedInstance.configuration.snapshotArtifactMaxCount = 32
        try? fileManager.removeItem(at: directory)
    }
}
```

- [ ] **Step 3: Add cleanup-on-stop integration test**

Append to `InspectorMCPTransportTests.swift`:

```swift
func testSnapshotCleanupOnInspectorStop() throws {
    _ = try snapshotResponsePayload()
    _ = try snapshotResponsePayload()

    let directory = inspectorSnapshotsDirectoryURL()
    XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))

    Inspector.sharedInstance.stop()

    XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path),
                   "snapshots directory must be gone after Inspector.stop()")

    addTeardownBlock {
        Inspector.sharedInstance.start()
    }
}
```

- [ ] **Step 4: Add `apiVersion` assertion to the existing health test**

Locate the existing health-response test (grep `func testHealth`) and extend its final assertions with:

```swift
XCTAssertEqual(result["apiVersion"] as? Int, 2)
```

- [ ] **Step 5: Run the three new/changed tests to verify they fail**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorMCPTransportTests/testSnapshotReturnsPNGFilePathEnvelope \
  -only-testing:InspectorTests/InspectorMCPTransportTests/testSnapshotRingBufferEvictsOldestViaTransport \
  -only-testing:InspectorTests/InspectorMCPTransportTests/testSnapshotCleanupOnInspectorStop
```

Expected: FAIL (the transport still emits `pngBase64` and has no `apiVersion`).

- [ ] **Step 6: Update `bridgeSnapshotResult`**

In `Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift`, replace the existing body of `bridgeSnapshotResult(for:)` (lines 319–332) with:

```swift
private func bridgeSnapshotResult(for request: InspectorMCPSnapshotRequest) throws -> InspectorMCPSnapshotResult {
    let artifact = try Inspector.bridgeSnapshot(
        .init(rawValue: request.handle),
        afterScreenUpdates: request.afterScreenUpdates
    )

    return InspectorMCPSnapshotResult(
        handle: artifact.handle.rawValue,
        mimeType: "image/png",
        pngPath: artifact.pngURL.path,
        size: .init(width: artifact.size.width.doubleValue, height: artifact.size.height.doubleValue),
        deviceScale: artifact.deviceScale.doubleValue,
        createdAt: artifact.createdAt
    )
}
```

- [ ] **Step 7: Update `healthResponse()` with `apiVersion`**

In the same file, update the returned `InspectorMCPHealthResponse` construction at the end of `healthResponse()` (around line 289) to include `apiVersion: 2`:

```swift
return InspectorMCPHealthResponse(
    status: status,
    bridgeEnabled: bridgeEnabled,
    inspectorStarted: inspectorStarted,
    bundleIdentifier: Bundle.main.bundleIdentifier,
    operations: [.query, .resolve, .snapshot],
    apiVersion: 2
)
```

- [ ] **Step 8: Run the same tests plus the existing transport suite**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorTests/InspectorMCPTransportTests
```

Expected: PASS all.

- [ ] **Step 9: Commit**

```bash
git add Sources/Inspector/Bridge/InspectorMCPHTTPTransport.swift Tests/InspectorTests/InspectorMCPTransportTests.swift
git commit -m "feat(mcp): transport emits pngPath + apiVersion=2"
```

---

## Task 9: MCP server session — version bump + tool description + field descriptions

**Files:**
- Modify: `Sources/InspectorMCPServer/InspectorMCPServerSession.swift:34-36` (`serverInfo.version`)
- Modify: `Sources/InspectorMCPServer/InspectorMCPServerSession.swift:120-137` (`snapshot` tool schema)
- Test: `Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift`

- [ ] **Step 1: Write the failing tests**

Append to `InspectorMCPServerTests.swift`:

```swift
func testInitializeResponseAdvertisesV2() throws {
    let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
    let request = #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}"#
    let response = try XCTUnwrap(try session.handleMessage(Data(request.utf8)))
    let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
    let result = try XCTUnwrap(object?["result"] as? [String: Any])
    let serverInfo = try XCTUnwrap(result["serverInfo"] as? [String: Any])
    XCTAssertEqual(serverInfo["version"] as? String, "2.0.0")
}

func testSnapshotToolDescriptionMentionsPngPath() throws {
    let session = InspectorMCPServerSession(bridgeClient: MockBridgeClient())
    let request = #"{"jsonrpc":"2.0","id":2,"method":"tools/list"}"#
    let response = try XCTUnwrap(try session.handleMessage(Data(request.utf8)))
    let object = try JSONSerialization.jsonObject(with: response) as? [String: Any]
    let result = try XCTUnwrap(object?["result"] as? [String: Any])
    let tools = try XCTUnwrap(result["tools"] as? [[String: Any]])
    let snapshotTool = try XCTUnwrap(tools.first { ($0["name"] as? String) == "snapshot" })

    let description = try XCTUnwrap(snapshotTool["description"] as? String)
    XCTAssertTrue(description.contains("pngPath"),
                  "description must mention pngPath so agents route to Read")

    let inputSchema = try XCTUnwrap(snapshotTool["inputSchema"] as? [String: Any])
    let properties = try XCTUnwrap(inputSchema["properties"] as? [String: Any])
    let handle = try XCTUnwrap(properties["handle"] as? [String: Any])
    let afterScreenUpdates = try XCTUnwrap(properties["afterScreenUpdates"] as? [String: Any])
    XCTAssertNotNil(handle["description"], "handle must have a description")
    XCTAssertNotNil(afterScreenUpdates["description"], "afterScreenUpdates must have a description")
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorMCPServerTests/InspectorMCPServerTests/testInitializeResponseAdvertisesV2 \
  -only-testing:InspectorMCPServerTests/InspectorMCPServerTests/testSnapshotToolDescriptionMentionsPngPath
```

Expected: FAIL — version is `1.0.0`; description omits `pngPath`; properties have no `description`.

- [ ] **Step 3: Bump version**

In `Sources/InspectorMCPServer/InspectorMCPServerSession.swift`, around line 36, change:

```swift
"version": "1.0.0"
```

to:

```swift
"version": "2.0.0"
```

- [ ] **Step 4: Rewrite snapshot tool description + per-field descriptions**

Still in `InspectorMCPServerSession.swift`, locate the `snapshot` tool definition in the `tools/list` response (around lines 120–137). Replace the tool dictionary with:

```swift
[
    "name": "snapshot",
    "description": "Capture a PNG snapshot for a handle. Returns an absolute host file path — use the Read tool on pngPath to load image bytes.",
    "inputSchema": [
        "type": "object",
        "properties": [
            "handle": [
                "type": "string",
                "description": "Opaque handle returned by query or resolve."
            ],
            "afterScreenUpdates": [
                "type": "boolean",
                "description": "Whether to flush pending view updates before capture. Default true."
            ]
        ],
        "required": ["handle", "afterScreenUpdates"]
    ]
]
```

- [ ] **Step 5: Run the tests**

Same commands as Step 2. Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add Sources/InspectorMCPServer/InspectorMCPServerSession.swift Tests/InspectorMCPServerTests/InspectorMCPServerTests.swift
git commit -m "feat(mcp): v2 server — pngPath tool description and per-field schemas"
```

---

## Task 10: Plugin skill and docs update

**Files:**
- Modify: `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md`
- Modify: `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md`
- Modify: `Plugins/inspector-mcp/README.md`

No tests — documentation only. Keep the wording aligned with the MCP tool description set in Task 9.

- [ ] **Step 1: Update `SKILL.md`**

In `Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md`, replace the existing "Good first query" / snapshot workflow section's snapshot example (around "Snapshot usage") with:

```markdown
Snapshot request:

```json
{"handle":"HANDLE","afterScreenUpdates":true}
```

Response:

```json
{"handle":"HANDLE","mimeType":"image/png","pngPath":"/Users/you/Library/Developer/CoreSimulator/…/tmp/inspector-snapshots/<uuid>.png","size":{"width":402,"height":874},"deviceScale":3,"createdAt":"2026-04-17T13:03:29Z"}
```

After receiving the response, read the PNG with your file-reading tool (Claude Code: `Read pngPath`). Do not base64-decode — the bytes live on disk, not inline.
```

After that section, add a new "Breaking changes" heading at the end of the skill body:

```markdown
## Breaking changes

- **v2 (2026-04-17)** — The `snapshot` tool response no longer carries `pngBase64`. It now returns `pngPath` (absolute host path) and `createdAt`; `scale` was renamed to `deviceScale`. Restart your MCP clients (Codex, Claude Code) after upgrading Inspector — in-flight sessions keep the old schema until reconnected.
```

- [ ] **Step 2: Update `references/inspection-patterns.md`**

In `Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md`, find the "Snapshot Usage" section and replace the existing JSON + "Rules" block with:

```markdown
## Snapshot Usage

Snapshot request:

```json
{"handle":"HANDLE","afterScreenUpdates":true}
```

Response shape (v2):

```json
{"handle":"HANDLE","mimeType":"image/png","pngPath":"/absolute/host/path/inspector-snapshots/<uuid>.png","size":{"width":402,"height":874},"deviceScale":3,"createdAt":"2026-04-17T13:03:29Z"}
```

Rules:
- `afterScreenUpdates` is required; use `true` unless you have a concrete reason not to.
- `pngPath` is an absolute host filesystem path. Read it directly — do not try to decode base64.
- Paths are ephemeral (live under the simulator sandbox `tmp/`). Consume immediately; do not cache across simulator resets or reinstalls.
```

- [ ] **Step 3: Update `Plugins/inspector-mcp/README.md`**

Add a "Versions" section near the top of `Plugins/inspector-mcp/README.md`, right after the introductory paragraph:

```markdown
## Versions

- **v2 (2026-04-17)** — snapshot returns `pngPath` (disk file) instead of `pngBase64`. Requires restarting MCP clients after upgrading Inspector. See `docs/superpowers/specs/2026-04-17-snapshot-disk-path-design.md`.
- **v1** — initial release.
```

- [ ] **Step 4: Sanity-check that the example values match the tool**

Grep the docs to make sure no reference to `pngBase64` remains:

```bash
grep -rn "pngBase64" Plugins/inspector-mcp/ docs/
```

Expected: only references inside design spec / release notes that mention the old behavior by name. If any instruction still tells the agent to decode base64, fix it.

- [ ] **Step 5: Commit**

```bash
git add Plugins/inspector-mcp/skills/inspector-mcp/SKILL.md Plugins/inspector-mcp/skills/inspector-mcp/references/inspection-patterns.md Plugins/inspector-mcp/README.md
git commit -m "docs(inspector-mcp): v2 snapshot contract and restart-client guidance"
```

---

## Post-plan verification

After all 10 tasks land:

- [ ] Build the library target and the executable cleanly:

```bash
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
swift build --target Inspector --sdk "$SDK" --triple arm64-apple-ios26.4-simulator
swift build --product InspectorMCPServer
```

- [ ] Run the full affected test surface end-to-end:

```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4' \
  -only-testing:InspectorMCPWireTests \
  -only-testing:InspectorMCPServerTests \
  -only-testing:InspectorTests/InspectorBridgeServiceTests \
  -only-testing:InspectorTests/InspectorMCPTransportTests \
  -only-testing:InspectorTests/InspectorConfigurationTests
```

- [ ] Live dogfooding: restart Claude Code's MCP connection (`/mcp` reconnect). Call `snapshot` on a live handle and verify the returned `pngPath` renders inline via `Read`.

- [ ] Follow-up issue: restore `swift test` compatibility. Today `Tests/InspectorMCPServerTests` does `@testable import InspectorMCPServer`, which is not permitted on a SwiftPM executable target; the fallback cascade also fails to build `Sources/Inspector/**` on the host because UIKit is iOS-only. The clean fix is to split `InspectorMCPServer` into a testable library target plus a thin `@main` executable shim, and guard any host-only tests explicitly. Tracked as out of scope for this plan; raise a separate issue before merging.
