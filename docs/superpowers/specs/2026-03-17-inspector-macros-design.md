# Inspector Macros — Design Spec

**Date:** 2026-03-17
**Scope:** New `InspectorInterface` + `InspectorMacros` SPM targets; zero changes to existing `Inspector` target; `Package.swift` updated to swift-tools-version 6.0
**Goal:** Let customers declare inspectable properties on their custom UIView subclasses with `@InspectorPanel` / `@InspectorProperty` attributes, and have all boilerplate generated automatically — only active when the `Debugging` Package Trait is enabled.

---

## 1. Motivation

Customers who want to inspect their custom UIKit components today must write a full `InspectorElementSectionDataSource` conforming type by hand: a failable `init?(with:)` that casts to the target type, a `Property` enum listing every row, a `properties` computed property that switches over that enum and wires each case to an `InspectorElementProperty` builder, and a separate `InspectorElementLibraryProtocol` conformer that ties the data source to the target class and panel type. This is the same ~70 lines of boilerplate for every custom component, with only the property list changing.

The goal is parity with the IBInspectable experience: tag the class and the properties you want exposed, get the panel for free.

---

## 2. Package Structure

### 2.1 Targets

Three SPM targets. No existing target is modified.

| Target | Kind | Always built | Purpose |
|---|---|---|---|
| `InspectorInterface` | Library | Yes — all configs | Declares `@InspectorPanel` and `@InspectorProperty` as macro attributes. Zero runtime code. |
| `InspectorMacros` | `.macro` executable | Only when `Debugging` trait is on | SwiftSyntax implementation of both macros. |
| `Inspector` | Library (existing) | Only when `Debugging` trait is on | Unchanged. Provides all runtime types. |

### 2.2 Package Traits

The package moves to `swift-tools-version: 6.0` and defines one trait:

```swift
// Package.swift (conceptual — exact SPM API to be confirmed during implementation)
traits: [
    .trait(
        name: "Debugging",
        description: "Enables the full Inspector debug runtime and macro expansion."
    )
]

.target(
    name: "InspectorInterface",
    dependencies: [
        .target(name: "InspectorMacros", condition: .when(traits: ["Debugging"])),
        .target(name: "Inspector",        condition: .when(traits: ["Debugging"])),
    ],
    swiftSettings: [
        .define("INSPECTOR_ENABLED", .when(traits: ["Debugging"]))
    ]
)
```

**Consumer integration:**

```swift
// Package.swift of the consuming app

// Debug / internal — Inspector runtime active:
.package(url: "…/Inspector", from: "2.0.0", traits: ["Debugging"])

// Release — only the thin InspectorInterface module:
.package(url: "…/Inspector", from: "2.0.0")
```

When `Debugging` is off: `Inspector` and `InspectorMacros` are not fetched, not compiled, not linked. `import InspectorInterface` still compiles because the macro declarations are gated with `#if INSPECTOR_ENABLED` and are simply absent in release — no type errors, no binary overhead. No Run Script phase needed to strip the framework from release archives.

**Why Traits over `#if canImport(Inspector)`:** `canImport` is unreliable in Xcode workspaces where sibling targets can pollute derived data search paths. Traits are explicit, build-system-agnostic, and prevent `Inspector` from being fetched at all in release — not just conditionally compiled.

---

## 3. Customer API

```swift
// Imported in all build configurations
import InspectorInterface

#if INSPECTOR_ENABLED
@InspectorPanel(title: "My Card View")
#endif
class MyCardView: UIView {

    #if INSPECTOR_ENABLED
    @InspectorProperty(.colorPicker)
    #endif
    var borderColor: UIColor = .clear

    #if INSPECTOR_ENABLED
    @InspectorProperty(.stepper(range: 0...100, step: 1))
    #endif
    var cornerRadius: CGFloat = 0

    #if INSPECTOR_ENABLED
    @InspectorProperty(.switch)
    #endif
    var showsBorder: Bool = false

    // Untagged properties are ignored
    var internalState: Bool = false
}
```

