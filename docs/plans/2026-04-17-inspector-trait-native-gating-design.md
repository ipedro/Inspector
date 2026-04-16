# Inspector Trait-Native Gating Design

## Goal
Replace the legacy `INSPECTOR_ENABLED` compile-time contract repo-wide with a single trait-backed symbol that reflects the `Debugging` trait directly, without changing the runtime/product behavior of Inspector.

## Decision
Adopt one new compile-time symbol: `INSPECTOR_DEBUGGING`.

`INSPECTOR_DEBUGGING` becomes the only conditional-compilation symbol used for Inspector’s trait-gated code paths. It is defined exclusively from the SwiftPM `Debugging` trait in `Package.swift`.

## Why This Design
- The current `INSPECTOR_ENABLED` name is historical and no longer describes the actual mechanism.
- The repo already has a first-class `Debugging` trait in `Package.swift`.
- A single repo-wide rename is lower-risk than introducing multiple new symbols or keeping a compatibility shim.
- This preserves the current conditional-compilation model used by:
  - macro-generated code
  - interface/runtime bridge surface
  - example/library integration points
  - macro snapshot tests

## In Scope
- `Package.swift` symbol definition changes
- Macro source updates so generated code emits `#if INSPECTOR_DEBUGGING`
- Macro test expectation updates
- Source-level replacement of `#if INSPECTOR_ENABLED` with `#if INSPECTOR_DEBUGGING`
- Bridge/runtime/example wiring updates that rely on the symbol
- Verification that the existing debug/simulator behavior still works after the rename

## Out of Scope
- Changing trait names
- Removing conditional compilation entirely
- Introducing multiple compile-time symbols
- Re-architecting the bridge/runtime beyond what is needed for the symbol migration

## Architecture
The compile-time model remains:

`Debugging trait -> Package.swift .define(...) -> source/macro conditional compilation`

Only the symbol name changes.

The intended end state is:
- `Package.swift` defines `INSPECTOR_DEBUGGING` when the `Debugging` trait is enabled
- all source and generated code checks `#if INSPECTOR_DEBUGGING`
- `INSPECTOR_ENABLED` no longer exists anywhere in the repo

## Alternatives Considered

### Option A: One new trait-backed symbol
Recommended.

Pros:
- Minimal conceptual change
- Smallest migration surface
- Keeps existing codegen and conditional-compilation patterns intact

Cons:
- Still uses a custom compile-time symbol rather than pure package-structure separation

### Option B: Two or more new symbols
Rejected.

Pros:
- More semantic precision between runtime/interface/macro lanes

Cons:
- More migration work
- Easier to misconfigure
- No clear payoff for the current repo shape

### Option C: Keep `INSPECTOR_ENABLED` as compatibility alias
Rejected.

Pros:
- Lower immediate churn

Cons:
- Prolongs the legacy mechanism
- Weakens the cleanup goal
- Creates mixed vocabulary across source and generated output

## File Groups Affected

### Manifest
- `Package.swift`

### Macros and Macro Tests
- `Sources/InspectorMacros/InspectorPanelMacro.swift`
- `Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift`

### Interface / Runtime / Example
- `Sources/InspectorInterface/InspectorPanel.swift`
- `Sources/InspectorInterface/InspectorBridge.swift`
- `Sources/Inspector/Inspector.swift`
- `Sources/Inspector/Bridge/InspectorBridgeTypes.swift`
- `Sources/Inspector/Bridge/InspectorBridgeService.swift`
- `Example/Example/ElementLibrary/ExampleAttributesLibrary.swift`

## Migration Order
1. Change `Package.swift` to define only `INSPECTOR_DEBUGGING` from the `Debugging` trait.
2. Update macro generation to emit `#if INSPECTOR_DEBUGGING`.
3. Update macro tests to expect the new symbol.
4. Replace all source-level `#if INSPECTOR_ENABLED` checks with `#if INSPECTOR_DEBUGGING`.
5. Run focused verification on macro tests and the iOS simulator test lane.

## Acceptance Criteria
- `INSPECTOR_ENABLED` no longer appears anywhere in the repo.
- `Package.swift` is the single source of truth for the new symbol.
- Macro-generated output uses `#if INSPECTOR_DEBUGGING`.
- Existing debug/simulator bridge surface still compiles and tests pass.
- No behavior change beyond the compile-time contract rename.

## Risks
- Macro snapshot tests will fail until regenerated expectations are updated.
- Example and bridge lanes may silently compile out if the manifest and source guards drift.
- A partial rename could leave source and generated code using different symbols.

## Mitigations
- Make the manifest change first.
- Update macro generator and macro tests in the same pass.
- Use a repo-wide search as a hard gate before claiming completion.
- Re-run the existing simulator test lane after the rename.

## Verification
- `rg -n "INSPECTOR_ENABLED|INSPECTOR_DEBUGGING" Package.swift Sources Tests Example`
- macro tests
- `xcodebuild test -project Example/Example.xcodeproj -scheme Example -destination 'id=<sim-udid>' -only-testing:InspectorTests`

## Notes
This is a compile-time contract cleanup, not a functional feature. The correct bar is “same behavior, clearer mechanism.”
