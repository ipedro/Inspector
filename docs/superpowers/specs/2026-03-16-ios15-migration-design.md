# iOS 15+ Migration — Wave 1: Cleanup

**Date:** 2026-03-16
**Scope:** Inspector SPM package + Example app
**Goal:** Bump minimum deployment target from iOS 14 to iOS 15, remove all `@available` annotations and `#available` guards that are now unconditional, and delete dead fallback branches.

---

## 1. Target Changes

| File | Change |
|------|--------|
| `Package.swift` | `.iOS(.v14)` → `.iOS(.v15)` |
| `Example/Example/Package.swift` | `.iOS(.v14)` → `.iOS(.v15)` — skip if the file doesn't declare a platform |
| `Example/Example.xcodeproj/project.pbxproj` | `IPHONEOS_DEPLOYMENT_TARGET` 14 → 15 — always update this |

Dependencies (`UIKeyCommandTableView`, `UIKeyboardAnimatable`, `Coordinator`) are **out of scope** for wave 1.

---

## 2. Flattening Rules (apply to every `.swift` file in `Sources/`)

These rules are applied mechanically to every Swift file in `Sources/`:

- `if #available(iOS N, *) { A } else { B }` where N ≤ 15 → keep `A`, delete guard + `else` block
- `if #available(iOS N, *) { A }` (no else) where N ≤ 15 → keep `A`, delete guard
- `@available(iOS N, *)` on any declaration where N ≤ 15 → remove the annotation
- `#if swift(>=5.5)` wrapper → remove the `#if`/`#endif` lines, keep the enclosed code

Each agent is responsible for **all matching occurrences** in their assigned directory subtree — not just the examples listed. If a file in the subtree has no matching patterns, skip it.

---

## 3. Agent Breakdown (Parallel)

Agents work on non-overlapping directory subtrees. Together they cover all of `Sources/Inspector/`.

### Agent 1 — Package targets
- `Package.swift` — bump `.iOS(.v14)` → `.iOS(.v15)`
- `Example/Example/Package.swift` — bump if platform is declared
- `Example/Example.xcodeproj/project.pbxproj` — set `IPHONEOS_DEPLOYMENT_TARGET = 15`

### Agent 2 — `Sources/Inspector/ElementInspector/`
Apply flattening rules to every `.swift` file in this subtree. Known hot spots:
- `Coordinators/ElementInspectorCoordinator.swift` — `@available(iOS 14)` on `colorPicker`, 2× `if #available(iOS 15)`
- `Coordinators/ElementInspectorCoordinator+ElementInspectorFormPanelDelegate.swift` — `if #available(iOS 14)`, `if #available(iOS 15)`
- `Configuration/ElementInspectorConfiguration.swift` — `if #available(iOS 15)`
- `ViewControllers/ElementInspectorPanelViewController.swift` — `if #available(iOS 15)`
- Any other files in the subtree with matching patterns

### Agent 3 — `Sources/Inspector/ElementLibraries/`, `Sources/Inspector/Models/`, `Sources/Inspector/InspectorView/`, `Sources/Inspector/ViewHierarchy/`, `Sources/Inspector/Protocols/`
Apply flattening rules to every `.swift` file in these subtrees. Known hot spots:
- `ElementLibraries/DefaultElementAttributesLibrary.swift` — `if #available(iOS 15)`
- `ElementLibraries/Sections/Attributes/DatePickerAttributesSectionDataSource.swift` — 2× `if #available(iOS 14)`
- `ElementLibraries/Sections/Attributes/NavigationBarAppearanceAttributesSectionDataSource.swift` — `if #available(iOS 15)`
- `ElementLibraries/Sections/Attributes/SwitchAttributesSectionDataSource.swift` — `if #available(iOS 14)`
- `ElementLibraries/Sections/Attributes/WindowAttributesSectionDataSource.swift` — `if #available(iOS 15)`, `#if swift(>=5.5)`
- `Models/ViewHierarchyElementController.swift` — `if #available(iOS 14)`
- `Models/ViewHierarchyIssue.swift` — `if #available(iOS 15)`
- `InspectorView/ViewControllers/InspectorViewController.swift` — `if #available(iOS 14)`
- `InspectorView/Views/HierarchyInspectorViewCode.swift` — `if #available(iOS 15)`
- Any other files in these subtrees with matching patterns

### Agent 4 — `Sources/Inspector/Extensions/`, `Sources/Inspector/CommonUI/`, `Sources/Inspector/Presenters/`, `Sources/Inspector/Configuration/`, `Sources/Inspector/Manager/`
Apply flattening rules to every `.swift` file in these subtrees. Known hot spots:
- `Extensions/UISwitch/UISwitch.Style+CaseIterable.swift` — `@available(iOS 14)`
- `Extensions/UISwitch/UISwitch.Style+SegmentedControlDisplayable.swift` — `@available(iOS 14)`
- `Extensions/UIDatePickerStyle/UIDatePickerStyle+CaseIterable.swift` — `if #available(iOS 14)` with 2-case else
- `Extensions/UIMenuElement/UIMenuElement+Convenience.swift` — 2× `if #available(iOS 15)`
- `Extensions/UIImage/UIImage+ModuleImage.swift` — `if #available(iOS 15)`
- `Extensions/UIViewController/UIViewController+PopoverPresentationStyle.swift` — `if #available(iOS 15)`
- `CommonUI/Controls/ColorPreviewControl.swift` — `if #available(iOS 14)` with else
- `Presenters/ColorPickerPresenter.swift` — `@available(iOS 14)` on class
- `Presenters/AdaptiveModalPresenter.swift` — `@available(iOS 15)`, `#if swift(>=5.5)`
- Any other files in these subtrees with matching patterns

---

## 4. Success Criteria

Run these checks after all agents complete. All must return zero results:

```bash
grep -r 'if #available(iOS 1[0-5]' Sources/
grep -r '@available(iOS 1[0-5]' Sources/
grep -r '#if swift' Sources/
```

Plus:
- `swift build` passes clean
- `Package.swift` contains `.iOS(.v15)`
- `project.pbxproj` `IPHONEOS_DEPLOYMENT_TARGET` is `15`

---

## 5. Out of Scope (Wave 2)

- Adopting `UIButton.Configuration`
- Full `UISheetPresentationController` integration
- `async`/`await` conversions
- Dependency package target bumps
