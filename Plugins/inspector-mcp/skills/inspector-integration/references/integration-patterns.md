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

## Consumer customization
Use `InspectorCustomizationProviding` to register app-specific libraries and behaviors instead of patching Inspector internals directly.

## Useful source references in this repo
- `README.md` integration examples
- `Example/Example/SceneDelegate.swift`
- `Sources/Inspector/Protocols/InspectorCustomizationProviding.swift`
