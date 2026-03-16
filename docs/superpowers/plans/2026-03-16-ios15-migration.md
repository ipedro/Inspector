# iOS 15+ Migration Wave 1 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bump Inspector's minimum deployment target from iOS 14 to iOS 15 and remove all now-unconditional `#available`/`@available` guards and `#if swift(>=5.5)` wrappers.

**Architecture:** Four agents work in parallel on non-overlapping directory subtrees of `Sources/Inspector/`. Each agent reads every `.swift` file in their subtree, applies the flattening rules mechanically, and commits. A fifth sequential task runs verification greps and build.

**Tech Stack:** Swift 5.10, Swift Package Manager, UIKit, Xcode project (`project.pbxproj`).

**Spec:** `docs/superpowers/specs/2026-03-16-ios15-migration-design.md`

---

## Flattening Rules (apply to every `.swift` file)

> Reference these in every task below.

1. `if #available(iOS N, *) { A } else { B }` where N ≤ 15 → keep `A`, delete the guard line + `else { B }` block
2. `if #available(iOS N, *) { A }` (no else) where N ≤ 15 → keep `A`, delete the guard line
3. `@available(iOS N, *)` on a declaration where N ≤ 15 → delete the annotation line
4. `#if swift(>=5.5)` … `#endif` → delete the `#if` and `#endif` lines, keep the enclosed code

**Important:** Preserve exact indentation of kept code. Do not reformat anything else.

---

## Chunk 1: Package & Project Targets

### Task 1: Bump deployment targets

**Files:**
- Modify: `Package.swift`
- Modify: `Example/Example/Package.swift` (skip if no `.iOS` platform entry)
- Modify: `Example/Example.xcodeproj/project.pbxproj`

- [ ] **Step 1: Update `Package.swift`**

  Open `Package.swift`. Change:
  ```swift
  .iOS(.v14)
  ```
  to:
  ```swift
  .iOS(.v15)
  ```

- [ ] **Step 2: Update `Example/Example/Package.swift` if applicable**

  Open the file. If it contains `.iOS(.v14)`, change it to `.iOS(.v15)`. If no platform entry exists, skip.

- [ ] **Step 3: Update `project.pbxproj`**

  Open `Example/Example.xcodeproj/project.pbxproj`. Replace every occurrence of:
  ```
  IPHONEOS_DEPLOYMENT_TARGET = 14;
  ```
  with:
  ```
  IPHONEOS_DEPLOYMENT_TARGET = 15;
  ```
  (There are typically 2–3 occurrences for different build configurations.)

- [ ] **Step 4: Verify**

  ```bash
  grep -n 'v14\|DEPLOYMENT_TARGET = 14' Package.swift Example/Example.xcodeproj/project.pbxproj
  # Only check Example/Example/Package.swift if it exists:
  [ -f Example/Example/Package.swift ] && grep -n 'v14' Example/Example/Package.swift || true
  ```
  Expected: no output from either command.

- [ ] **Step 5: Commit**

  ```bash
  git add Package.swift Example/Example/Package.swift Example/Example.xcodeproj/project.pbxproj
  git commit -m "chore: bump deployment target to iOS 15"
  ```

---

## Chunk 2: ElementInspector/ Subtree

### Task 2: Flatten availability guards in `Sources/Inspector/ElementInspector/`

**Files:** Every `.swift` file in `Sources/Inspector/ElementInspector/` that contains `#available`, `@available`, or `#if swift`.

Find them first:
```bash
grep -rl '#available\|@available\|#if swift' Sources/Inspector/ElementInspector/
```

Apply the flattening rules to each result. Key known changes:

