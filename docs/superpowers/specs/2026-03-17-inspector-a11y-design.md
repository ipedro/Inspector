# Inspector Accessibility (a11y) Design

## Goal

Add accessibility identifiers, labels, and values to the Inspector's own UI so that AXe (and VoiceOver) can interact with it reliably by name rather than by coordinate.

## Background

The Inspector UI currently has zero `accessibilityIdentifier` or `accessibilityLabel` assignments on its own interactive elements, despite the codebase having full capability to read and edit accessibility properties of _inspected_ views. This makes automated UI testing with AXe brittle — every interaction requires hardcoded coordinates.

## Scope

Three areas, all simple property assignments:

1. **Navigation shell** — structural interactive elements
2. **Hierarchy list cells** — dynamic labels from cell content
3. **Form controls** — base class label + value for all property controls

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

**File touched:**
- `Sources/Inspector/InspectorView/Views/HierarchyInspectorTableViewCell.swift`

**Change:**

Compose `textLabel.text` (element name) and `detailTextLabel.text` (class name) into a single `accessibilityLabel` in the cell's configuration method:

```swift
accessibilityLabel = [textLabel?.text, detailTextLabel?.text]
    .compactMap { $0 }
    .joined(separator: ", ")
```

No change to accessibility traits — UIKit marks selectable table cells appropriately.

---

## Section 3: Form Controls

**Files touched:**
- `Sources/Inspector/CommonUI/Bases/BaseFormControl.swift`
- `Sources/Inspector/CommonUI/Controls/ToggleControl.swift`
- `Sources/Inspector/CommonUI/Controls/StepperControl.swift`
- `Sources/Inspector/CommonUI/Controls/StepperPairControl.swift`

**BaseFormControl — covers all 15+ controls in one change:**

```swift
// set in init or when title changes
accessibilityLabel = title
// Do NOT set isAccessibilityElement = true here — composite controls
// (StepperPairControl, PointControl, SizeControl, etc.) contain interactive
// subviews that must remain individually accessible. UIKit walks children
// automatically. accessibilityLabel on the container is still readable by
// AXe via accessibilityIdentifier traversal.
```

**ToggleControl — value updated in `updateViews()`:**

```swift
accessibilityValue = isOn ? "on" : "off"
```

**StepperControl / StepperPairControl — value updated when value changes:**

```swift
accessibilityValue = "\(currentValue)"
```

All other controls (TextFieldControl, ColorPreviewControl, SegmentedControl, OptionListControl, etc.) inherit the label from `BaseFormControl`; UIKit handles their value display naturally.

---

## Out of Scope

- VoiceOver grouping / custom accessibility containers for form panels
- `accessibilityHint` strings
- Custom accessibility actions
- `accessibilityTraits` beyond what UIKit assigns automatically

These can be addressed in a future pass once the foundation is in place.

---

## Testing

After implementation, verify with AXe:

```bash
# Find search field by label
axe tap --label "Search views" --udid $SIM_UDID

# Find dismiss button by identifier
axe tap --label "Close" --udid $SIM_UDID

# Find a hierarchy cell by its element name
axe tap --label "PlaygroundViewController" --udid $SIM_UDID
```
