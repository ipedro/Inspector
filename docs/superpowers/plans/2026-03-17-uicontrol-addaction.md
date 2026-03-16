# UIControl.addAction Migration Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `addTarget(_:action:for:)` + `@objc` selector methods with `UIControl.addAction(_:for:)` closures across 7 controls in `CommonUI/Controls/`.

**Architecture:** Each task is a single-file, mechanical substitution: remove the `addTarget` call and its `@objc` selector method, replace with an inline `UIAction` closure. Tasks 1–7 are fully independent and can run in parallel. Task 8 is the final verification gate.

**Tech Stack:** Swift 5.10, UIKit, `UIControl.addAction(_:for:)` (iOS 14+).

**Spec:** `docs/superpowers/specs/2026-03-17-uicontrol-addaction-design.md`

---

## The Transform (reference for all tasks)

**Before pattern:**
```swift
someChildControl.addTarget(self, action: #selector(foo), for: .valueChanged)

@objc private func foo() {
    sendActions(for: .valueChanged)
}
```

**After pattern:**
```swift
someChildControl.addAction(UIAction { [weak self] _ in
    self?.sendActions(for: .valueChanged)
}, for: .valueChanged)
```

Rules:
- `[weak self]` on every closure (child control owns the UIAction; without it: self → child → action → self cycle)
- Delete the entire `@objc` selector method
- Touch nothing else in the file

---

## Chunk 1: StepperControl (non-trivial)

### Task 1: Migrate `StepperControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/StepperControl.swift`

⚠️ `step()` is non-trivial — it calls `updateCounterLabel()` before `sendActions`. Both calls must be preserved in the closure.

- [ ] **Step 1: Read the file and locate the wiring**

  Find the `addTarget` call that wires the internal `UIStepper` to `#selector(step)`, and the `step()` method itself. Confirm `step()` body is:
  ```swift
  updateCounterLabel()
  sendActions(for: .valueChanged)
  ```

- [ ] **Step 2: Replace `addTarget` with `addAction`**

  Replace:
  ```swift
  stepper.addTarget(self, action: #selector(step), for: .valueChanged)
  ```
  With:
  ```swift
  stepper.addAction(UIAction { [weak self] _ in
      self?.updateCounterLabel()
      self?.sendActions(for: .valueChanged)
  }, for: .valueChanged)
  ```

- [ ] **Step 3: Delete the `step()` selector method**

  Remove the entire `@objc func step()` method (including the `@objc` annotation line).