**`ElementInspector/Coordinators/ElementInspectorCoordinator.swift`**
- Delete the `@available(iOS 14.0, *)` line above the `colorPicker` lazy var
- For each `if #available(iOS 15.0, *) { ... }` block: delete the guard line, keep the body, delete the closing `}` of the guard (not of the body's content)
- Remove any `#if swift(>=5.5)` / `#endif` wrappers

**`ElementInspector/Coordinators/ElementInspectorCoordinator+ElementInspectorFormPanelDelegate.swift`**
- `if #available(iOS 14.0, *) { <UIColorPickerViewController block> }` — this has no `else`; delete guard line only, keep body
- `if #available(iOS 15.0, *) { ... }` — same treatment
- Remove any `#if swift(>=5.5)` / `#endif` wrappers

**`ElementInspector/Configuration/ElementInspectorConfiguration.swift`**
- Flatten `if #available(iOS 15.0, *)` guard
- Remove any `#if swift(>=5.5)` / `#endif` wrappers

**`ElementInspector/ViewControllers/ElementInspectorPanelViewController.swift`**
- Flatten `if #available(iOS 15.0, *)` guard
- Remove any `#if swift(>=5.5)` / `#endif` wrappers

Process any additional files returned by the grep above using the same rules.

- [ ] **Step 1: Find all affected files in subtree**

  ```bash
  grep -rl '#available\|@available\|#if swift' Sources/Inspector/ElementInspector/
  ```

- [ ] **Step 2: Apply flattening rules to each file**

  For each file: read it, apply the four flattening rules, save.

- [ ] **Step 3: Verify subtree is clean**

  ```bash
  grep -r '#available\|@available\|#if swift' Sources/Inspector/ElementInspector/
  ```
  Expected: no output.

- [ ] **Step 4: Build check**

  ```bash
  swift build 2>&1 | head -40
  ```
  Expected: no errors related to availability.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/ElementInspector/
  git commit -m "chore: flatten iOS 14/15 availability guards in ElementInspector"
  ```

---

## Chunk 3: ElementLibraries/, Models/, InspectorView/, ViewHierarchy/, Protocols/

### Task 3: Flatten availability guards in five subtrees

**Subtrees:**
- `Sources/Inspector/ElementLibraries/`
- `Sources/Inspector/Models/`
- `Sources/Inspector/InspectorView/`
- `Sources/Inspector/ViewHierarchy/`
- `Sources/Inspector/Protocols/`

Find affected files:
```bash
grep -rl '#available\|@available\|#if swift' \
  Sources/Inspector/ElementLibraries/ \
  Sources/Inspector/Models/ \
  Sources/Inspector/InspectorView/ \
  Sources/Inspector/ViewHierarchy/ \
  Sources/Inspector/Protocols/
```

Key known changes:

**`ElementLibraries/DefaultElementAttributesLibrary.swift`** — flatten `if #available(iOS 15.0, *)`

**`ElementLibraries/Sections/Attributes/DatePickerAttributesSectionDataSource.swift`** — two `if #available(iOS 14.0, *)` blocks; both have an `else` that switches date picker style — keep the iOS 14+ body (`datePicker.datePickerStyle = ...`), delete the `else` branch

**`ElementLibraries/Sections/Attributes/NavigationBarAppearanceAttributesSectionDataSource.swift`** — flatten `if #available(iOS 15.0, *)`, remove `#if swift(>=5.5)`

**`ElementLibraries/Sections/Attributes/SwitchAttributesSectionDataSource.swift`** — flatten `if #available(iOS 14.0, *)` guards

**`ElementLibraries/Sections/Attributes/WindowAttributesSectionDataSource.swift`** — flatten `if #available(iOS 15.0, *)`, remove `#if swift(>=5.5)`

**`Models/ViewHierarchyElementController.swift`** — flatten `if #available(iOS 14.0, *) { self._prefersPointerLocked = viewController.prefersPointerLocked } else { _prefersPointerLocked = false }` → keep assignment, delete else

**`Models/ViewHierarchyIssue.swift`** — flatten `if #available(iOS 15.0, *)` guards

**`InspectorView/ViewControllers/InspectorViewController.swift`** — The function has this structure:
```swift
if #available(iOS 14.0, *) {
    return GCKeyboard.coalesced != nil
}
return false  // ← this is the implicit else: only runs when the guard was false
```
Delete the `if #available` guard line and its closing `}`, keep `return GCKeyboard.coalesced != nil`, and delete the `return false` line that follows — it only existed as the fallback for the iOS < 14 path.

**`InspectorView/Views/HierarchyInspectorViewCode.swift`** — flatten `if #available(iOS 15.0, *)`

Apply the same rules to any additional files the grep finds.

- [ ] **Step 1: Find all affected files**

  ```bash
  grep -rl '#available\|@available\|#if swift' \
    Sources/Inspector/ElementLibraries/ \
    Sources/Inspector/Models/ \
    Sources/Inspector/InspectorView/ \
    Sources/Inspector/ViewHierarchy/ \
    Sources/Inspector/Protocols/
  ```

- [ ] **Step 2: Apply flattening rules to each file**

  For each file: read it, apply the four flattening rules, save.

- [ ] **Step 3: Verify subtrees are clean**

  ```bash
  grep -r '#available\|@available\|#if swift' \
    Sources/Inspector/ElementLibraries/ \
    Sources/Inspector/Models/ \
    Sources/Inspector/InspectorView/ \
    Sources/Inspector/ViewHierarchy/ \
    Sources/Inspector/Protocols/
  ```
  Expected: no output.

- [ ] **Step 4: Build check**

  ```bash
  swift build 2>&1 | head -40
  ```
  Expected: no errors.

- [ ] **Step 5: Commit**

  ```bash
  git add \
    Sources/Inspector/ElementLibraries/ \
    Sources/Inspector/Models/ \
    Sources/Inspector/InspectorView/ \
    Sources/Inspector/ViewHierarchy/ \
    Sources/Inspector/Protocols/
  git commit -m "chore: flatten iOS 14/15 availability guards in ElementLibraries, Models, InspectorView, ViewHierarchy, Protocols"
  ```

---

## Chunk 4: Extensions/, CommonUI/, Presenters/, Configuration/, Manager/

### Task 4: Flatten availability guards in remaining subtrees

**Subtrees:**
- `Sources/Inspector/Extensions/`
- `Sources/Inspector/CommonUI/`
- `Sources/Inspector/Presenters/`
- `Sources/Inspector/Configuration/`
- `Sources/Inspector/Manager/`

Find affected files:
```bash
grep -rl '#available\|@available\|#if swift' \
  Sources/Inspector/Extensions/ \
  Sources/Inspector/CommonUI/ \
  Sources/Inspector/Presenters/ \
  Sources/Inspector/Configuration/ \
  Sources/Inspector/Manager/
```

Key known changes:

**`Extensions/UISwitch/UISwitch.Style+CaseIterable.swift`** — delete `@available(iOS 14.0, *)` line

**`Extensions/UISwitch/UISwitch.Style+SegmentedControlDisplayable.swift`** — delete `@available(iOS 14.0, *)` line

**`Extensions/UIDatePickerStyle/UIDatePickerStyle+CaseIterable.swift`** — `if #available(iOS 14.0, *) { return [.automatic, .wheels, .compact, .inline] } else { return [.automatic, .wheels] }` → keep 4-case return, delete guard + else

**`Extensions/UIMenuElement/UIMenuElement+Convenience.swift`** — two `if #available(iOS 15.0, *)` blocks; flatten each; remove `#if swift(>=5.5)`

**`Extensions/UIImage/UIImage+ModuleImage.swift`** — flatten `if #available(iOS 15.0, *)` (prefersHierarchicalColor path)

**`Extensions/UIViewController/UIViewController+PopoverPresentationStyle.swift`** — flatten `if #available(iOS 15.0, *)`, remove `#if swift(>=5.5)`

**`CommonUI/Controls/ColorPreviewControl.swift`** — `if #available(iOS 14.0, *) { colorDisplayControl.isEnabled = true } else { accessoryControl.isUserInteractionEnabled = false }` → keep `colorDisplayControl.isEnabled = true`, delete guard + else

**`Presenters/ColorPickerPresenter.swift`** — delete `@available(iOS 14.0, *)` line above the class declaration

**`Presenters/AdaptiveModalPresenter.swift`** — delete `@available(iOS 15.0, *)` line; delete `#if swift(>=5.5)` and matching `#endif`, keep enclosed code

Apply the same rules to any additional files the grep finds.

- [ ] **Step 1: Find all affected files**

  ```bash
  grep -rl '#available\|@available\|#if swift' \
    Sources/Inspector/Extensions/ \
    Sources/Inspector/CommonUI/ \
    Sources/Inspector/Presenters/ \
    Sources/Inspector/Configuration/ \
    Sources/Inspector/Manager/
  ```

- [ ] **Step 2: Apply flattening rules to each file**

  For each file: read it, apply the four flattening rules, save.

- [ ] **Step 3: Verify subtrees are clean**

  ```bash
  grep -r '#available\|@available\|#if swift' \
    Sources/Inspector/Extensions/ \
    Sources/Inspector/CommonUI/ \
    Sources/Inspector/Presenters/ \
    Sources/Inspector/Configuration/ \
    Sources/Inspector/Manager/
  ```
  Expected: no output.

- [ ] **Step 4: Build check**

  ```bash
  swift build 2>&1 | head -40
  ```
  Expected: no errors.

- [ ] **Step 5: Commit**

  ```bash
  git add \
    Sources/Inspector/Extensions/ \
    Sources/Inspector/CommonUI/ \
    Sources/Inspector/Presenters/ \
    Sources/Inspector/Configuration/ \
    Sources/Inspector/Manager/
  git commit -m "chore: flatten iOS 14/15 availability guards in Extensions, CommonUI, Presenters, Configuration, Manager"
  ```

---

## Chunk 5: Final Verification

> Run this after Tasks 1–4 are all complete.

### Task 5: Verify and confirm

- [ ] **Step 1: Run full success criteria checks**

  ```bash
  grep -r 'if #available(iOS 1[0-5]' Sources/
  grep -r '@available(iOS 1[0-5]' Sources/
  grep -r '#if swift' Sources/
  ```
  All three must return **no output**.

- [ ] **Step 2: Confirm package target**

  ```bash
  grep 'iOS' Package.swift
  ```
  Expected output contains `.iOS(.v15)`.

- [ ] **Step 3: Confirm project target**

  ```bash
  grep 'IPHONEOS_DEPLOYMENT_TARGET' Example/Example.xcodeproj/project.pbxproj
  ```
  Expected: all entries show `15`.

- [ ] **Step 4: Full build**

  ```bash
  swift build
  ```
  Expected: `Build complete!` with no errors or availability warnings.

- [ ] **Step 5: Run tests**

  ```bash
  swift test
  ```
  Expected: all tests pass.

- [ ] **Step 6: Final commit if anything was missed**

  If any stray guards were caught in Steps 1–3, fix them, then:
  ```bash
  git add -p
  git commit -m "chore: fix remaining availability guards from iOS 15 migration"
  ```
