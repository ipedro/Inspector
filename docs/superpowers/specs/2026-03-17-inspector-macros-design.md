# Inspector Macros — Design Spec

**Date:** 2026-03-17
**Scope:** New `InspectorInterface` + `InspectorMacros` SPM targets; zero changes to existing `Inspector` target
**Goal:** Let customers declare inspectable properties on their custom UIView subclasses with `@InspectorPanel` / `@InspectorProperty` attributes, and have the full `SectionDataSource` boilerplate generated automatically — only active when `Inspector` is linked.

---

## 1. Motivation

Customers who want to inspect their custom UIKit components today must write a full `InspectorElementSectionDataSource` subclass by hand: a failable `init?(with:)` that casts to the target type, a `Property` enum listing every row, and a `properties` computed property that switches over that enum and wires each case to an `InspectorElementProperty` builder. This is the same ~50 lines of boilerplate for every custom component, with only the property list changing.

The goal is parity with the old IBInspectable experience: tag the class and the properties you want exposed, get the panel for free.

---

## 2. Package Structure

Three SPM targets. No existing target is modified.

| Target | Kind | Always linked | Purpose |
|---|---|---|---|
| `InspectorInterface` | Library | Yes — all configs | Declares `@InspectorPanel` and `@InspectorProperty` as macro attributes. Zero runtime code. |
| `InspectorMacros` | Macro executable | Yes (compiler plugin, zero runtime cost) | SwiftSyntax implementation of both macros. |
| `Inspector` | Library (existing) | Debug / internal only | Unchanged. Provides `InspectorElementSectionDataSource` and all runtime types. |

**Dependency graph:**
```
InspectorInterface
    └── InspectorMacros (via `macros:` array in SPM target)

Inspector (standalone — no dependency on InspectorInterface)

CustomerApp (debug config)
    ├── InspectorInterface   ← always
    └── Inspector            ← debug only
```

`InspectorInterface` has no dependency on `Inspector`. The two are entirely independent at the SPM level.

---

## 3. Customer API

```swift
// Imported in all build configurations — zero binary cost in release
import InspectorInterface

@InspectorPanel(title: "My Card View")
class MyCardView: UIView {

    @InspectorProperty(.colorPicker)
    var borderColor: UIColor = .clear

    @InspectorProperty(.stepper(range: 0...100, step: 1))
    var cornerRadius: CGFloat = 0

    @InspectorProperty(.switch)
    var showsBorder: Bool = false

    // Untagged properties are ignored — no annotation, no row
    var internalState: Bool = false
}
```

### Type inference for the descriptor argument

When the property type maps unambiguously to a single control, the descriptor argument is optional:

| Property type | Default control |
|---|---|
| `Bool` | `.switch` |
| `UIColor` | `.colorPicker` |
| `CGFloat` / `Double` / `Float` | `.stepper` |
| `String` | `.textField` |

`@InspectorProperty` with no argument is valid for these types. An explicit descriptor is required for everything else (enums → `.optionsList`, `UIImage` → `.imagePicker`, etc.) and always accepted as an override.

### Registration

After the macro generates the `SectionDataSource`, the customer registers it once inside their existing Inspector setup (debug only):

```swift
// AppDelegate or debug bootstrap — inside #if canImport(Inspector)
Inspector.manager.setup(
    .init(elementLibraries: [MyCardViewSectionDataSource.self])
)
```

No auto-registration magic. The customer's debug setup block is already the natural place for this.

---

## 4. Macro Expansion

### `@InspectorPanel` — `@attached(member)` macro

Applied to a `class` that is (or inherits from) `NSObject`. The macro:

1. Reads the `title` argument (required).
2. Scans the class's stored property declarations for `@InspectorProperty` annotations.
3. Derives a human-readable label for each property: the `label` argument if provided, otherwise the property name split on camelCase (e.g. `borderColor` → `"Border Color"`).
4. Generates one nested class, wrapped entirely in `#if canImport(Inspector)`.

**Generated output for the example above:**

