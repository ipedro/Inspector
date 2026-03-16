# iOS 15+ Migration — Wave 1: Cleanup

**Date:** 2026-03-16
**Scope:** Inspector SPM package + Example app
**Goal:** Bump minimum deployment target from iOS 14 to iOS 15, remove all `@available` annotations and `#available` guards that are now unconditional, and delete dead fallback branches.

---

## 1. Target Changes

| File | Change |
|------|--------|
| `Package.swift` | `.iOS(.v14)` → `.iOS(.v15)` |
| `Example/Example/Package.swift` | `.iOS(.v14)` → `.iOS(.v15)` (if declared) |
| `Example/Example.xcodeproj` | `IPHONEOS_DEPLOYMENT_TARGET` 14 → 15 in `project.pbxproj` |

Dependencies (`UIKeyCommandTableView`, `UIKeyboardAnimatable`, `Coordinator`) are **out of scope** for wave 1.

---

## 2. Code Changes

### Rule: How to flatten `#available` guards

- `if #available(iOS 14.0, *) { A } else { B }` → keep `A`, delete guard + `else` block
- `if #available(iOS 15.0, *) { A } else { B }` → keep `A`, delete guard + `else` block
- `if #available(iOS 14.0, *) { A }` (no else) → keep `A`, delete guard
- `@available(iOS 14.0, *)` / `@available(iOS 15.0, *)` on a declaration → remove annotation
- `#if swift(>=5.5)` wrapping an iOS 15 availability block → remove the compiler flag wrapper too

---

## 3. Agent Breakdown (Parallel)

### Agent 1 — Package targets
Files:
- `Package.swift`
- `Example/Example/Package.swift`
- `Example/Example.xcodeproj/project.pbxproj`

### Agent 2 — ElementInspector/
Files and changes:
- `ElementInspector/Coordinators/ElementInspectorCoordinator.swift`
  - Remove `@available(iOS 14.0, *)` on `colorPicker` lazy var
  - Flatten 2× `if #available(iOS 15.0, *)` guards
- `ElementInspector/Coordinators/ElementInspectorCoordinator+ElementInspectorFormPanelDelegate.swift`
  - Flatten `if #available(iOS 14.0, *)` (UIColorPickerViewController — keep body, delete guard + else)
  - Flatten `if #available(iOS 15.0, *)` guard
- `ElementInspector/Configuration/ElementInspectorConfiguration.swift`
  - Flatten `if #available(iOS 15.0, *)`
- `ElementInspector/ViewControllers/ElementInspectorPanelViewController.swift`
  - Flatten `if #available(iOS 15.0, *)`

### Agent 3 — ElementLibraries/ + Models/ + InspectorView/
Files and changes:
- `ElementLibraries/DefaultElementAttributesLibrary.swift`
  - Flatten `if #available(iOS 15.0, *)`
- `ElementLibraries/Sections/Attributes/DatePickerAttributesSectionDataSource.swift`
  - Flatten 2× `if #available(iOS 14.0, *)` (keep bodies, delete guards)
- `ElementLibraries/Sections/Attributes/NavigationBarAppearanceAttributesSectionDataSource.swift`
  - Flatten `if #available(iOS 15.0, *)`
- `Models/ViewHierarchyElementController.swift`
  - Flatten `if #available(iOS 14.0, *)` — keep `_prefersPointerLocked = viewController.prefersPointerLocked`, delete `else { _prefersPointerLocked = false }`
- `InspectorView/ViewControllers/InspectorViewController.swift`
  - Flatten `if #available(iOS 14.0, *)` — keep `GCKeyboard.coalesced != nil`, delete `return false` else branch
- `InspectorView/Views/HierarchyInspectorViewCode.swift`
  - Flatten `if #available(iOS 15.0, *)`

### Agent 4 — Extensions/ + CommonUI/ + Presenters/
Files and changes:
- `Extensions/UISwitch/UISwitch.Style+CaseIterable.swift`
  - Remove `@available(iOS 14.0, *)` annotation
- `Extensions/UISwitch/UISwitch.Style+SegmentedControlDisplayable.swift`
  - Remove `@available(iOS 14.0, *)` annotation
- `Extensions/UIDatePickerStyle/UIDatePickerStyle+CaseIterable.swift`
  - Flatten `if #available(iOS 14.0, *)` — keep 4-case array (`.automatic`, `.wheels`, `.compact`, `.inline`), delete `else` with 2-case array
- `CommonUI/Controls/ColorPreviewControl.swift`
  - Flatten `if #available(iOS 14.0, *)` — keep `colorDisplayControl.isEnabled = true`, delete `else { accessoryControl.isUserInteractionEnabled = false }`
- `Extensions/UIMenuElement/UIMenuElement+Convenience.swift`
  - Flatten 2× `if #available(iOS 15.0, *)`
- `Extensions/UIImage/UIImage+ModuleImage.swift`
  - Flatten `if #available(iOS 15.0, *)` (prefersHierarchicalColor)
- `Extensions/UIViewController/UIViewController+PopoverPresentationStyle.swift`
  - Flatten `if #available(iOS 15.0, *)`
- `Presenters/ColorPickerPresenter.swift`
  - Remove `@available(iOS 14.0, *)` annotation
- `Presenters/AdaptiveModalPresenter.swift`
  - Remove `@available(iOS 15.0, *)` annotation + `#if swift(>=5.5)` compiler guard

---

## 4. Success Criteria

- `swift build` passes with no warnings about deprecated availability checks
- No `#available(iOS 14` or `#available(iOS 15` guards remain in `Sources/`
- No `@available(iOS 14` or `@available(iOS 15` annotations remain in `Sources/`
- `Package.swift` declares `.iOS(.v15)`
- Example app deployment target is 15

---

## 5. Out of Scope (Wave 2)

- Adopting `UIButton.Configuration`
- Full `UISheetPresentationController` integration
- `async`/`await` conversions
- Dependency package target bumps