- [ ] **Step 4: Verify no `addTarget` or `@objc` remains**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/StepperControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/StepperControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in StepperControl"
  ```

---

## Chunk 2: Single-child controls

### Task 2: Migrate `SegmentedControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/SegmentedControl.swift`

- [ ] **Step 1: Locate the wiring**

  Find `addTarget(self, action: #selector(changeSegment), for: .valueChanged)` and the `changeSegment()` method. Confirm `changeSegment()` body is just `sendActions(for: .valueChanged)`.

- [ ] **Step 2: Replace `addTarget` with `addAction`**

  Replace:
  ```swift
  segmentedControl.addTarget(self, action: #selector(changeSegment), for: .valueChanged)
  ```
  With:
  ```swift
  segmentedControl.addAction(UIAction { [weak self] _ in
      self?.sendActions(for: .valueChanged)
  }, for: .valueChanged)
  ```

- [ ] **Step 3: Delete `changeSegment()`**

  Remove the entire `@objc func changeSegment()` method.

- [ ] **Step 4: Verify**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/SegmentedControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/SegmentedControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in SegmentedControl"
  ```

---

### Task 3: Migrate `TextFieldControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/TextFieldControl.swift`

Note: the event here is `.editingChanged`, not `.valueChanged`.

- [ ] **Step 1: Locate the wiring**

  Find `addTarget(self, action: #selector(editText), for: .editingChanged)` and the `editText()` method. Confirm `editText()` body is just `sendActions(for: .valueChanged)`.

- [ ] **Step 2: Replace `addTarget` with `addAction`**

  Replace:
  ```swift
  textField.addTarget(self, action: #selector(editText), for: .editingChanged)
  ```
  With:
  ```swift
  textField.addAction(UIAction { [weak self] _ in
      self?.sendActions(for: .valueChanged)
  }, for: .editingChanged)
  ```

- [ ] **Step 3: Delete `editText()`**

  Remove the entire `@objc func editText()` method.

- [ ] **Step 4: Verify**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/TextFieldControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/TextFieldControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in TextFieldControl"
  ```

---

## Chunk 3: Multi-stepper controls

### Task 4: Migrate `RectControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/RectControl.swift`

This control wires 4 internal `StepperControl` instances to the same `valueChanged()` selector.

- [ ] **Step 1: Locate the wiring**

  Find 4 `addTarget(self, action: #selector(valueChanged), for: .valueChanged)` calls and the single `valueChanged()` method. Confirm `valueChanged()` body is just `sendActions(for: .valueChanged)`.

- [ ] **Step 2: Replace all 4 `addTarget` calls with `addAction`**

  For each of the 4 stepper controls (e.g. `xStepper`, `yStepper`, `widthStepper`, `heightStepper` — use actual property names from the file), replace:
  ```swift
  xStepper.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
  ```
  With:
  ```swift
  xStepper.addAction(UIAction { [weak self] _ in
      self?.sendActions(for: .valueChanged)
  }, for: .valueChanged)
  ```
  Repeat for all 4.

- [ ] **Step 3: Delete `valueChanged()`**

  Remove the entire `@objc func valueChanged()` method.

- [ ] **Step 4: Verify**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/RectControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/RectControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in RectControl"
  ```

---

### Task 5: Migrate `EdgeInsetsControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/EdgeInsetsControl.swift`

Same pattern as `RectControl` — 4 stepper children, one `valueChanged()` selector.

- [ ] **Step 1: Locate the wiring**

  Find 4 `addTarget(self, action: #selector(valueChanged), for: .valueChanged)` calls and the `valueChanged()` method.

- [ ] **Step 2: Replace all 4 `addTarget` calls with `addAction`**

  For each stepper property (use actual names from the file):
  ```swift
  stepper.addAction(UIAction { [weak self] _ in
      self?.sendActions(for: .valueChanged)
  }, for: .valueChanged)
  ```

- [ ] **Step 3: Delete `valueChanged()`**

- [ ] **Step 4: Verify**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/EdgeInsetsControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/EdgeInsetsControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in EdgeInsetsControl"
  ```

---

### Task 6: Migrate `DirectionalEdgeInsetsControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/DirectionalEdgeInsetsControl.swift`

Same pattern — 4 stepper children, one `valueChanged()` selector.

- [ ] **Step 1: Locate the wiring**

  Find 4 `addTarget` calls wiring to `#selector(valueChanged)` and the `valueChanged()` method.

- [ ] **Step 2: Replace all 4 `addTarget` calls with `addAction`**

  For each stepper:
  ```swift
  stepper.addAction(UIAction { [weak self] _ in
      self?.sendActions(for: .valueChanged)
  }, for: .valueChanged)
  ```

- [ ] **Step 3: Delete `valueChanged()`**

- [ ] **Step 4: Verify**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/DirectionalEdgeInsetsControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/DirectionalEdgeInsetsControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in DirectionalEdgeInsetsControl"
  ```

---

### Task 7: Migrate `StepperPairControl.swift`

**File:** `Sources/Inspector/CommonUI/Controls/StepperPairControl.swift`

Same pattern — 2 stepper children (not 4), one `valueChanged()` selector.

- [ ] **Step 1: Locate the wiring**

  Find 2 `addTarget` calls wiring to `#selector(valueChanged)` and the `valueChanged()` method.

- [ ] **Step 2: Replace both `addTarget` calls with `addAction`**

  For each stepper:
  ```swift
  stepper.addAction(UIAction { [weak self] _ in
      self?.sendActions(for: .valueChanged)
  }, for: .valueChanged)
  ```

- [ ] **Step 3: Delete `valueChanged()`**

- [ ] **Step 4: Verify**

  ```bash
  grep 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/StepperPairControl.swift
  ```
  Expected: no output.

- [ ] **Step 5: Commit**

  ```bash
  git add Sources/Inspector/CommonUI/Controls/StepperPairControl.swift
  git commit -m "chore: replace addTarget with UIAction closure in StepperPairControl"
  ```

---

## Chunk 4: Final Verification

> Run after Tasks 1–7 are all complete.

### Task 8: Verify and build

- [ ] **Step 1: Run success criteria grep**

  ```bash
  grep -r 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/
  ```
  Expected: results **only** from `ToggleControl.swift` (two `addTarget` + two `@objc`) and `TextViewControl.swift` (one `@objc` delegate method). No other files.

- [ ] **Step 2: Build**

  ```bash
  xcodebuild build -project Example/Example.xcodeproj -scheme Inspector \
    -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.4' \
    | grep 'BUILD'
  ```
  Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Final commit if anything was missed**

  If Step 1 found stray results in unexpected files, fix and commit:
  ```bash
  git add Sources/Inspector/CommonUI/Controls/
  git commit -m "chore: fix remaining addTarget/selector in Controls"
  ```