```swift
#if canImport(Inspector)
final class MyCardViewSectionDataSource: InspectorElementSectionDataSource {
    var state: InspectorElementSectionState = .collapsed
    let title = "My Card View"
    var subtitle: String? { nil }
    var customClass: InspectorElementSectionView.Type? { nil }
    var titleAccessoryProperty: InspectorElementProperty? { nil }

    private weak var element: MyCardView?

    init?(with object: NSObject) {
        guard let element = object as? MyCardView else { return nil }
        self.element = element
    }

    private enum Property: String, CaseIterable {
        case borderColor = "Border Color"
        case cornerRadius = "Corner Radius"
        case showsBorder = "Shows Border"
    }

    var properties: [InspectorElementProperty] {
        guard let element else { return [] }
        return Property.allCases.map { property in
            switch property {
            case .borderColor:
                .colorPicker(
                    title: property.rawValue,
                    color: { element.borderColor },
                    handler: { element.borderColor = $0 }
                )
            case .cornerRadius:
                .stepper(
                    title: property.rawValue,
                    value: { element.cornerRadius },
                    range: { 0...100 },
                    stepValue: { 1 },
                    handler: { element.cornerRadius = $0 }
                )
            case .showsBorder:
                .switch(
                    title: property.rawValue,
                    isOn: { element.showsBorder },
                    handler: { element.showsBorder = $0 }
                )
            }
        }
    }
}
#endif
```

### `@InspectorProperty` — `@attached(accessor)` macro (peer, no-op)

`@InspectorProperty` is a peer macro that generates no code on its own. It exists solely as a marker that `@InspectorPanel` reads during its member scan. In release builds (where `InspectorInterface` is imported but `Inspector` is not), it expands to nothing and has zero impact on the annotated property.

### Compilation guard

All generated `SectionDataSource` code is wrapped in `#if canImport(Inspector)`. Since SPM only adds a target's `.swiftmodule` to the search paths of targets that declare it as a dependency, this guard is `false` in any configuration where `Inspector` is not a dependency — which is exactly release builds.

**Known limitation:** In Xcode workspaces with sibling targets that share derived data, `canImport` may evaluate to `true` unexpectedly. Customers using `.xcworkspace` (not pure SPM) should additionally set `INSPECTOR_ENABLED` in their Swift Active Compilation Conditions and switch the guard to `#if INSPECTOR_ENABLED` if they observe this.

---

## 5. Supported `@InspectorProperty` Descriptors

These map 1-to-1 to existing `InspectorElementProperty` builders:

```swift
.switch
.colorPicker
.textField
.textView
.imagePicker(axis:)
.stepper(range:step:)
.optionsList(options:)          // options: [String] or RawRepresentable enum
.textButtonGroup(options:)
.imageButtonGroup(images:)
.cgFloat
.cgPoint
.cgSize
.cgRect
.edgeInsets
.directionalInsets
.group(title:subtitle:)         // non-interactive section header row
.separator
.infoNote(text:)
```

The macro validates at compile time that the chosen descriptor is compatible with the property's declared type and emits a diagnostic if not (e.g. `@InspectorProperty(.switch)` on a `UIColor` property).

---

## 6. Error Handling & Diagnostics

The macro emits compile-time diagnostics (not runtime crashes) for:

- `@InspectorPanel` applied to a non-`NSObject` class — required because `init?(with object: NSObject)` must cast.
- `@InspectorProperty` applied to a computed property — only stored properties can be wired bidirectionally.
- `@InspectorProperty` descriptor incompatible with the property's declared type.
- `@InspectorProperty` with no argument on a type that has no default descriptor.

---

## 7. Out of Scope

- Inspecting `let` (read-only) properties — all wired properties must be `var`.
- Automatic discovery without annotation (`@InspectorPanel` on a class with no `@InspectorProperty` tags generates an empty `properties` array and emits a warning).
- Support for non-UIKit targets (macOS Catalyst, etc.) — out of scope for v1.
- Generating the `DefaultElementAttributesLibrary` registration automatically — manual registration in the debug bootstrap is intentional.

---

## 8. Success Criteria

1. A customer can annotate a custom `UIView` subclass with `@InspectorPanel` + `@InspectorProperty` attributes and have a working inspector panel with zero handwritten boilerplate.
2. In a release build (where `Inspector` is not linked), the customer's app compiles cleanly with `InspectorInterface` imported — no type errors, no unused code.
3. Macro expansion is visible in Xcode's "Expand Macro" action, showing the generated `SectionDataSource` class.
4. Compile-time diagnostics fire for invalid usage (wrong type, computed property, missing descriptor).
5. Existing `Inspector` target and all existing handwritten `SectionDataSource` classes are unaffected.