The `#if INSPECTOR_ENABLED` guards on the customer's annotations are required because the macro declarations themselves are absent in release builds. This is intentional — `@InspectorPanel` is debug-only code.

### 3.1 Type inference for the descriptor argument

When the property type maps unambiguously to a single control, the descriptor argument is optional:

| Property type | Default descriptor |
|---|---|
| `Bool` | `.switch` |
| `UIColor` / `UIColor?` | `.colorPicker` |
| `CGFloat` / `Double` / `Float` | `.stepper(range: 0...Double.infinity, step: 1)` |
| `String` / `String?` | `.textField` |
| `CGRect` | `.cgRect` |
| `CGPoint` | `.cgPoint` |
| `CGSize` | `.cgSize` |
| `UIOffset` | `.uiOffset` |
| `UIEdgeInsets` | `.edgeInsets` |
| `NSDirectionalEdgeInsets` | `.directionalInsets` |

For all other types (enums, `UIImage`, etc.) an explicit descriptor is required.

### 3.2 Registration

The generated `InspectorLibrary` type is registered via `InspectorCustomizationProviding`:

```swift
// Debug bootstrap — already inside #if INSPECTOR_ENABLED
struct MyDebugCustomization: InspectorCustomizationProviding {
    var elementLibraries: [Inspector.ElementPanelType: [InspectorElementLibraryProtocol]]? {
        [.attributes: [MyCardView.InspectorLibrary()]]
    }
    // other customization...
}
```

---

## 4. Macro Expansion

### 4.1 `@InspectorPanel` — `@attached(member)` macro

Applied to a class that is (or inherits from) `NSObject`. The macro:

1. Reads the `title` argument (required).
2. Scans the class's stored property declarations for `@InspectorProperty` annotations.
3. Derives a human-readable label for each from its name, split on camelCase (`borderColor` → `"Border Color"`), unless a `label:` override is provided.
4. Generates **two nested types** as new members of the annotated class, both wrapped in `#if INSPECTOR_ENABLED`.

**Generated output for the example above:**

```swift
// Generated by @InspectorPanel — added as members of MyCardView

#if INSPECTOR_ENABLED
final class SectionDataSource: InspectorElementSectionDataSource {
    var state: InspectorElementSectionState = .collapsed
    let title = "My Card View"

    private weak var element: MyCardView?

    init?(with object: NSObject) {
        guard let element = object as? MyCardView else { return nil }
        self.element = element
    }

    private enum Property: String, Swift.CaseIterable {
        case borderColor  = "Border Color"
        case cornerRadius = "Corner Radius"
        case showsBorder  = "Shows Border"
    }

    var properties: [InspectorElementProperty] {
        guard let element else { return [] }
        return Property.allCases.compactMap { property in
            switch property {
            case .borderColor:
                .colorPicker(
                    title: property.rawValue,
                    color: { element.borderColor },
                    handler: { newColor in
                        if let newColor { element.borderColor = newColor }
                    }
                )
            case .cornerRadius:
                .stepper(
                    title: property.rawValue,
                    value: { Double(element.cornerRadius) },
                    range: { 0.0...100.0 },
                    stepValue: { 1.0 },
                    isDecimalValue: true,
                    handler: { element.cornerRadius = CGFloat($0) }
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

struct InspectorLibrary: InspectorElementLibraryProtocol {
    var targetClass: AnyClass { MyCardView.self }

    func sections(for object: NSObject) -> InspectorElementSections {
        .init(with: SectionDataSource(with: object))
    }
}
#endif
```

**Notes on the generated code:**

- `subtitle`, `customClass`, and `titleAccessoryProperty` are not generated — the protocol's default extension covers them (`nil` / `nil` / `nil`).
- `.compactMap` allows individual cases to return `nil` if a property should be conditionally hidden.
- `init?(with object: NSObject)` is not protocol-required, but is the factory convention used by all element libraries. The macro always generates it.
- `UIColor` handler receives `UIColor?` — the macro generates an `if let` unwrap for non-optional stored properties.
- `CGFloat`/`Float`/`Double` are bridged to `Double` (`Double(…)` / `CGFloat($0)`) because `InspectorElementProperty.stepper` takes `DoubleProvider` / `DoubleHandler`. `isDecimalValue` is always `true` for these types.
- The `#if INSPECTOR_ENABLED` guard uses `IfConfigDeclSyntax` via SwiftSyntax, which is valid in member macro expansions (confirmed pattern in `swift-spyable`; requires `.poundIfToken()` constructor, not string interpolation).

