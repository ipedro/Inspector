# Inspector Trait-Native Gating Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the legacy `INSPECTOR_ENABLED` compile-time contract repo-wide with a single trait-backed symbol, `INSPECTOR_DEBUGGING`, without changing Inspector behavior.

**Architecture:** Keep the current conditional-compilation model, but make `Package.swift` the single source of truth for a new trait-native symbol. Update macro generation, macro expectations, and all source guards in one bounded pass so generated code and runtime code stay aligned.

**Tech Stack:** SwiftPM traits, Swift macros, XCTest, Xcode simulator test lane

---

### Task 1: Update The Manifest Contract

**Files:**
- Modify: `Package.swift`
- Test: repo-wide grep verification

**Step 1: Replace the symbol definition**

Change the manifest so the repo defines `INSPECTOR_DEBUGGING` from the `Debugging` trait and stops defining `INSPECTOR_ENABLED`.

**Step 2: Verify the old symbol is gone from the manifest**

Run:

```bash
rg -n "INSPECTOR_ENABLED|INSPECTOR_DEBUGGING" Package.swift
```

Expected:
- `INSPECTOR_ENABLED` absent
- `INSPECTOR_DEBUGGING` present in the relevant target `swiftSettings`

**Step 3: Commit**

```bash
git add Package.swift
git commit -m "Align Inspector compile gating with the Debugging trait

Replace the legacy INSPECTOR_ENABLED symbol with a single
trait-backed INSPECTOR_DEBUGGING contract in the SwiftPM
manifest so the repo has one source of truth for debug-only
Inspector code paths.

Constraint: Must preserve current trait-based package behavior
Rejected: Compatibility alias for INSPECTOR_ENABLED | prolongs legacy contract
Confidence: high
Scope-risk: narrow
Directive: Keep macro output and source guards on the same symbol
Tested: rg verification of manifest symbol definitions
Not-tested: downstream compile lanes"
```

### Task 2: Update Macro Emission

**Files:**
- Modify: `Sources/InspectorMacros/InspectorPanelMacro.swift`
- Test: `Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift`

**Step 1: Change generated conditional compilation**

Update the macro so generated code emits `#if INSPECTOR_DEBUGGING` instead of `#if INSPECTOR_ENABLED`.

**Step 2: Update macro test expectations**

Adjust all expected expansions in `InspectorPanelMacroTests.swift` to the new symbol.

**Step 3: Run macro tests**

Run:

```bash
xcodebuild test -project Example/Example.xcodeproj -scheme Example -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorMacrosTests
```

Expected:
- macro tests pass

**Step 4: Commit**

```bash
git add Sources/InspectorMacros/InspectorPanelMacro.swift Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift
git commit -m "Keep generated Inspector code on the trait-native symbol

Update macro emission and snapshot-style expectations so
generated Inspector code uses INSPECTOR_DEBUGGING consistently
with the manifest contract.

Constraint: Generated and hand-written code must share one symbol
Rejected: Leave generated output on legacy symbol | contract drift
Confidence: high
Scope-risk: narrow
Directive: Any future macro that gates Inspector runtime should emit INSPECTOR_DEBUGGING
Tested: Inspector macro tests
Not-tested: runtime consumers"
```

### Task 3: Replace Source Guards Repo-Wide

**Files:**
- Modify: `Sources/InspectorInterface/InspectorPanel.swift`
- Modify: `Sources/InspectorInterface/InspectorBridge.swift`
- Modify: `Sources/Inspector/Inspector.swift`
- Modify: `Sources/Inspector/Bridge/InspectorBridgeTypes.swift`
- Modify: `Sources/Inspector/Bridge/InspectorBridgeService.swift`
- Modify: `Example/Example/ElementLibrary/ExampleAttributesLibrary.swift`
- Test: repo-wide grep verification

**Step 1: Replace all source-level guards**

Change every remaining `#if INSPECTOR_ENABLED` check in source/example code to `#if INSPECTOR_DEBUGGING`.

**Step 2: Verify no legacy guards remain**

