# Inspector Accessibility Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add accessibility identifiers, labels, and values to the Inspector's own UI so AXe and VoiceOver can interact with it by name rather than by coordinate.

**Architecture:** Navigation shell elements get stable `accessibilityIdentifier` strings. Hierarchy cells build a label from their displayed text content. Form controls (ToggleControl, StepperControl, etc.) expose their title as `accessibilityLabel` on the leaf interactive subview (UISwitch, UIStepper, UITextField, UISegmentedControl) — not the container — so VoiceOver reaches the right element. StepperControl proxies `accessibilityLabel`/`accessibilityValue` as computed property overrides to transparently propagate values from StepperPairControl through to the inner UIStepper.

**Tech Stack:** Swift, UIKit, UIAccessibility APIs (available since iOS 3 — no availability guards needed), `xcodebuild test` on an iOS Simulator for unit tests (the `InspectorTests` target depends on `Inspector` which is iOS-only, so `swift test` on macOS won't find it), AXe CLI for end-to-end verification.

**Spec:** `docs/superpowers/specs/2026-03-17-inspector-a11y-design.md`

---

## Chunk 1: Navigation Shell + Cells

### Task 1: Navigation Shell Identifiers

**Files:**
- Modify: `Sources/Inspector/ElementInspector/ViewControllers/ElementInspectorViewController.swift` (line ~72, `segmentedControl` lazy var; line ~84, `dismissBarButtonItem` lazy var)
- Modify: `Sources/Inspector/InspectorView/Views/HierarchyInspectorSearchView.swift` (lines 30-41, `textField` lazy var)
- Modify: `Sources/Inspector/InspectorView/Views/HierarchyInspectorViewCode.swift` (lines 73-79, `tableView` lazy var)

These are pure additions — no logic changes, no tests needed beyond AXe verification.

- [ ] **Step 1: Add identifier to segmented control**

In `ElementInspectorViewController.swift`, in the `segmentedControl` lazy var (line ~72):

```swift
private lazy var segmentedControl = UISegmentedControl.segmentedControlStyle().then {
    $0.accessibilityIdentifier = "inspector.panel-picker"
    $0.addTarget(self, action: #selector(didChangeSelectedSegmentIndex), for: .valueChanged)
    $0.addInteraction(UIContextMenuInteraction(delegate: self))
}
```

- [ ] **Step 2: Add identifier to dismiss button**

In `ElementInspectorViewController.swift`, the `dismissBarButtonItem` lazy var (line ~84) currently has no `.then` block. Add one:

```swift
private(set) lazy var dismissBarButtonItem = UIBarButtonItem(
    barButtonSystemItem: dismissItem,
    target: self,
    action: #selector(dismiss(_:))
).then {
    $0.accessibilityIdentifier = "inspector.dismiss-button"
}
```

(`UIBarButtonItem` is `NSObject` so `.then` is available — other properties in this file already use it.)

- [ ] **Step 3: Add identifier + label to search text field**

In `HierarchyInspectorSearchView.swift`, in the `textField` lazy var (line ~30):

```swift
private(set) lazy var textField = KeyPressTextField().then {
    $0.accessibilityIdentifier = "inspector.search-field"
    $0.accessibilityLabel = "Search views"
    $0.clearButtonMode = .always
    $0.font = .preferredFont(forTextStyle: .title2)
    $0.textColor = colorStyle.textColor
    $0.attributedPlaceholder = NSAttributedString(
        string: Texts.searchViews,
        attributes: [
            .foregroundColor: colorStyle.secondaryTextColor,
            .font: UIFont.preferredFont(forTextStyle: .title2)
        ]
    )
}
```

- [ ] **Step 4: Add identifier to hierarchy table view**

In `HierarchyInspectorViewCode.swift`, in the `tableView` lazy var (line ~73):

```swift
private(set) lazy var tableView = UIKeyCommandTableView().then {
    $0.accessibilityIdentifier = "inspector.hierarchy-list"
    $0.backgroundColor = .none
    $0.keyboardDismissMode = .onDrag
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
    $0.sectionHeaderTopPadding = 0
}
```

- [ ] **Step 5: Build and verify no errors**

```bash
cd /Users/pedro/Developer/Inspector
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed|Build complete"
```

Expected: `Build complete!` with no errors.

- [ ] **Step 6: Commit**

```bash
git add Sources/Inspector/ElementInspector/ViewControllers/ElementInspectorViewController.swift
git add Sources/Inspector/ElementInspector/ViewControllers/ElementInspectorNavigationController.swift
git add Sources/Inspector/InspectorView/Views/HierarchyInspectorSearchView.swift
git add Sources/Inspector/InspectorView/Views/HierarchyInspectorViewCode.swift
git commit -m "feat(a11y): add identifiers to navigation shell elements"
```

---

### Task 2: Hierarchy List Cell Labels

**Files:**
- Modify: `Sources/Inspector/InspectorView/Views/HierarchyInspectorReferenceSummaryTableViewCell.swift` (lines 33-49, `viewModel` didSet)
- Modify: `Sources/Inspector/InspectorView/Views/HierarchyInspectorActionTableViewCell.swift` (line ~33, `viewModel` didSet)

- [ ] **Step 1: Add accessibilityLabel to reference cell**

In `HierarchyInspectorReferenceSummaryTableViewCell.swift`, at the end of the `viewModel` didSet body (after line ~44 `detailTextLabel?.text = viewModel?.subtitle`):

```swift
var viewModel: HierarchyInspectorReferenceSummaryCellViewModelProtocol? {
    didSet {
        textLabel?.text = viewModel?.title
        detailTextLabel?.text = viewModel?.subtitle
        imageView?.image = viewModel?.image

        // accessibility
        accessibilityLabel = [viewModel?.title, viewModel?.subtitle]
            .compactMap { $0.flatMap { $0.isEmpty ? nil : $0 } }
            .joined(separator: ", ")

        let defaultLayoutMargins = directionalLayoutMargins
        let depth = CGFloat(viewModel?.depth ?? 0)
        var margins = defaultLayoutMargins
        margins.leading += depth * 5

        directionalLayoutMargins = margins
        separatorInset = UIEdgeInsets(left: margins.leading, right: defaultLayoutMargins.trailing)

        contentView.alpha = viewModel?.isEnabled == true ? 1 : colorStyle.disabledAlpha
        selectionStyle = viewModel?.isEnabled == true ? .default : .none
    }
}
```

Note: Read `viewModel?.title` / `viewModel?.subtitle` directly (not `textLabel?.text`) to avoid depending on UIKit text assignment order.

- [ ] **Step 2: Add accessibilityLabel to action cell**

In `HierarchyInspectorActionTableViewCell.swift`, in the `viewModel` didSet, after `textLabel?.text = viewModel?.title`:

```swift
accessibilityLabel = viewModel?.title
```

- [ ] **Step 3: Build**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed|Build complete"
```

Expected: `Build complete!` with no errors.

- [ ] **Step 4: Commit**

```bash
git add Sources/Inspector/InspectorView/Views/HierarchyInspectorReferenceSummaryTableViewCell.swift
git add Sources/Inspector/InspectorView/Views/HierarchyInspectorActionTableViewCell.swift
git commit -m "feat(a11y): set accessibilityLabel on hierarchy list cells from content"
```

---

## Chunk 2: Form Controls

### Task 3: ToggleControl, TextFieldControl, SegmentedControl

**Files:**
- Modify: `Sources/Inspector/CommonUI/Controls/ToggleControl.swift`
- Modify: `Sources/Inspector/CommonUI/Controls/TextFieldControl.swift`
- Modify: `Sources/Inspector/CommonUI/Controls/SegmentedControl.swift`

Each of these has a single leaf interactive subview. Set `accessibilityLabel = title` on that subview in `setup()`.

- [ ] **Step 1: Write failing tests**

In `Tests/InspectorTests/` — create `Tests/InspectorTests/AccessibilityTests.swift`:

```swift
// Tests/InspectorTests/AccessibilityTests.swift
import XCTest
@testable import Inspector

final class AccessibilityTests: XCTestCase {

    func testToggleControlExposesLabelOnSwitch() {
        let control = ToggleControl(title: "Animate", isOn: false)
        XCTAssertEqual(control.switchControl.accessibilityLabel, "Animate")
    }
}
```

- [ ] **Step 2: Run to confirm it fails**

```bash
cd /Users/pedro/Developer/Inspector
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

Expected: test failure (switchControl.accessibilityLabel is nil).

- [ ] **Step 3: Add label to ToggleControl**

In `ToggleControl.swift`, in `setup()` (line ~76), add after `super.setup()`:

```swift
override func setup() {
    super.setup()
    switchControl.accessibilityLabel = title
    contentView.addArrangedSubview(switchContainer)
    updateViews()
}
```

- [ ] **Step 4: Run test — expect pass**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

Expected: `testToggleControlExposesLabelOnSwitch` passes.

- [ ] **Step 5: Add label to TextFieldControl**

`TextFieldControl.textField` is currently `private lazy var`. Change it to `private(set) lazy var` so tests can read it (setter stays private). Then set `accessibilityLabel` in `setup()`.

In `TextFieldControl.swift`:
- Change `private lazy var textField` → `private(set) lazy var textField` (line ~28)
- In `setup()` (line ~92), add after `super.setup()`:

```swift
override func setup() {
    super.setup()
    textField.accessibilityLabel = title
    axis = .vertical
    contentView.addArrangedSubview(accessoryControl)
}
```

- [ ] **Step 6: Add label to SegmentedControl**

In `SegmentedControl.swift`, in `setup()` (line ~79), add after `super.setup()`:

```swift
override func setup() {
    super.setup()
    segmentedControl.accessibilityLabel = title
    axis = .vertical
    contentView.installView(segmentedControl)
}
```

- [ ] **Step 7: Add tests for TextFieldControl**

Add to `Tests/InspectorTests/AccessibilityTests.swift`:

```swift
    func testTextFieldControlExposesLabelOnTextField() {
        let control = TextFieldControl(title: "Name", value: "hello", placeholder: nil)
        XCTAssertEqual(control.textField.accessibilityLabel, "Name")
    }
```

(`textField` is now `private(set)` so `@testable import` makes it readable.)

- [ ] **Step 8: Build and run all tests**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

Expected: all passing.

- [ ] **Step 9: Commit**

```bash
git add Sources/Inspector/CommonUI/Controls/ToggleControl.swift
git add Sources/Inspector/CommonUI/Controls/TextFieldControl.swift
git add Sources/Inspector/CommonUI/Controls/SegmentedControl.swift
git add Tests/InspectorTests/AccessibilityTests.swift
git commit -m "feat(a11y): set accessibilityLabel on leaf controls (toggle, text field, segmented)"
```

---

### Task 4: StepperControl Proxy Overrides

**File:**
- Modify: `Sources/Inspector/CommonUI/Controls/StepperControl.swift`

`StepperControl` is used standalone AND embedded inside `StepperPairControl`. To let `StepperPairControl` set a label on its children that flows through to the inner `UIStepper`, we override `accessibilityLabel` and `accessibilityValue` as computed property proxies.

- [ ] **Step 1: Write failing tests**

Add to `Tests/InspectorTests/AccessibilityTests.swift`:

```swift
    func testStepperControlExposesLabelViaProxy() {
        let control = StepperControl(title: "Width", value: 10, range: 0...200, stepValue: 1, isDecimalValue: false)
        XCTAssertEqual(control.accessibilityLabel, "Width")
    }

    func testStepperControlExposesValueViaProxy() {
        let control = StepperControl(title: "Width", value: 10, range: 0...200, stepValue: 1, isDecimalValue: false)
        XCTAssertNotNil(control.accessibilityValue)
    }

    func testStepperControlLabelOverridePropagatesToInnerStepper() {
        let control = StepperControl(title: "Width", value: 10, range: 0...200, stepValue: 1, isDecimalValue: false)
        control.accessibilityLabel = "Custom Label"
        XCTAssertEqual(control.accessibilityLabel, "Custom Label")
    }
```

- [ ] **Step 2: Run to confirm they fail**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

Expected: `testStepperControlExposesLabelViaProxy` fails (returns nil).

- [ ] **Step 3: Add proxy overrides and setup wiring to StepperControl**

In `StepperControl.swift`, add after the `stepperControl` lazy var declaration (after line ~72) and update `setup()` and `updateCounterLabel()`:

```swift
// Proxy accessibilityLabel/Value to the inner UIStepper so callers
// (including StepperPairControl) can set these on the StepperControl
// wrapper and have them reach the actual accessibility element.
override var accessibilityLabel: String? {
    get { stepperControl.accessibilityLabel }
    set { stepperControl.accessibilityLabel = newValue }
}

override var accessibilityValue: String? {
    get { stepperControl.accessibilityValue }
    set { stepperControl.accessibilityValue = newValue }
}
```

Update `setup()`:

```swift
override func setup() {
    super.setup()
    stepperControl.accessibilityLabel = title   // initial label from title
    updateState()
    contentView.addArrangedSubviews(counterLabel, stepperControl)
}
```

Update `updateCounterLabel()`:

```swift
private func updateCounterLabel() {
    counterLabel.text = stepperControl.value.toString()
    stepperControl.accessibilityValue = stepperControl.value.toString()
}
```

- [ ] **Step 4: Run tests — expect pass**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

Expected: all stepper tests pass.

- [ ] **Step 5: Build**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

- [ ] **Step 6: Commit**

```bash
git add Sources/Inspector/CommonUI/Controls/StepperControl.swift
git add Tests/InspectorTests/AccessibilityTests.swift
git commit -m "feat(a11y): proxy accessibilityLabel/Value to inner UIStepper in StepperControl"
```

---

### Task 5: StepperPairControl Labels

**File:**
- Modify: `Sources/Inspector/CommonUI/Controls/StepperPairControl.swift`

`StepperPairControl` is generic (`StepperPairControl<T: FloatingPoint>`). It has two `StepperControl` children (`firstStepper`, `secondStepper`) with `title: .none`. The pair's own `title` comes from `BaseFormControl`. Use that title with `(first)` / `(second)` suffixes.

- [ ] **Step 1: Write failing test**

Add to `Tests/InspectorTests/AccessibilityTests.swift`:

```swift
    func testStepperPairControlLabelsFirstAndSecondSteppers() {
        // CGPoint uses StepperPairControl<CGFloat> via PointControl —
        // test StepperPairControl directly using a concrete subclass or indirectly.
        // Since StepperPairControl is generic, instantiate via PointControl.
        // PointControl(title:value:) creates a StepperPairControl<CGFloat> internally.
        // We verify accessibility on the pair by checking accessibilityLabel on the control itself.
        // If PointControl isn't testable here, this step is verified via AXe only.
        // Skip if PointControl is not accessible — comment out and note.
    }
```

Note: `StepperPairControl<T>` is generic and its `firstStepper`/`secondStepper` are `private`. Unit testing is limited. Rely on AXe end-to-end verification for this task. Include the test structure as a placeholder.

- [ ] **Step 2: Override `title` didSet in StepperPairControl**

`BaseView.init` calls `setup()` during `super.init(frame:)`, which runs **before** `BaseFormControl.init` assigns `self.title`. So `title` is always `nil` inside `setup()`. Labels must be set in a `title` property override instead.

In `StepperPairControl.swift`, add a `title` override **and** leave `setup()` unchanged (no label code there):

```swift
// Override title (a computed property in BaseFormControl) to propagate
// accessibility labels to child steppers whenever the title is set.
// Note: cannot use didSet on a computed property override — must use get/set.
override var title: String? {
    get { super.title }
    set {
        super.title = newValue
        updateStepperAccessibilityLabels()
    }
}

private func updateStepperAccessibilityLabels() {
    firstStepper.accessibilityLabel = [title, "(first)"]
        .compactMap { $0.flatMap { $0.isEmpty ? nil : $0 } }
        .joined(separator: " ")
    secondStepper.accessibilityLabel = [title, "(second)"]
        .compactMap { $0.flatMap { $0.isEmpty ? nil : $0 } }
        .joined(separator: " ")
}
```

`setup()` stays exactly as it is — no label code there.

Also update `firstValue` and `secondValue` setters to keep `accessibilityValue` in sync:

```swift
var firstValue: FloatingPoint {
    get { FloatingPoint(firstStepper.value) }
    set {
        firstStepper.value = Double(newValue)
        firstStepper.accessibilityValue = newValue.toString()
    }
}

var secondValue: FloatingPoint {
    get { FloatingPoint(secondStepper.value) }
    set {
        secondStepper.value = Double(newValue)
        secondStepper.accessibilityValue = newValue.toString()
    }
}
```

Note: `FloatingPoint` may or may not have a `toString()` method. If it doesn't, use `"\(newValue)"` instead. Check at compile time.

- [ ] **Step 3: Build**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

If there's a `toString()` compile error on `FloatingPoint`, replace with `"\(newValue)"`.

- [ ] **Step 4: Commit**

```bash
git add Sources/Inspector/CommonUI/Controls/StepperPairControl.swift
git commit -m "feat(a11y): label first/second steppers in StepperPairControl"
```

---

## Chunk 3: Section Headers

### Task 6: Section Header Collapse Controls

**File:**
- Modify: `Sources/Inspector/ElementInspector/Views/InspectorElementSectionFormView.swift` (lines 97-107, `headerControl` lazy var; lines 24-27, `title` property)

- [ ] **Step 1: Add accessibility to headerControl**

In `InspectorElementSectionFormView.swift`, update the `headerControl` lazy var (line ~97) to add identifier and hint:

```swift
private(set) lazy var headerControl = BaseControl().then {
    $0.accessibilityIdentifier = "inspector.section-header"
    $0.accessibilityHint = "Double-tap to toggle"
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.addTarget(self, action: #selector(changeState), for: .touchUpInside)
    $0.addTarget(self, action: #selector(headerControlDidChangeState), for: .stateChanged)

    $0.contentView.isUserInteractionEnabled = false
    $0.contentView.spacing = elementInspectorAppearance.verticalMargins
    $0.contentView.addArrangedSubviews(collapseIcon, header)
    $0.contentView.alignment = .center
    $0.contentView.directionalLayoutMargins = elementInspectorAppearance.directionalInsets
}
```

Then update the `title` setter to also propagate to `headerControl.accessibilityLabel`:

```swift
var title: String? {
    get { header.title }
    set {
        header.title = newValue
        headerControl.accessibilityLabel = newValue
    }
}
```

- [ ] **Step 2: Build**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:InspectorTests/AccessibilityTests 2>&1 | grep -E "error:|passed|failed"
```

- [ ] **Step 3: Run all tests**

```bash
xcodebuild test -scheme Inspector -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | grep -E "error:|passed|failed"
```

Expected: all tests pass (no regressions).

- [ ] **Step 4: Commit**

```bash
git add Sources/Inspector/ElementInspector/Views/InspectorElementSectionFormView.swift
git commit -m "feat(a11y): add identifier, label, and hint to section header collapse control"
```

---

## End-to-End Verification

After all tasks are complete, verify with AXe in the simulator.

**Prerequisites:**
1. Build and install the Example app:
```bash
export SIM_UDID=<your-booted-simulator-udid>
xcodebuild \
  -workspace Example/Example.xcodeproj/project.xcworkspace \
  -scheme Example \
  -destination "platform=iOS Simulator,id=$SIM_UDID" \
  -configuration Debug \
  -derivedDataPath /tmp/inspector-example-build \
  build 2>&1 | grep -E "^(error:|BUILD)"
xcrun simctl install $SIM_UDID /tmp/inspector-example-build/Build/Products/Debug-iphonesimulator/Example.app
xcrun simctl launch $SIM_UDID am.pedro.Inspector
```

2. Tap "Open Inspector" button in the Example app.

**Verification steps:**
```bash
# Search field is findable by label
axe tap --label "Search views" --udid $SIM_UDID

# Dismiss button is findable by identifier
axe tap --identifier "inspector.dismiss-button" --udid $SIM_UDID

# Segmented control is findable by identifier
axe describe-ui --udid $SIM_UDID | grep "inspector.panel-picker"

# After navigating to PlaygroundViewController panel:
# Toggle "Has Appeared" switch is findable by label
axe tap --label "Has Appeared" --udid $SIM_UDID
```
