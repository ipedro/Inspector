# `.subpanel` Descriptor Design

**Goal:** Add a `.subpanel` case to `InspectorPropertyDescriptor` so a class annotated with `@InspectorPanel` can inline another component's inspector properties directly into its own section.

**Architecture:** Entirely macro-layer change. The generated `properties` getter switches from `compactMap` to `flatMap`, allowing a `.subpanel` case to emit a `.group` header followed by the child's own `properties`. No changes to the Inspector runtime, `InspectorElementProperty`, or any rendering code.

**Tech Stack:** SwiftSyntax 600.x, SPM macro plugin (`InspectorMacros`), `InspectorInterface`, `InspectorMacrosTests`.

---

## Touch Points

| File | Change |
|------|--------|
| `Sources/InspectorInterface/InspectorPanel.swift` | Add `.subpanel` case to `InspectorPropertyDescriptor` |
| `Sources/InspectorMacros/Helpers/PropertyDescriptorParser.swift` | Add `.subpanel` to `ResolvedDescriptor`; add `case "subpanel": return .subpanel` inside `parseSimpleCase(_:)`; do NOT add to `inferDescriptor` (`.subpanel` is explicit-only, never auto-inferred) |
| `Sources/InspectorMacros/InspectorPanelMacro.swift` | Change emitted `compactMap` → `flatMap`; add `.subpanel` case to `generatePropertyBuilder` |
| `Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift` | New test for `.subpanel` expansion; update existing tests for `flatMap` shape |

---

## Generated Code Shape

Given:

```swift
@InspectorPanel(title: "Playground")
class PlaygroundViewController: BaseViewController {
    @InspectorProperty(.subpanel)
    var inspectBarButton: RoundedButton!

    @InspectorProperty(.switch)
    var hasAppeared = false
}
```

The macro emits:

```swift
#if INSPECTOR_DEBUGGING
final class SectionDataSource: InspectorElementSectionDataSource {
    var state: InspectorElementSectionState = .collapsed
    let title = "Playground"
    private weak var element: PlaygroundViewController?
    init?(with object: NSObject) {
        guard let element = object as? PlaygroundViewController else { return nil }
        self.element = element
    }
    private enum Property: String, CaseIterable {
        case inspectBarButton = "Inspect Bar Button"
        case hasAppeared = "Has Appeared"
    }
    var properties: [InspectorElementProperty] {
        guard let element else { return [] }
        return Property.allCases.flatMap { property -> [InspectorElementProperty] in
            switch property {
            case .inspectBarButton:
                guard let child = element.inspectBarButton else { return [] }
                return [.group(title: property.rawValue)]
                    + (RoundedButton.SectionDataSource(with: child)?.properties ?? [])
            case .hasAppeared:
                return [.switch(
                    title: property.rawValue,
                    isOn: { element.hasAppeared },
                    handler: { element.hasAppeared = $0 }
                )]
            }
        }
    }
}
// ...InspectorLibrary unchanged
#endif
```

### Base type derivation

`ResolvedDescriptor.subpanel` is a **bare case** (no associated value). The child's base type name is read from `InspectableProperty.typeName` at code-generation time inside `generatePropertyBuilder`, not stored in `ResolvedDescriptor`. The stripping of optional markers (`!`, `?`) is done in `generatePropertyBuilder` by calling `trimmingCharacters(in: .init(charactersIn: "!?"))` on `prop.typeName`. This is separate from `inferDescriptor(forTypeName:)`, which is not involved.

`var inspectBarButton: RoundedButton!` → `prop.typeName = "RoundedButton!"` → base type `"RoundedButton"` → generates `RoundedButton.SectionDataSource(with: child)`.

`guard let child` is emitted **unconditionally** for all `.subpanel` cases regardless of the `isOptional` flag. The existing `isOptional` flag is `true` only for `?`-suffixed types; `!`-suffixed types have `isOptional = false`. Rather than introduce a separate `isImplicitlyUnwrapped` flag, the generator always emits the nil-guard for subpanels — this is safe for non-optional types too since `guard let x = someNonOptional` is a valid (if redundant) Swift pattern that the compiler accepts.

**Limitation:** spelled-out generic forms (`Optional<RoundedButton>`, `ImplicitlyUnwrappedOptional<T>`) are not handled. In practice, `@InspectorProperty(.subpanel)` is expected on `IBOutlet`-style properties (`Type!`) or plain optional properties (`Type?`), and these are the only forms supported.

### Runtime behaviour

- Child is `nil` at runtime (e.g. IBOutlet not yet connected): the `guard let child` returns `[]` — silent no-op, no crash.
- Child type has no `SectionDataSource` (not annotated with `@InspectorPanel`): compile error from the Swift compiler — `RoundedButton.SectionDataSource` does not exist. No extra diagnostic needed.
- Nested subpanels (grandchildren): work naturally — each child's `SectionDataSource.properties` already handles its own `.subpanel` cases.

---

## Public API

`InspectorPropertyDescriptor` is a `public` non-`@frozen` enum. Adding `.subpanel` is source-additive — it does not remove or rename any existing case. Per Swift's non-frozen enum rules, exhaustive `switch` statements over a non-frozen public enum in external modules already require `@unknown default` (the compiler warns without it). No migration guidance is needed beyond what Swift already enforces.

---

## Diagnostics

No new diagnostics in this iteration. Stricter enforcement (e.g. warning when `.subpanel` is applied to a non-class type) is deferred.

---

## Tests

### New test

`testSubpanelExpansion` — verifies the full expansion of a class with one `.subpanel` property:
- `Property` enum has `case inspectBarButton = "Inspect Bar Button"`
- `properties` getter uses `flatMap`
- `.subpanel` case emits `guard let child`, `.group` header, and `ChildType.SectionDataSource` delegation

### Updated tests

All existing `assertMacroExpansion` tests whose expected output contains `compactMap` must be updated to the `flatMap { -> [InspectorElementProperty] in }` shape with `return [...]` wrapping on each case.

### Nil-child path test

A second `.subpanel` test verifies the `guard let child` nil path: given a class where the subpanel property is implicitly unwrapped optional, the expanded `guard let child = element.propName else { return [] }` appears in the output. This confirms the nil case produces `[]` rather than crashing.
