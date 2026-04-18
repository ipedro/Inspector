---
name: inspector-integration
description: Use when an agent needs to integrate the Inspector library into an app without focusing on the MCP bridge: startup wiring, configuration/customization, debug-only gating, and custom panel registration. Especially useful when patching another iOS app to call `Inspector.start()` correctly and optionally register custom Inspector libraries.
---

# Inspector Integration

## Overview

Use this skill when integrating **Inspector the library** into a consumer app.
This is broader than MCP bridge setup and applies even when the app only needs:
- `Inspector.start()` / `Inspector.stop()`
- configuration via `InspectorConfiguration`
- customization via `InspectorCustomizationProviding`
- debug-only custom panels/libraries/macros

## Core startup pattern

The safe baseline is:

```swift
Inspector.setConfiguration(...)
Inspector.setCustomization(...)
Inspector.start()
```

Do configuration/customization **before** `Inspector.start()`.

## Typical integration tasks
- add Inspector startup to UIKit or SwiftUI app entry points
- keep startup debug-only
- register custom libraries/panels through `InspectorCustomizationProviding`
- verify Example-like integration patterns in another app
- preserve existing app startup behavior while inserting Inspector cleanly

## Common entry points
- UIKit lifecycle: `SceneDelegate.scene(_:willConnectTo:)`
- older UIKit lifecycle: `AppDelegate`
- SwiftUI lifecycle: `@main App` / app delegate adaptor or debug bootstrap path

## Debug-only guidance
Prefer keeping Inspector setup in debug-only code paths so release builds stay clean.
If the consumer app uses macro-based custom panels, ensure the same debug trait/build gating applies consistently.

## Verification
- app launches with Inspector enabled
- no duplicate `Inspector.start()` calls
- configuration/customization are applied before startup
- custom panels/libraries appear when expected

## References
Read only when needed:
- `references/integration-patterns.md`
