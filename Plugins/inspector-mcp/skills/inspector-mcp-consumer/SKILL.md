---
name: inspector-mcp-consumer
description: Use when an agent needs to patch a consumer iOS app so it exposes the Inspector MCP bridge, add or verify the app-side Inspector startup configuration, or choose the correct UIKit or SwiftUI lifecycle entry point for `enableMCPBridge`, `snapshotExpiration = 300`, and `snapshotMaxCount = 8`. Especially useful when preparing another app to be driven by `InspectorMCPServer` and then handed off to the `inspector-mcp` skill for live inspection.
---

# Inspector MCP Consumer

## Overview

Use this skill to wire a consuming iOS app so the Inspector MCP server can launch it and inspect its live hierarchy. This skill is about app integration, not MCP registration or live querying.

## Workflow

### 1. Confirm the app already depends on Inspector

Before editing startup code, verify the consumer app actually includes the `Inspector` package.

Look for:
- `import Inspector`
- SwiftPM package reference to Inspector
- Xcode target dependency on the package product

If the app does not depend on Inspector yet, add the package first before trying to wire the bridge.

### 2. Find the real startup point

Do not add a second, parallel initialization path.

Patch the existing app startup path:
- UIKit + scenes: `SceneDelegate.scene(_:willConnectTo:options:)`
- UIKit without scenes: `AppDelegate.application(_:didFinishLaunchingWithOptions:)`
- SwiftUI app lifecycle: prefer a `UIApplicationDelegateAdaptor` bridge instead of ad hoc scattered startup calls

Read [entry-points.md](references/entry-points.md) for concrete patterns.

### 3. Insert the bridge configuration before `Inspector.start()`

Required configuration:

```swift
var configuration = InspectorConfiguration.config(
    enableMCPBridge: true,
    snapshotExpiration: 300
)
configuration.snapshotMaxCount = 8
Inspector.setConfiguration(configuration)
Inspector.start()
```

Rules:
- call `Inspector.setConfiguration` before `Inspector.start()`
- use `snapshotExpiration = 300`
- set `snapshotMaxCount = 8`
- keep existing `Inspector.setCustomization(...)` or other app-specific Inspector wiring intact

If the app already calls `Inspector.start()`, patch that path instead of adding another one.

### 4. Preserve the app's current structure

Prefer the smallest possible diff:
- reuse the existing startup object
- preserve existing customization hooks
- preserve existing debug-only gating if the app already has it
- do not introduce a new abstraction unless the current lifecycle is genuinely fragmented

### 5. Verify the app is now launchable by the MCP server

At minimum, verify:
- the app builds for Simulator
- the startup path compiles with the new Inspector config
- the app still launches

If you are in the Inspector repo, the Example app pattern in:
- `<Inspector repo>/Example/Example/SceneDelegate.swift`

is the reference shape for a scene-based UIKit app.

Read [verification.md](references/verification.md) for the verification checklist.

### 6. Hand off to live inspection

Once the consumer app is patched, switch to the sibling `inspector-mcp` skill.

That skill covers:
- deriving the Inspector package path
- registering the MCP server in Codex or Claude
- using `query`, `resolve`, and `snapshot`

## Constraints

- This skill does not cover mutation APIs
- This skill does not cover physical-device support
- This skill does not cover multi-app or multi-session setup
- This skill is only about making the consumer app expose the read-only v1 bridge correctly

## References

Read only as needed:
- [entry-points.md](references/entry-points.md) for UIKit and SwiftUI startup placement
- [verification.md](references/verification.md) for build and launch checks
