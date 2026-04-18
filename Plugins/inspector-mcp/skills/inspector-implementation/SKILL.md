---
name: inspector-implementation
description: Use when an agent needs to implement or modify the Inspector library itself — panel UI, hierarchy/runtime behavior, custom property models, macros, or Example-app dogfooding. Especially useful when changing `Sources/Inspector/`, `Sources/InspectorInterface/`, or `Sources/InspectorMacros/` and you need the repo's architecture and verification workflow in one place.
---

# Inspector Implementation

## Overview

Use this skill when the work is **inside the Inspector repo**, not in a consumer app. Typical tasks:
- changing runtime behavior in `Sources/Inspector/`
- adding or adjusting Inspector UI panels
- extending custom property/action flows
- changing macro-generated Inspector integration (`@InspectorPanel`, `@InspectorProperty`)
- dogfooding changes through the Example app

## Fast architecture map

Start from these zones:
- `Sources/Inspector/Manager/` — top-level orchestration and presentation flow
- `Sources/Inspector/ViewHierarchy/` — live hierarchy capture and element references
- `Sources/Inspector/ElementInspector/` — element panel UI and interactions
- `Sources/Inspector/ElementLibraries/` — per-type property/section definitions
- `Sources/Inspector/Bridge/` — Inspector MCP bridge/runtime semantic layer
- `Sources/InspectorInterface/` — public macro declarations / debug-facing interface surface
- `Sources/InspectorMacros/` — macro expansion logic
- `Example/Example/` — dogfooding app and runtime verification target

## When touching specific features

### Runtime / bridge / semantic tooling
Look first in:
- `Sources/Inspector/Bridge/`
- `Tests/InspectorTests/InspectorBridgeServiceTests.swift`
- `Tests/InspectorTests/InspectorMCPTransportTests.swift`
- `Tests/InspectorMCPServerTests/`
- `Tests/InspectorMCPWireTests/`

### Panel UI / element inspector behavior
Look first in:
- `Sources/Inspector/ElementInspector/`
- `Sources/Inspector/CommonUI/`
- `Sources/Inspector/TransitionCoordinator/`

### Built-in editable properties / sections
Look first in:
- `Sources/Inspector/ElementLibraries/Sections/`
- `Sources/Inspector/Extensions/InspectorElementViewModelProperty/`

### Customer-extensibility / macros
Look first in:
- `Sources/InspectorInterface/`
- `Sources/InspectorMacros/`
- `Example/Example/PlaygroundViewController.swift`
- `Example/Example/RoundedButton.swift`

## Verification

### SwiftPM/server-side verification
```bash
swift build --product InspectorMCPServer
swift build --target InspectorMCPWireTests
swift build --target InspectorMCPServerTests
```

### Example app / iOS verification
```bash
xcodebuild test \
  -project Example/Example.xcodeproj \
  -scheme Example \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.4.1'
```

Prefer focused `-only-testing:` runs while iterating, then broaden when the slice stabilizes.

## References

Read only when needed:
- `references/architecture.md`