### 4.2 `@InspectorProperty` — `@attached(peer)` macro

A peer macro that generates no code. It is a syntactic marker that `@InspectorPanel` reads during its member scan. `@attached(peer)` is the correct kind — `@attached(accessor)` would be incorrect because accessor macros must produce accessor bodies.

---

## 5. Supported `@InspectorProperty` Descriptors

| Descriptor | Maps to `InspectorElementProperty` case |
|---|---|
| `.switch` | `.switch(title:isOn:handler:)` |
| `.colorPicker` | `.colorPicker(title:emptyTitle:color:handler:)` |
| `.textField` | `.textField(title:placeholder:axis:value:handler:)` — placeholder: nil |
| `.textView` | `.textView(title:placeholder:value:handler:)` — placeholder: nil |
| `.imagePicker` | `.imagePicker(title:axis:image:handler:)` — axis: .vertical |
| `.stepper(range:step:)` | `.stepper(title:value:range:stepValue:isDecimalValue:handler:)` |
| `.optionsList(options:[String])` | `.optionsList(title:emptyTitle:axis:options:selectedIndex:handler:)` |
| `.textButtonGroup(texts:[String])` | `.textButtonGroup(title:axis:texts:selectedIndex:handler:)` |
| `.cgRect` | `.cgRect(title:rect:handler:)` |
| `.cgPoint` | `.cgPoint(title:point:handler:)` |
| `.cgSize` | `.cgSize(title:size:handler:)` |
| `.uiOffset` | `.uiOffset(title:offset:handler:)` |
| `.edgeInsets` | `.edgeInsets(title:insets:handler:)` |
| `.directionalInsets` | `.directionalInsets(title:insets:handler:)` |
| `.group(title:)` | `.group(title:subtitle:)` — non-interactive |
| `.separator` | `.separator` |
| `.infoNote(text:)` | `.infoNote(icon:title:text:)` |

---

## 6. Diagnostics

The macro emits compile-time errors for:

| Condition | Diagnostic |
|---|---|
| `@InspectorPanel` on a non-`NSObject` class | Error: requires `NSObject` subclass |
| `@InspectorProperty` on a computed property | Error: requires stored property |
| Descriptor incompatible with property type | Error: `.switch` cannot be used with `UIColor` |
| `@InspectorProperty` with no argument on unsupported type | Error: explicit descriptor required |
| `@InspectorPanel` with no `@InspectorProperty` members | Warning: panel will be empty |

---

## 7. Out of Scope

- `let` (read-only) properties — all wired properties must be `var`.
- Automatic discovery without annotation.
- Non-UIKit targets (AppKit, etc.) — v1 is UIKit / `NSObject` only.
- Auto-registration — intentionally excluded.

---

## 8. Versioning

This is a **major version (`2.0.0`)**. Breaking changes:
- `Package.swift` moves to `swift-tools-version: 6.0`.
- Consumers who want the full Inspector runtime must declare `traits: ["Debugging"]`.
- v1.x consumers are unaffected — the existing API is unchanged.

---

## 9. Success Criteria

1. A customer annotates a custom `NSObject` subclass with `@InspectorPanel` + `@InspectorProperty` and gets a working inspector panel with zero handwritten boilerplate.
2. In a release build (no `Debugging` trait), the app compiles cleanly with `import InspectorInterface` — no type errors, no Inspector binary in the archive, no Run Script phase needed.
3. In a debug build, the generated `SectionDataSource` and `InspectorLibrary` types are visible via Xcode's "Expand Macro" action.
4. Compile-time diagnostics fire for all invalid usage cases.
5. No existing `Inspector` target code or handwritten `SectionDataSource` classes are affected.
