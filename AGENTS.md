# Inspector — Agent Reference

iOS in-app debugging library (Swift Package Manager, iOS 14+, Swift 5.10).

## Commands

```bash
# Build
swift build

# Test
swift test

# Run single test
swift test --filter <TestName>
```

## Architecture

**Entry point:** `Sources/Inspector/Inspector.swift` — singleton facade (`Inspector.sharedInstance`) with a static API: `start()`, `stop()`, `present(animated:)`, `inspect(_:)`, `setConfiguration(_:)`, `setCustomization(_:)`.

**Key modules under `Sources/Inspector/`:**

| Directory | Role |
|---|---|
| `Manager/` | Orchestrates all subsystems |
| `ViewHierarchy/` | Snapshot & traversal of the UIView tree |
| `ElementInspector/` | Panel UI for inspecting individual elements (children, attributes, size, preview) |
| `ElementLibraries/` | Data-source definitions for each inspectable UIKit type |
| `Configuration/` | `InspectorConfiguration` + `InspectorAppearance` (user-facing settings) |
| `Protocols/` | Public extensibility points — implement these to add custom panels/providers |
| `CommonUI/` | Reusable controls, base classes, icon kit |
| `Extensions/` | UIKit protocol conformances (`CaseIterable`, `CustomStringConvertible`, etc.) |

**Dependencies:** `UIKeyCommandTableView`, `UIKeyboardAnimatable`, `Coordinator` (all first-party, via SPM).

**Example app:** `Example/Example.xcodeproj` — demonstrates integration patterns.
