# Inspector compatibility layer

This directory contains the temporary compatibility bridge for the deprecated
`InspectorElementProperty`-based authoring model.

## Purpose

The modern Inspector runtime is binding-native:

- section authoring uses `InspectorPropertyBinding`
- public schema uses `InspectorContract`
- runtime editing/rendering flows through bindings first

The files in this directory exist only to preserve backward compatibility while
older downstream code migrates.

## Files

- `InspectorElementProperty.swift`
  - deprecated legacy property enum and associated types
- `InspectorPropertyBinding+Legacy.swift`
  - conversion bridge between bindings and legacy properties
- `InspectorElementSectionDataSource+Legacy.swift`
  - deprecated section-data-source fallback requirements and defaults
- `InspectorLegacyTypealiases.swift`
  - deprecated compatibility aliases

## Removal rule

Before deleting this directory, run:

```bash
./Tools/compatibility/audit-legacy-bridge.sh --strict
./Tools/compatibility/audit-legacy-bridge.sh --json
```

Deletion should only proceed when:

- `non_compatibility_refs == 0`
- the remaining references are expected compatibility-only references

## Current status

See:

- `docs/plans/2026-04-19-inspector-legacy-removal-checklist.md`
- `Tools/compatibility/audit-legacy-bridge.sh`

This directory is migration-only and should shrink to zero.
