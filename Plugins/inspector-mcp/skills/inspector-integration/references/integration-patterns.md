# Inspector Integration Patterns

## Minimal startup
```swift
Inspector.start()
```

## Startup with config/customization
```swift
Inspector.setConfiguration(...)
Inspector.setCustomization(...)
Inspector.start()
```

## Good rules
- configure before start
- keep integration debug-only when appropriate
- avoid multiple startup paths calling `Inspector.start()` independently
- preserve existing app-specific customization hooks

## Macro-based integration

If the consumer app adopts `@InspectorPanel` / `@InspectorProperty`:

```swift
import InspectorInterface
import Inspector
```

Use `InspectorInterface` for the annotations themselves. Import `Inspector` in the same file when:
- generated code needs runtime Inspector types
- the file also calls `Inspector.start()` / `setConfiguration` / `setCustomization`

Rules:
- avoid wrapping `@InspectorProperty` so aggressively that the macro expander cannot see it
- prefer debug-only gating around startup/bootstrap code rather than hiding the annotation declaration
- make sure the app target links the needed Inspector package products for debug builds

## Consumer customization
Use `InspectorCustomizationProviding` to register app-specific libraries and behaviors instead of patching Inspector internals directly.

## Useful source references in this repo
- `README.md` integration examples
- `Example/Example/SceneDelegate.swift`
- `Sources/Inspector/Protocols/InspectorCustomizationProviding.swift`
