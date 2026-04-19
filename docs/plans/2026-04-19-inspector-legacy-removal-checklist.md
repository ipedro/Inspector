# Inspector legacy bridge removal checklist

This document tracks the final deletion path for the deprecated `InspectorElementProperty` compatibility layer.

## Current state

As of this checkpoint:

- `ElementLibraries/Sections/**` are binding-native
- example custom section authoring is binding-native
- ordinary bridge/test fixtures are binding-native
- compatibility code is isolated under `Sources/Inspector/Compatibility/`
- explicit compatibility assertions are isolated in `Tests/InspectorTests/InspectorLegacyCompatibilityTests.swift`
- `Tools/compatibility/audit-legacy-bridge.sh --strict` reports `non_compatibility_refs=0`

## Compatibility files still in play

- `Sources/Inspector/Compatibility/InspectorElementProperty.swift`
- `Sources/Inspector/Compatibility/InspectorPropertyBinding+Legacy.swift`
- `Sources/Inspector/Compatibility/InspectorElementSectionDataSource+Legacy.swift`
- `Sources/Inspector/Compatibility/InspectorLegacyTypealiases.swift`
- `Tests/InspectorTests/InspectorLegacyCompatibilityTests.swift`

## Required preflight before deletion

Run:

```bash
./Tools/compatibility/audit-legacy-bridge.sh --strict
./Tools/compatibility/audit-legacy-bridge.sh --json
```

Deletion should not proceed if `non_compatibility_refs` is non-zero.

## Removal sequence

1. Delete `Tests/InspectorTests/InspectorLegacyCompatibilityTests.swift`
2. Delete `Sources/Inspector/Compatibility/InspectorLegacyTypealiases.swift`
3. Delete `Sources/Inspector/Compatibility/InspectorElementSectionDataSource+Legacy.swift`
4. Delete `Sources/Inspector/Compatibility/InspectorPropertyBinding+Legacy.swift`
5. Delete `Sources/Inspector/Compatibility/InspectorElementProperty.swift`
6. Remove the `InspectorElementSectionLegacyDataSource` inheritance from `InspectorElementSectionDataSource`
7. Rebuild `Inspector`, `InspectorMacrosTests`, and focused Example simulator tests
8. Re-run the audit script and confirm both counters are zero

## Verification targets

Minimum:

```bash
swift build --target InspectorMacrosTests
swift build --target Inspector --sdk $(xcrun --sdk iphonesimulator --show-sdk-path) --triple arm64-apple-ios26.4-simulator
```

Focused simulator checks:

- `InspectorPropertyBindingTests`
- `InspectorBridgeServiceTests`
- `InspectorAutobuiltPanelTests`

## Notes

The final deletion pass should be kept separate from unrelated warning cleanup.
Warnings around deprecated UIKit APIs are orthogonal and should not block removal of the compatibility bridge.

## Audit gate

Use the audit script before and after deletion:

```bash
./Tools/compatibility/audit-legacy-bridge.sh --strict
./Tools/compatibility/audit-legacy-bridge.sh --json
```

Expected before deletion:
- `non_compatibility_refs = 0`
- `compatibility_refs > 0`

Expected after deletion:
- `non_compatibility_refs = 0`
- `compatibility_refs = 0`

Use the `compatibility_by_file` breakdown from `--json` output to decide deletion order and to confirm that counts drop where expected after each removal step.
