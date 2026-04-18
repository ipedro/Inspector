# Inspector Implementation Reference

## Entry points
- `Sources/Inspector/Inspector.swift` — singleton API (`start`, `stop`, `present`, `inspect`, config/customization setters)
- `Sources/Inspector/Manager/Manager.swift` — runtime state and coordinator ownership

## Key runtime seams
- `Manager+ElementInspectorCoordinatorDelegate.swift` — Inspector panel presentation
- `Manager+ViewHierarchyActionableProtocol.swift` — action execution for hierarchy elements
- `Bridge/InspectorBridgeService.swift` — MCP/runtime semantic layer
- `ViewHierarchy/` types — live node/reference model

## Extensibility seams
- `InspectorCustomizationProviding` in `Sources/Inspector/Protocols/`
- `ElementLibraries/` for built-in and custom panel sections
- `InspectorInterface` + `InspectorMacros` for macro-driven consumer ergonomics

## Good verification habits
- keep Example app behavior stable unless the product surface intentionally changes
- add focused tests in the nearest layer first (wire/server/service/live transport)
- prefer additive, typed contracts over ad hoc view poking
