# UIControl.addAction Migration — Wave 2

**Date:** 2026-03-17
**Scope:** `Sources/Inspector/CommonUI/Controls/` — 7 files
**Goal:** Replace `addTarget(_:action:for:)` + `@objc` selector methods with `UIControl.addAction(_:for:)` closures. No public API changes.

---

## 1. Motivation

iOS 14 introduced `UIControl.addAction(_:for:)`, which lets you wire control events inline with a closure instead of a separate `@objc` method. Now that Inspector targets iOS 15+, there is no reason to keep selector-based internal wiring. The result is less boilerplate, no `@objc` exposure requirements, and the event handler is co-located with the wiring call.

---

## 2. The Transform

Every affected file follows the same mechanical change:

**Before:**
```swift
childControl.addTarget(self, action: #selector(methodName), for: .someEvent)

@objc private func methodName() {
    // body — always just: sendActions(for: .valueChanged)
}
```

**After:**
```swift
childControl.addAction(UIAction { [weak self] _ in
    self?.sendActions(for: .valueChanged)
}, for: .someEvent)
```

Rules:
- `[weak self]` capture on every closure to prevent retain cycles
- The `@objc` selector method is deleted entirely
- No other code in the file changes
- Public API (what consumers see via `UIControl` observation) is unchanged

---

## 3. Files

All 7 files are in `Sources/Inspector/CommonUI/Controls/`:

| File | Selector removed | Event |
|------|-----------------|-------|
| `StepperControl.swift` | `step()` | `.valueChanged` |
| `SegmentedControl.swift` | `changeSegment()` | `.valueChanged` |
| `TextFieldControl.swift` | `editText()` | `.editingChanged` |
| `RectControl.swift` | `valueChanged()` | `.valueChanged` (×4 steppers) |
| `EdgeInsetsControl.swift` | `valueChanged()` | `.valueChanged` (×4 steppers) |
| `DirectionalEdgeInsetsControl.swift` | `valueChanged()` | `.valueChanged` (×4 steppers) |
| `StepperPairControl.swift` | `valueChanged()` | `.valueChanged` (×2 steppers) |

**Out of scope:**
- `ToggleControl.swift` — selector body is non-trivial; left as-is
- `ColorPreviewControl.swift` — uses gesture recognizer, not `addTarget`
- `ImagePreviewControl.swift` — uses gesture recognizer, not `addTarget`

---

## 4. Success Criteria

```bash
grep -r 'addTarget\|@objc' Sources/Inspector/CommonUI/Controls/
```
Expected: no results (excluding `ToggleControl.swift` which is explicitly out of scope).

Build check:
```bash
xcodebuild build -project Example/Example.xcodeproj -scheme Inspector \
  -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.4' \
  | grep 'BUILD'
```
Expected: `BUILD SUCCEEDED`