Run:

```bash
rg -n "INSPECTOR_ENABLED|INSPECTOR_DEBUGGING" Package.swift Sources Tests Example
```

Expected:
- `INSPECTOR_ENABLED` absent everywhere
- `INSPECTOR_DEBUGGING` present everywhere the guard is still needed

**Step 3: Commit**

```bash
git add Sources/InspectorInterface/InspectorPanel.swift Sources/InspectorInterface/InspectorBridge.swift Sources/Inspector/Inspector.swift Sources/Inspector/Bridge/InspectorBridgeTypes.swift Sources/Inspector/Bridge/InspectorBridgeService.swift Example/Example/ElementLibrary/ExampleAttributesLibrary.swift
git commit -m "Replace legacy Inspector compile guards repo-wide

Rename all remaining source-level conditional compilation checks
to INSPECTOR_DEBUGGING so the manifest, runtime, interface, and
example wiring all use the same trait-backed contract.

Constraint: No behavioral change beyond compile-time contract rename
Rejected: Partial rename | leaves source and generated code inconsistent
Confidence: high
Scope-risk: moderate
Directive: Do not reintroduce INSPECTOR_ENABLED in new code
Tested: repo-wide grep verification
Not-tested: simulator runtime"
```

### Task 4: Run Runtime Regression Verification

**Files:**
- Test: `Tests/InspectorTests/InspectorBridgeServiceTests.swift`
- Test: full `InspectorTests` target

**Step 1: Run focused bridge tests**

Run:

```bash
xcodebuild test -project Example/Example.xcodeproj -scheme Example -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/InspectorBridgeServiceTests
```

Expected:
- bridge tests pass

**Step 2: Run full InspectorTests lane**

Run:

```bash
xcodebuild test -project Example/Example.xcodeproj -scheme Example -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests
```

Expected:
- all `InspectorTests` pass

**Step 3: Commit**

```bash
git add Tests/InspectorTests/InspectorBridgeServiceTests.swift Tests/InspectorTests/InspectorConfigurationTests.swift Example/Example.xcodeproj/project.pbxproj Example/Example.xcodeproj/xcshareddata/xcschemes/Example.xcscheme
git commit -m "Verify trait-native Inspector gating in the simulator test lane

Re-run the bridge and Inspector test targets after the symbol
migration so the compile-time contract rename is backed by fresh
runtime evidence.

Constraint: Must verify the real simulator-backed test lane
Rejected: Rely on grep-only validation | insufficient runtime evidence
Confidence: medium
Scope-risk: narrow
Directive: Keep the simulator test lane as the source of truth for gated runtime verification
Tested: InspectorBridgeServiceTests, InspectorTests
Not-tested: non-Debugging omission lane"
```

### Task 5: Final Repo Audit

**Files:**
- Modify only if issues are found

**Step 1: Run final symbol audit**

Run:

```bash
rg -n "INSPECTOR_ENABLED" Package.swift Sources Tests Example
```

Expected:
- no matches

**Step 2: Run final new-symbol audit**

Run:

```bash
rg -n "INSPECTOR_DEBUGGING" Package.swift Sources Tests Example
```

Expected:
- matches only in intended manifest/source/test/example guard sites

**Step 3: Write final summary**

Summarize:
- files changed
- behavior preserved
- verification run
- any remaining risk, especially lack of a negative non-Debugging compile lane

**Step 4: Commit**

```bash
git add -A
git commit -m "Retire the legacy Inspector compile-time contract

Finish the repo-wide migration to the trait-native
INSPECTOR_DEBUGGING symbol and verify there are no remaining
references to the old INSPECTOR_ENABLED mechanism.

Constraint: Must leave one compile-time contract name in the repo
Rejected: compatibility shim | extends cleanup indefinitely
Confidence: high
Scope-risk: moderate
Directive: Future Inspector gating should originate from the Debugging trait only
Tested: repo-wide symbol audit, simulator test lane
Not-tested: explicit non-Debugging omission build"
```
