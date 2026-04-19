# Inspector legacy bridge removal checklist

Status: completed.

This document records the final deletion of the deprecated `InspectorElementProperty`
compatibility layer and the acceptance checks used to verify removal.

## Final result

The compatibility bridge has been removed.

Current audited state:

- `non_compatibility_refs = 0`
- `compatibility_refs = 0`

Verified with:

```bash
./Tools/compatibility/audit-legacy-bridge.sh --strict
./Tools/compatibility/audit-legacy-bridge.sh --strict --json
```

## What was deleted

Removed in the final pass:

- `Sources/Inspector/Compatibility/InspectorElementProperty.swift`
- `Sources/Inspector/Compatibility/InspectorPropertyBinding+Legacy.swift`
- `Sources/Inspector/Compatibility/InspectorElementSectionDataSource+Legacy.swift`
- `Sources/Inspector/Compatibility/InspectorLegacyTypealiases.swift`
- `Sources/Inspector/Compatibility/README.md`
- `Tests/InspectorTests/Compatibility/InspectorLegacyCompatibilityTests.swift`

Also removed:

- legacy inheritance from `InspectorElementSectionDataSource`
- section-data-source fallback property semantics from the modern path

## Verification targets used

```bash
./Tools/compatibility/audit-legacy-bridge.sh --strict --json
swift build --target InspectorMacrosTests
swift build --target Inspector --sdk $(xcrun --sdk iphonesimulator --show-sdk-path) --triple arm64-apple-ios26.4-simulator
```

Focused simulator checks used during removal:

- `InspectorAutobuiltPanelTests/testButtonAttributesSectionUsesBindingsAndMutatesBehavior`
- `InspectorAutobuiltPanelTests/testAutobuiltSectionIncludesInheritedStoredProperties`
- `InspectorBridgeServiceTests/testBridgeListPropertiesProjectsSupportedEditableProperties`

## Notes

- The audit script remains useful as a regression guard against reintroducing a
  compatibility-only property path.
- Deprecated UIKit warnings are separate cleanup work and were not treated as blockers
  for the compatibility-layer removal.
