# Inspector Accessibility (a11y) Design

## Goal

Add accessibility identifiers, labels, and values to the Inspector's own UI so that AXe (and VoiceOver) can interact with it reliably by name rather than by coordinate.

## Background

The Inspector UI currently has zero `accessibilityIdentifier` or `accessibilityLabel` assignments on its own interactive elements, despite the codebase having full capability to read and edit accessibility properties of _inspected_ views. This makes automated UI testing with AXe brittle — every interaction requires hardcoded coordinates.

## Scope

Four areas, all simple property assignments:

1. **Navigation shell** — structural interactive elements
2. **Hierarchy list cells** — dynamic labels from cell content
3. **Form controls** — label on leaf interactive subviews per control type
4. **Section headers** — collapse/expand controls

---

## Section 1: Navigation Shell

**Files touched:**
- `Sources/Inspector/ElementInspector/ViewControllers/ElementInspectorViewController.swift`
- `Sources/Inspector/ElementInspector/ViewControllers/ElementInspectorNavigationController.swift`
- `Sources/Inspector/InspectorView/Views/HierarchyInspectorSearchView.swift`
- `Sources/Inspector/InspectorView/Views/HierarchyInspectorViewCode.swift`

**Changes:**

| Element | Property | Value |
|---|---|---|
| Segmented control (panel picker) | `accessibilityIdentifier` | `"inspector.panel-picker"` |
| Dismiss bar button | `accessibilityIdentifier` | `"inspector.dismiss-button"` |
| Search text field | `accessibilityIdentifier` | `"inspector.search-field"` |
| Search text field | `accessibilityLabel` | `"Search views"` |
| Hierarchy table view | `accessibilityIdentifier` | `"inspector.hierarchy-list"` |

Segmented control segment titles (e.g. "Children", "Attributes") are already used by UIKit as per-segment accessibility labels — no extra work needed.

The system `.close` bar button already has a localized VoiceOver label from UIKit; adding an identifier makes it stable for AXe.

---

## Section 2: Hierarchy List Cells

**Files touched:**
- `Sources/Inspector/InspectorView/Views/HierarchyInspectorReferenceSummaryTableViewCell.swift`
- `Sources/Inspector/InspectorView/Views/HierarchyInspectorActionTableViewCell.swift`

The base class `HierarchyInspectorTableViewCell` has no configuration method — text is set in each subclass's `viewModel` didSet (for reference cells) or equivalent for action cells. Set `accessibilityLabel` at that point in each subclass.

**`HierarchyInspectorReferenceSummaryTableViewCell` — in `viewModel` didSet:**

```swift
accessibilityLabel = [textLabel?.text, detailTextLabel?.text]
    .compactMap { $0.flatMap { $0.isEmpty ? nil : $0 } }
    .joined(separator: ", ")
```

Note: use `flatMap { $0.isEmpty ? nil : $0 }` (not just `compactMap { $0 }`) to guard against empty strings, which would produce trailing separators.

**`HierarchyInspectorActionTableViewCell` — in its text-configuration path:**

```swift
accessibilityLabel = textLabel?.text
```

No change to accessibility traits — UIKit marks selectable table cells appropriately.

---

## Section 3: Form Controls

Setting `accessibilityLabel` on a container view (`BaseFormControl`) without `isAccessibilityElement = true` is a no-op in the accessibility tree — UIKit walks past the container to the leaf interactive subviews. Instead, set the title as the label directly on each leaf interactive subview.

**Files touched:**
- `Sources/Inspector/CommonUI/Controls/ToggleControl.swift`
- `Sources/Inspector/CommonUI/Controls/StepperControl.swift`
- `Sources/Inspector/CommonUI/Controls/StepperPairControl.swift`
- `Sources/Inspector/CommonUI/Controls/TextFieldControl.swift`
- `Sources/Inspector/CommonUI/Controls/SegmentedControl.swift`

**ToggleControl — set on `switchControl` in `setup()` or `updateViews()`:**

```swift
switchControl.accessibilityLabel = title
// Don't set accessibilityValue — UISwitch announces "on"/"off" natively.
```

**StepperControl — proxy `accessibilityLabel` to the inner `UIStepper`:**

Override `accessibilityLabel` so that any caller (including `StepperPairControl`) setting the label on a `StepperControl` automatically propagates it to the inner `UIStepper`. Also update `accessibilityValue` when value changes.

```swift
// In StepperControl — proxy both label and value to the inner UIStepper:
override var accessibilityLabel: String? {
    get { stepperControl.accessibilityLabel }
    set { stepperControl.accessibilityLabel = newValue }
}

override var accessibilityValue: String? {
    get { stepperControl.accessibilityValue }
    set { stepperControl.accessibilityValue = newValue }
}

// In setup() — initial label from title:
stepperControl.accessibilityLabel = title

// In updateCounterLabel() — keep value in sync:
stepperControl.accessibilityValue = "\(value)"
```

**StepperPairControl — set label on each `StepperControl` wrapper in `setup()`:**

Because `StepperControl.accessibilityLabel` is now proxied to its inner `UIStepper`, these assignments reach the actual leaf element:

```swift
firstStepper.accessibilityLabel = "\(title ?? "") (first)"
firstStepper.accessibilityValue = "\(firstValue)"   // update when firstValue changes

secondStepper.accessibilityLabel = "\(title ?? "") (second)"
secondStepper.accessibilityValue = "\(secondValue)" // update when secondValue changes
```

**TextFieldControl — set on the inner `UITextField` in `setup()`:**

```swift
textField.accessibilityLabel = title
```

**SegmentedControl — set on the inner `UISegmentedControl` in `setup()`:**

```swift
segmentedControl.accessibilityLabel = title
```

All other controls (ColorPreviewControl, OptionListControl, PointControl, SizeControl, etc.) have their leaf interactive subviews (UIButton, UITextField, UIStepper) already exposed by UIKit's default traversal. They can be addressed in a follow-up pass; excluding them here keeps this change focused.

---

## Section 4: Section Headers (Collapse/Expand)

**File touched:**
- `Sources/Inspector/ElementInspector/Submodules/FormPanel/Views/InspectorElementSectionFormView.swift` (or wherever `headerControl` is configured)

The `headerControl` (a `BaseControl` subclass `ToogleCollapseButton`) drives section expand/collapse. It currently has no identifier or label.

**Changes:**

```swift
headerControl.accessibilityLabel = sectionTitle  // or equivalent property
headerControl.accessibilityIdentifier = "inspector.section-header"
headerControl.accessibilityHint = "Double-tap to toggle"
```

---

## Out of Scope

- VoiceOver grouping / custom accessibility containers for form panels
- Full `accessibilityHint` coverage beyond the section toggle
- Custom accessibility actions
- `accessibilityTraits` beyond what UIKit assigns automatically

These can be addressed in a future pass once the foundation is in place.

---

## Testing

After implementation, verify with AXe:

```bash
# Find search field by label
axe tap --label "Search views" --udid $SIM_UDID

# Find dismiss button by identifier (system label is locale-dependent)
axe tap --identifier "inspector.dismiss-button" --udid $SIM_UDID

# Find a hierarchy cell by its element name
axe tap --label "PlaygroundViewController" --udid $SIM_UDID

# Find the panel picker by identifier
axe tap --identifier "inspector.panel-picker" --udid $SIM_UDID
```
