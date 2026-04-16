# Inspector Macros Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Introduce `@InspectorPanel` / `@InspectorProperty` Swift macros that generate `SectionDataSource` + `InspectorLibrary` boilerplate for customers' custom UIKit components, gated entirely behind a Package Trait so Inspector is never compiled into release builds.

**Architecture:** Three new SPM targets are added to the existing package: `InspectorInterface` (thin always-importable module with macro declarations), `InspectorMacros` (compiler plugin that does the expansion), and a `InspectorMacrosTests` test target. The `Debugging` Package Trait gates whether `InspectorMacros` and the existing `Inspector` target are compiled. When the trait is off, `@InspectorPanel` / `@InspectorProperty` are absent from `InspectorInterface` and customer code compiles cleanly with no Inspector dependency.

**Tech Stack:** Swift 6.0, swift-tools-version 6.0, SwiftSyntax 600.x (`swift-syntax` package), `SwiftSyntaxMacros`, `SwiftCompilerPlugin`, `SwiftSyntaxMacrosTestSupport` (for tests). Tests run with `swift test` — no iOS simulator required.

**Spec:** `docs/superpowers/specs/2026-03-17-inspector-macros-design.md`

---

## File Map

### New files
| File | Purpose |
|---|---|
| `Sources/InspectorInterface/InspectorPanel.swift` | Macro declarations (`@InspectorPanel`, `@InspectorProperty`) + `InspectorPropertyDescriptor` enum |
| `Sources/InspectorMacros/InspectorMacrosPlugin.swift` | `@main CompilerPlugin` entry point — registers both macros |
| `Sources/InspectorMacros/InspectorPanelMacro.swift` | `@attached(member)` macro — core implementation |
| `Sources/InspectorMacros/InspectorPropertyMacro.swift` | `@attached(peer)` no-op marker macro |
| `Sources/InspectorMacros/Helpers/CamelCaseConverter.swift` | `"borderColor"` → `"Border Color"` utility |
| `Sources/InspectorMacros/Helpers/PropertyDescriptorParser.swift` | Parses `@InspectorProperty(...)` attribute syntax → `ResolvedDescriptor` |
| `Sources/InspectorMacros/Helpers/InspectorMacroDiagnostic.swift` | Typed diagnostic messages |
| `Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift` | `assertMacroExpansion` tests |
| `Tests/InspectorMacrosTests/CamelCaseConverterTests.swift` | Unit tests for camelCase converter |

### Modified files
| File | Change |
|---|---|
| `Package.swift` | swift-tools-version 6.0, add `Debugging` trait, add `swift-syntax` dep, add 3 new targets |

---

## Chunk 1: Package Scaffolding

### Task 1: Update Package.swift

**Files:**
- Modify: `Package.swift`

- [ ] **Step 1: Replace the entire Package.swift with the updated version**

```swift
// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Inspector",
    platforms: [
        .iOS(.v15)
    ],
    traits: [
        .trait(
            name: "Debugging",
            description: "Enables the full Inspector debug runtime, macro expansion, and InspectorInterface."
        )
    ],
    products: [
        .library(
            name: "Inspector",
            targets: ["Inspector"]
        ),
        .library(
            name: "InspectorDynamic",
            type: .dynamic,
            targets: ["Inspector"]
        ),
        .library(
            name: "InspectorInterface",
            targets: ["InspectorInterface"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ipedro/UIKeyCommandTableView.git", from: "1.0.0"),
        .package(url: "https://github.com/ipedro/UIKeyboardAnimatable.git", from: "1.0.0"),
        .package(url: "https://github.com/ipedro/Coordinator.git", from: "2.1.2"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0")
    ],
    targets: [
        // MARK: - Existing

        .target(
            name: "Inspector",
            dependencies: [
                "UIKeyCommandTableView",
                "UIKeyboardAnimatable",
                "Coordinator"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "InspectorTests",
            dependencies: ["Inspector"]
        ),

        // MARK: - New: Macro executable

        .macro(
            name: "InspectorMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),

        // MARK: - New: Thin always-importable interface

        .target(
            name: "InspectorInterface",
            dependencies: [
                .target(
                    name: "InspectorMacros",
                    condition: .when(traits: ["Debugging"])
                ),
                .target(
                    name: "Inspector",
                    condition: .when(traits: ["Debugging"])
                )
            ],
            swiftSettings: [
                .define("INSPECTOR_DEBUGGING", .when(traits: ["Debugging"]))
            ]
        ),

        // MARK: - New: Macro tests

        .testTarget(
            name: "InspectorMacrosTests",
            dependencies: [
                "InspectorMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
```

⚠️ **Package Traits API note:** The `.when(traits:)` condition on target-level dependencies (`Target.Dependency.Condition`) and `swiftSettings` was introduced in SE-0450 (swift-tools-version 6.0). Verify the API compiles in your toolchain by running `swift build` first. If `.when(traits:)` is not available on `Target.Dependency.Condition` (i.e. only supported on package-level dependency conditions), use this fallback: remove the `condition:` parameters from the `InspectorInterface` target dependencies (always link both), and rely solely on `swiftSettings: [.define("INSPECTOR_DEBUGGING", .when(traits: ["Debugging"]))]` for the compilation gate. The `#if INSPECTOR_DEBUGGING` guards in source files will still prevent the generated code from compiling in release. The only downside is that `Inspector` and `InspectorMacros` are always compiled even in release — the generated code just stays dead.

- [ ] **Step 2: Resolve packages and verify it builds**

```bash
cd /path/to/Inspector
swift package resolve
swift build --target InspectorMacros
```

Expected: resolves `swift-syntax` and builds without errors. The `InspectorInterface` and `InspectorMacrosTests` targets will fail until source files exist — that's expected.

- [ ] **Step 3: Create the InspectorInterface source directory**

```bash
mkdir -p Sources/InspectorInterface
```

- [ ] **Step 4: Create the InspectorMacros source directories**

```bash
mkdir -p Sources/InspectorMacros/Helpers
mkdir -p Tests/InspectorMacrosTests
```

- [ ] **Step 5: Commit**

```bash
git add Package.swift Package.resolved
git commit -m "chore: add swift-syntax dep, Debugging trait, InspectorInterface + InspectorMacros targets"
```

---

### Task 2: Create InspectorInterface source — macro declarations + descriptor type

**Files:**
- Create: `Sources/InspectorInterface/InspectorPanel.swift`

All declarations in this file are gated behind `#if INSPECTOR_DEBUGGING`. When the `Debugging` trait is off, this file compiles to nothing — the macro attributes simply don't exist.

- [ ] **Step 1: Create the file**

```swift
// Sources/InspectorInterface/InspectorPanel.swift

#if INSPECTOR_DEBUGGING

// MARK: - @InspectorPanel

/// Attach to a UIView subclass to generate an InspectorElementSectionDataSource
/// and InspectorElementLibraryProtocol conformance for use with the Inspector debug library.
///
/// Example:
/// ```swift
/// @InspectorPanel(title: "My Card View")
/// class MyCardView: UIView {
///     @InspectorProperty(.colorPicker)
///     var borderColor: UIColor = .clear
/// }
/// ```
/// Generates `MyCardView.SectionDataSource` and `MyCardView.InspectorLibrary`
/// inside `#if INSPECTOR_DEBUGGING` guards.
@attached(member, names: named(SectionDataSource), named(InspectorLibrary))
public macro InspectorPanel(title: String) =
    #externalMacro(module: "InspectorMacros", type: "InspectorPanelMacro")

// MARK: - @InspectorProperty

/// Marks a stored property as inspectable. @InspectorPanel reads this annotation
/// during macro expansion — it generates no code on its own.
///
/// - Parameter descriptor: The inspector control to use. Omit for type-inferred default.
@attached(peer)
public macro InspectorProperty(
    _ descriptor: InspectorPropertyDescriptor = .auto
) = #externalMacro(module: "InspectorMacros", type: "InspectorPropertyMacro")

// MARK: - InspectorPropertyDescriptor

/// Describes which Inspector control to use for an @InspectorProperty-annotated property.
public enum InspectorPropertyDescriptor {
    // Interactive controls
    case `switch`
    case colorPicker
    case stepper(range: ClosedRange<Double> = 0...Double.infinity, step: Double = 1)
    case textField
    case textView
    case imagePicker
    case optionsList(options: [String])
    case textButtonGroup(texts: [String])

    // Struct controls
    case cgRect
    case cgPoint
    case cgSize
    case uiOffset
    case edgeInsets
    case directionalInsets

    // Non-interactive
    case group(title: String)
    case separator
    case infoNote(text: String)

    /// Type-inferred: the macro chooses the control based on the property's declared type.
    case auto
}

#endif
```

- [ ] **Step 2: Verify the InspectorInterface target builds**

```bash
swift build --target InspectorInterface
```

Expected: builds successfully (the `#if INSPECTOR_DEBUGGING` block compiles to nothing since the trait is off by default in local builds without explicit trait activation).

- [ ] **Step 3: Commit**

```bash
git add Sources/InspectorInterface/InspectorPanel.swift
git commit -m "feat: add InspectorInterface target with @InspectorPanel, @InspectorProperty declarations"
```

---

## Chunk 2: InspectorMacros — Foundation

### Task 3: Plugin entry point + no-op InspectorPropertyMacro

**Files:**
- Create: `Sources/InspectorMacros/InspectorMacrosPlugin.swift`
- Create: `Sources/InspectorMacros/InspectorPropertyMacro.swift`

- [ ] **Step 1: Create the compiler plugin entry point**

```swift
// Sources/InspectorMacros/InspectorMacrosPlugin.swift

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct InspectorMacrosPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        InspectorPanelMacro.self,
        InspectorPropertyMacro.self,
    ]
}
```

- [ ] **Step 2: Create the no-op InspectorPropertyMacro**

```swift
// Sources/InspectorMacros/InspectorPropertyMacro.swift

import SwiftSyntax
import SwiftSyntaxMacros

/// A marker-only peer macro. Generates nothing.
/// @InspectorPanel reads @InspectorProperty annotations during its member scan.
public struct InspectorPropertyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
```

- [ ] **Step 3: Create a stub InspectorPanelMacro so the plugin compiles**

```swift
// Sources/InspectorMacros/InspectorPanelMacro.swift

import SwiftSyntax
import SwiftSyntaxMacros

public struct InspectorPanelMacro: MemberMacro {
    // Use the 3-parameter form — the 4-parameter form (with `conformingTo:`) is only
    // called for macros declared with `@attached(member, conformances:...)`.
    // Using the wrong overload compiles but is silently never called.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // TODO: full implementation in Tasks 4–6
        return []
    }
}
```

- [ ] **Step 4: Verify the InspectorMacros target builds**

```bash
swift build --target InspectorMacros
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 5: Commit**

```bash
git add Sources/InspectorMacros/InspectorMacrosPlugin.swift \
        Sources/InspectorMacros/InspectorPropertyMacro.swift \
        Sources/InspectorMacros/InspectorPanelMacro.swift
git commit -m "feat: add InspectorMacros plugin entry point and no-op InspectorPropertyMacro"
```

---

### Task 4: CamelCase converter + diagnostic types

**Files:**
- Create: `Sources/InspectorMacros/Helpers/CamelCaseConverter.swift`
- Create: `Sources/InspectorMacros/Helpers/InspectorMacroDiagnostic.swift`
- Create: `Tests/InspectorMacrosTests/CamelCaseConverterTests.swift`

- [ ] **Step 1: Write the failing tests for the camelCase converter**

```swift
// Tests/InspectorMacrosTests/CamelCaseConverterTests.swift

import XCTest
@testable import InspectorMacros

final class CamelCaseConverterTests: XCTestCase {

    func testSingleWord() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("color"), "Color")
    }

    func testTwoWords() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("borderColor"), "Border Color")
    }

    func testThreeWords() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("cornerRadius"), "Corner Radius")
    }

    func testAcronymHandling() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("isHidden"), "Is Hidden")
    }

    func testAlreadyCapitalized() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("showsBorder"), "Shows Border")
    }

    func testSingleCharacterSegments() {
        XCTAssertEqual(CamelCaseConverter.toDisplayName("xPosition"), "X Position")
    }

    func testConsecutiveUppercaseAcronym() {
        // Acronym run: space inserted before the last uppercase that starts a new word
        XCTAssertEqual(CamelCaseConverter.toDisplayName("URLString"), "URL String")
    }
}
```

- [ ] **Step 2: Run to verify they fail**

```bash
swift test --filter CamelCaseConverterTests
```

Expected: compile error — `CamelCaseConverter` not found.

- [ ] **Step 3: Implement CamelCaseConverter**

```swift
// Sources/InspectorMacros/Helpers/CamelCaseConverter.swift

enum CamelCaseConverter {
    /// Converts a camelCase identifier to a space-separated display name.
    /// "borderColor"  → "Border Color"
    /// "URLString"    → "URL String"  (acronym run: space before last uppercase of a run)
    /// "isHidden"     → "Is Hidden"
    static func toDisplayName(_ identifier: String) -> String {
        guard !identifier.isEmpty else { return "" }
        var result = ""
        let chars = Array(identifier)

        for i in 0..<chars.count {
            let c = chars[i]
            if c.isUppercase && i > 0 {
                let prev = chars[i - 1]
                let next: Character? = i + 1 < chars.count ? chars[i + 1] : nil
                // Insert a space before this uppercase letter if:
                // – previous was lowercase ("borderColor" → "border|Color")
                // – previous was uppercase AND next is lowercase ("URLString" → "URL|String")
                if prev.isLowercase || (prev.isUppercase && next?.isLowercase == true) {
                    result.append(" ")
                }
            }
            result.append(c)
        }

        // Capitalise the first character
        return result.prefix(1).uppercased() + result.dropFirst()
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```bash
swift test --filter CamelCaseConverterTests
```

Expected: all 6 tests pass.

- [ ] **Step 5: Create diagnostic types**

```swift
// Sources/InspectorMacros/Helpers/InspectorMacroDiagnostic.swift

import SwiftDiagnostics
import SwiftSyntax

enum InspectorMacroDiagnostic: DiagnosticMessage {
    case notAClass
    case notAStoredProperty
    case missingTitle
    case noInspectableProperties
    case unsupportedTypeForAutoDescriptor(typeName: String)
    case descriptorTypeMismatch(descriptor: String, typeName: String)

    var message: String {
        switch self {
        case .notAClass:
            return "@InspectorPanel can only be applied to a class"
        case .notAStoredProperty:
            return "@InspectorProperty can only be applied to a stored var property"
        case .missingTitle:
            return "@InspectorPanel requires a non-empty title argument"
        case .noInspectableProperties:
            return "@InspectorPanel found no @InspectorProperty-annotated stored properties — panel will be empty"
        case .unsupportedTypeForAutoDescriptor(let typeName):
            return "@InspectorProperty requires an explicit descriptor for '\(typeName)' — no default control exists for this type"
        case .descriptorTypeMismatch(let descriptor, let typeName):
            return "@InspectorProperty(\(descriptor)) is not compatible with '\(typeName)'"
        }
    }

    // Use stable string IDs — do NOT use String(describing: self) here because
    // cases with associated values produce IDs that include runtime values (unstable).
    var diagnosticID: MessageID {
        switch self {
        case .notAClass:
            return MessageID(domain: "InspectorMacros", id: "notAClass")
        case .notAStoredProperty:
            return MessageID(domain: "InspectorMacros", id: "notAStoredProperty")
        case .missingTitle:
            return MessageID(domain: "InspectorMacros", id: "missingTitle")
        case .noInspectableProperties:
            return MessageID(domain: "InspectorMacros", id: "noInspectableProperties")
        case .unsupportedTypeForAutoDescriptor:
            return MessageID(domain: "InspectorMacros", id: "unsupportedTypeForAutoDescriptor")
        case .descriptorTypeMismatch:
            return MessageID(domain: "InspectorMacros", id: "descriptorTypeMismatch")
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .noInspectableProperties:
            return .warning
        default:
            return .error
        }
    }
}
```

- [ ] **Step 6: Build to verify**

```bash
swift build --target InspectorMacros
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 7: Commit**

```bash
git add Sources/InspectorMacros/Helpers/CamelCaseConverter.swift \
        Sources/InspectorMacros/Helpers/InspectorMacroDiagnostic.swift \
        Tests/InspectorMacrosTests/CamelCaseConverterTests.swift
git commit -m "feat: add CamelCaseConverter and InspectorMacroDiagnostic types"
```

---

## Chunk 3: InspectorMacros — Core Generation

### Task 5: PropertyDescriptorParser

**Files:**
- Create: `Sources/InspectorMacros/Helpers/PropertyDescriptorParser.swift`
- Modify: `Tests/InspectorMacrosTests/CamelCaseConverterTests.swift` (add descriptor parser tests to the same file, or create a new file)

The descriptor parser does two things:
1. **Type inference**: given a Swift type name string, returns the default descriptor (or nil if unsupported).
2. **Attribute parsing**: given an `@InspectorProperty(...)` attribute syntax node, returns a `ResolvedDescriptor` the code generator can use.

- [ ] **Step 1: Write failing tests**

```swift
// Tests/InspectorMacrosTests/PropertyDescriptorParserTests.swift

import XCTest
@testable import InspectorMacros

final class PropertyDescriptorParserTests: XCTestCase {

    // MARK: - Type inference

    func testBoolInfersSwitch() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "Bool"), .switch)
    }

    func testUIColorInfersColorPicker() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "UIColor"), .colorPicker)
    }

    func testOptionalUIColorInfersColorPicker() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "UIColor?"), .colorPicker)
    }

    func testCGFloatInfersStepper() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "CGFloat"), .stepper(range: 0...Double.infinity, step: 1))
    }

    func testStringInfersTextField() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "String"), .textField)
    }

    func testUnknownTypeReturnsNil() {
        XCTAssertNil(PropertyDescriptorParser.inferDescriptor(forTypeName: "MyCustomEnum"))
    }

    func testCGRectInfersCGRect() {
        XCTAssertEqual(PropertyDescriptorParser.inferDescriptor(forTypeName: "CGRect"), .cgRect)
    }
}
```

- [ ] **Step 2: Run to verify they fail**

```bash
swift test --filter PropertyDescriptorParserTests
```

Expected: compile error.

- [ ] **Step 3: Implement PropertyDescriptorParser**

```swift
// Sources/InspectorMacros/Helpers/PropertyDescriptorParser.swift

import SwiftSyntax

// MARK: - ResolvedDescriptor

/// The parsed/inferred descriptor for a single @InspectorProperty.
enum ResolvedDescriptor: Equatable {
    case `switch`
    case colorPicker
    case stepper(range: ClosedRange<Double>, step: Double)
    case textField
    case textView
    case imagePicker
    case optionsList(options: [String])
    case textButtonGroup(texts: [String])
    case cgRect
    case cgPoint
    case cgSize
    case uiOffset
    case edgeInsets
    case directionalInsets
    case group(title: String)
    case separator
    case infoNote(text: String)
}

// MARK: - PropertyDescriptorParser

enum PropertyDescriptorParser {

    // MARK: Type inference

    /// Returns the default ResolvedDescriptor for a Swift type name, or nil if unsupported.
    static func inferDescriptor(forTypeName typeName: String) -> ResolvedDescriptor? {
        // Strip optional suffix
        let base = typeName.hasSuffix("?") ? String(typeName.dropLast()) : typeName
        switch base {
        case "Bool":                        return .switch
        case "UIColor":                     return .colorPicker
        case "CGFloat", "Double", "Float":  return .stepper(range: 0...Double.infinity, step: 1)
        case "String":                      return .textField
        case "CGRect":                      return .cgRect
        case "CGPoint":                     return .cgPoint
        case "CGSize":                      return .cgSize
        case "UIOffset":                    return .uiOffset
        case "UIEdgeInsets":                return .edgeInsets
        case "NSDirectionalEdgeInsets":     return .directionalInsets
        default:                            return nil
        }
    }

    // MARK: Attribute syntax parsing

    /// Parses the argument of an @InspectorProperty(...) attribute.
    /// Returns nil if the argument is `.auto` or absent (both mean "infer from type").
    static func parseDescriptor(from attribute: AttributeSyntax) -> ResolvedDescriptor? {
        // @InspectorProperty with no argument → auto
        guard let args = attribute.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = args.first else {
            return nil // auto
        }

        let expr = firstArg.expression

        // Handle member access: .switch, .colorPicker, .cgRect, etc.
        if let memberAccess = expr.as(MemberAccessExprSyntax.self) {
            return parseSimpleCase(memberAccess.declName.baseName.text)
        }

        // Handle function calls: .stepper(range:step:), .optionsList(options:), etc.
        if let funcCall = expr.as(FunctionCallExprSyntax.self),
           let base = funcCall.calledExpression.as(MemberAccessExprSyntax.self) {
            return parseFunctionCase(base.declName.baseName.text, args: funcCall.arguments)
        }

        return nil // unknown syntax — treated as auto, error emitted by caller
    }

    // MARK: - Private

    private static func parseSimpleCase(_ name: String) -> ResolvedDescriptor? {
        switch name {
        case "switch":           return .switch
        case "colorPicker":      return .colorPicker
        case "textField":        return .textField
        case "textView":         return .textView
        case "imagePicker":      return .imagePicker
        case "cgRect":           return .cgRect
        case "cgPoint":          return .cgPoint
        case "cgSize":           return .cgSize
        case "uiOffset":         return .uiOffset
        case "edgeInsets":       return .edgeInsets
        case "directionalInsets": return .directionalInsets
        case "separator":        return .separator
        case "auto":             return nil // caller handles auto
        default:                 return nil
        }
    }

    private static func parseFunctionCase(
        _ name: String,
        args: LabeledExprListSyntax
    ) -> ResolvedDescriptor? {
        switch name {
        case "stepper":
            let range = extractDoubleClosedRange(from: args, label: "range") ?? 0...Double.infinity
            let step = extractDouble(from: args, label: "step") ?? 1.0
            return .stepper(range: range, step: step)

        case "optionsList":
            let options = extractStringArray(from: args, label: "options") ?? []
            return .optionsList(options: options)

        case "textButtonGroup":
            let texts = extractStringArray(from: args, label: "texts") ?? []
            return .textButtonGroup(texts: texts)

        case "group":
            let title = extractString(from: args, label: "title") ?? ""
            return .group(title: title)

        case "infoNote":
            let text = extractString(from: args, label: "text") ?? ""
            return .infoNote(text: text)

        default:
            return nil
        }
    }

    // MARK: Literal extractors

    private static func extractDouble(from args: LabeledExprListSyntax, label: String) -> Double? {
        guard let arg = args.first(where: { $0.label?.text == label }),
              let floatLit = arg.expression.as(FloatLiteralExprSyntax.self) else { return nil }
        return Double(floatLit.literal.text)
    }

    private static func extractDoubleClosedRange(
        from args: LabeledExprListSyntax,
        label: String
    ) -> ClosedRange<Double>? {
        guard let arg = args.first(where: { $0.label?.text == label }),
              let infix = arg.expression.as(InfixOperatorExprSyntax.self),
              let op = infix.operator.as(BinaryOperatorExprSyntax.self),
              op.operator.text == "..." else { return nil }
        // Parse both sides as numeric literals
        func toDouble(_ expr: ExprSyntax) -> Double? {
            if let f = expr.as(FloatLiteralExprSyntax.self) { return Double(f.literal.text) }
            if let i = expr.as(IntegerLiteralExprSyntax.self) { return Double(i.literal.text) }
            // Double.infinity expressed as member access
            if let m = expr.as(MemberAccessExprSyntax.self), m.declName.baseName.text == "infinity" {
                return Double.infinity
            }
            return nil
        }
        guard let lo = toDouble(infix.leftOperand),
              let hi = toDouble(infix.rightOperand) else { return nil }
        return lo...hi
    }

    private static func extractString(from args: LabeledExprListSyntax, label: String) -> String? {
        guard let arg = args.first(where: { $0.label?.text == label }),
              let lit = arg.expression.as(StringLiteralExprSyntax.self),
              let seg = lit.segments.first?.as(StringSegmentSyntax.self) else { return nil }
        return seg.content.text
    }

    private static func extractStringArray(
        from args: LabeledExprListSyntax,
        label: String
    ) -> [String]? {
        guard let arg = args.first(where: { $0.label?.text == label }),
              let array = arg.expression.as(ArrayExprSyntax.self) else { return nil }
        return array.elements.compactMap { element in
            guard let lit = element.expression.as(StringLiteralExprSyntax.self),
                  let seg = lit.segments.first?.as(StringSegmentSyntax.self) else { return nil }
            return seg.content.text
        }
    }
}
```

- [ ] **Step 4: Run tests**

```bash
swift test --filter PropertyDescriptorParserTests
```

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/InspectorMacros/Helpers/PropertyDescriptorParser.swift \
        Tests/InspectorMacrosTests/PropertyDescriptorParserTests.swift
git commit -m "feat: add PropertyDescriptorParser with type inference and attribute syntax parsing"
```

---

### Task 6: Full InspectorPanelMacro implementation

Replace the stub `InspectorPanelMacro.swift` with the complete implementation.

**Files:**
- Modify: `Sources/InspectorMacros/InspectorPanelMacro.swift`

The macro collects `@InspectorProperty`-annotated stored properties, builds a `SectionDataSource` and `InspectorLibrary`, and emits them wrapped in `#if INSPECTOR_DEBUGGING` using `IfConfigDeclSyntax`.

**Key SwiftSyntax construction note:** `IfConfigDeclSyntax` is a valid `DeclSyntax` that can be returned from an `@attached(member)` macro (confirmed in swift-spyable). Use `.poundIfToken()` for the `poundKeyword` — not a string literal.

- [ ] **Step 1: Write the failing macro expansion test first** (see Task 7 Step 1 — write it now)

Create `Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift` with at minimum this test:

```swift
// Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import InspectorMacros

private let testMacros: [String: any Macro.Type] = [
    "InspectorPanel": InspectorPanelMacro.self,
    "InspectorProperty": InspectorPropertyMacro.self
]

final class InspectorPanelMacroTests: XCTestCase {

    func testBasicColorPickerExpansion() {
        assertMacroExpansion(
            """
            @InspectorPanel(title: "My Card View")
            class MyCardView: UIView {
                @InspectorProperty(.colorPicker)
                var borderColor: UIColor = .clear
            }
            """,
            expandedSource: """
            class MyCardView: UIView {
                var borderColor: UIColor = .clear
                #if INSPECTOR_DEBUGGING
                final class SectionDataSource: InspectorElementSectionDataSource {
                    var state: InspectorElementSectionState = .collapsed
                    let title = "My Card View"
                    private weak var element: MyCardView?
                    init?(with object: NSObject) {
                        guard let element = object as? MyCardView else { return nil }
                        self.element = element
                    }
                    private enum Property: String, Swift.CaseIterable {
                        case borderColor = "Border Color"
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
            }
            """,
            macros: testMacros
        )
    }
}
```

- [ ] **Step 2: Run to verify the test fails (stub returns empty)**

```bash
swift test --filter InspectorPanelMacroTests
```

Expected: test fails — expansion doesn't match.

- [ ] **Step 3: Implement the full InspectorPanelMacro**

```swift
// Sources/InspectorMacros/InspectorPanelMacro.swift

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: - Supporting types

struct InspectableProperty {
    let name: String
    let typeName: String
    let isOptional: Bool
    let displayName: String
    let descriptor: ResolvedDescriptor
}

// MARK: - InspectorPanelMacro

public struct InspectorPanelMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // 1. Must be applied to a class
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InspectorMacroDiagnostic.notAClass))
            return []
        }

        let className = classDecl.name.text

        // 2. Get the title argument
        guard let labeledArgs = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArg = labeledArgs.first,
              let titleLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
              let titleSegment = titleLiteral.segments.first?.as(StringSegmentSyntax.self),
              !titleSegment.content.text.isEmpty else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InspectorMacroDiagnostic.missingTitle))
            return []
        }
        let title = titleSegment.content.text

        // 3. Collect @InspectorProperty-annotated stored properties
        let properties: [InspectableProperty] = classDecl.memberBlock.members.compactMap { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.text == "var",
                  let binding = varDecl.bindings.first,
                  binding.accessorBlock == nil, // stored property only
                  let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation?.type else { return nil }

            // Find @InspectorProperty attribute
            guard varDecl.attributes.contains(where: { attr in
                attr.as(AttributeSyntax.self)?
                    .attributeName.as(IdentifierTypeSyntax.self)?
                    .name.text == "InspectorProperty"
            }) else { return nil }

            let inspectorAttr = varDecl.attributes.compactMap { $0.as(AttributeSyntax.self) }.first {
                $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "InspectorProperty"
            }

            let rawTypeName = typeAnnotation.trimmedDescription
            let isOptional = rawTypeName.hasSuffix("?")
            let typeName = rawTypeName

            // Resolve descriptor: explicit → auto-inferred → error
            let resolvedDescriptor: ResolvedDescriptor
            if let explicit = inspectorAttr.flatMap({ PropertyDescriptorParser.parseDescriptor(from: $0) }) {
                resolvedDescriptor = explicit
            } else if let inferred = PropertyDescriptorParser.inferDescriptor(forTypeName: rawTypeName) {
                resolvedDescriptor = inferred
            } else {
                context.diagnose(Diagnostic(
                    node: Syntax(typeAnnotation),
                    message: InspectorMacroDiagnostic.unsupportedTypeForAutoDescriptor(typeName: rawTypeName)
                ))
                return nil
            }

            return InspectableProperty(
                name: pattern.identifier.text,
                typeName: typeName,
                isOptional: isOptional,
                displayName: CamelCaseConverter.toDisplayName(pattern.identifier.text),
                descriptor: resolvedDescriptor
            )
        }

        if properties.isEmpty {
            context.diagnose(Diagnostic(node: Syntax(node), message: InspectorMacroDiagnostic.noInspectableProperties))
        }

        // 4. Generate the two nested types
        let sectionDataSource = generateSectionDataSource(
            className: className,
            title: title,
            properties: properties
        )
        let inspectorLibrary = generateInspectorLibrary(className: className)

        // 5. Wrap both in #if INSPECTOR_DEBUGGING
        // IfConfigDeclSyntax wraps them so they only compile when the Debugging trait is on.
        // NOTE: use .poundIfToken() — string literal will crash the compiler.
        let ifConfigDecl = IfConfigDeclSyntax(
            clauses: IfConfigClauseListSyntax([
                IfConfigClauseSyntax(
                    poundKeyword: .poundIfToken(trailingTrivia: .space),
                    condition: ExprSyntax(
                        DeclReferenceExprSyntax(baseName: .identifier("INSPECTOR_DEBUGGING"))
                    ),
                    elements: .decls(MemberBlockItemListSyntax([
                        MemberBlockItemSyntax(decl: sectionDataSource),
                        MemberBlockItemSyntax(decl: inspectorLibrary)
                    ]))
                )
            ])
        )

        return [DeclSyntax(ifConfigDecl)]
    }

    // MARK: - SectionDataSource generation

    private static func generateSectionDataSource(
        className: String,
        title: String,
        properties: [InspectableProperty]
    ) -> ClassDeclSyntax {
        let enumCases = properties.map { prop in
            "        case \(prop.name) = \"\(prop.displayName)\""
        }.joined(separator: "\n")

        let switchCases = properties.map { prop in
            generateSwitchCase(prop: prop, className: className)
        }.joined(separator: "\n")

        let source = """
        final class SectionDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "\(title)"
            private weak var element: \(className)?
            init?(with object: NSObject) {
                guard let element = object as? \(className) else { return nil }
                self.element = element
            }
            private enum Property: String, Swift.CaseIterable {
        \(enumCases)
            }
            var properties: [InspectorElementProperty] {
                guard let element else { return [] }
                return Property.allCases.compactMap { property in
                    switch property {
        \(switchCases)
                    }
                }
            }
        }
        """
        return DeclSyntax(stringLiteral: source).as(ClassDeclSyntax.self)!
    }

    // MARK: - InspectorLibrary generation

    private static func generateInspectorLibrary(className: String) -> StructDeclSyntax {
        let source = """
        struct InspectorLibrary: InspectorElementLibraryProtocol {
            var targetClass: AnyClass { \(className).self }
            func sections(for object: NSObject) -> InspectorElementSections {
                .init(with: SectionDataSource(with: object))
            }
        }
        """
        return DeclSyntax(stringLiteral: source).as(StructDeclSyntax.self)!
    }

    // MARK: - Switch case generation per descriptor

    private static func generateSwitchCase(
        prop: InspectableProperty,
        className: String
    ) -> String {
        let body = generatePropertyBuilder(prop: prop)
        return """
                    case .\(prop.name):
        \(body)
        """
    }

    private static func generatePropertyBuilder(prop: InspectableProperty) -> String {
        let name = prop.name
        let displayName = "property.rawValue"

        switch prop.descriptor {
        case .switch:
            return """
                            .switch(
                                title: \(displayName),
                                isOn: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        case .colorPicker:
            if prop.isOptional {
                return """
                                .colorPicker(
                                    title: \(displayName),
                                    color: { element.\(name) },
                                    handler: { element.\(name) = $0 }
                                )
                """
            } else {
                return """
                                .colorPicker(
                                    title: \(displayName),
                                    color: { element.\(name) },
                                    handler: { newColor in
                                        if let newColor { element.\(name) = newColor }
                                    }
                                )
                """
            }
        case .stepper(let range, let step):
            let lo = range.lowerBound == 0 ? "0.0" : "\(range.lowerBound)"
            let hi = range.upperBound == Double.infinity ? "Double.infinity" : "\(range.upperBound)"
            let stepStr = step == 1.0 ? "1.0" : "\(step)"
            let isDecimal = (prop.typeName == "CGFloat" || prop.typeName == "Double" || prop.typeName == "Float")
            let valueExpr = prop.typeName == "CGFloat" ? "Double(element.\(name))" : "element.\(name)"
            let handlerExpr = prop.typeName == "CGFloat"
                ? "element.\(name) = CGFloat($0)"
                : "element.\(name) = $0"
            return """
                            .stepper(
                                title: \(displayName),
                                value: { \(valueExpr) },
                                range: { \(lo)...\(hi) },
                                stepValue: { \(stepStr) },
                                isDecimalValue: \(isDecimal),
                                handler: { \(handlerExpr) }
                            )
            """
        case .textField:
            return """
                            .textField(
                                title: \(displayName),
                                placeholder: nil,
                                value: { element.\(name) },
                                handler: { element.\(name) = $0 ?? "" }
                            )
            """
        case .textView:
            return """
                            .textView(
                                title: \(displayName),
                                placeholder: nil,
                                value: { element.\(name) },
                                handler: { element.\(name) = $0 ?? "" }
                            )
            """
        case .cgRect:
            return """
                            .cgRect(
                                title: \(displayName),
                                rect: { element.\(name) },
                                handler: { element.\(name) = $0 ?? .zero }
                            )
            """
        case .cgPoint:
            return """
                            .cgPoint(
                                title: \(displayName),
                                point: { element.\(name) },
                                handler: { element.\(name) = $0 ?? .zero }
                            )
            """
        case .cgSize:
            return """
                            .cgSize(
                                title: \(displayName),
                                size: { element.\(name) },
                                handler: { element.\(name) = $0 ?? .zero }
                            )
            """
        case .uiOffset:
            return """
                            .uiOffset(
                                title: \(displayName),
                                offset: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        case .edgeInsets:
            return """
                            .edgeInsets(
                                title: \(displayName),
                                insets: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        case .directionalInsets:
            return """
                            .directionalInsets(
                                title: \(displayName),
                                insets: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        case .optionsList(let options):
            let optionsList = options.map { "\"\($0)\"" }.joined(separator: ", ")
            return """
                            .optionsList(
                                title: \(displayName),
                                options: [\(optionsList)],
                                selectedIndex: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        case .textButtonGroup(let texts):
            let textsList = texts.map { "\"\($0)\"" }.joined(separator: ", ")
            return """
                            .textButtonGroup(
                                title: \(displayName),
                                texts: [\(textsList)],
                                selectedIndex: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        case .group(let groupTitle):
            return """
                            .group(title: "\(groupTitle)")
            """
        case .separator:
            return """
                            .separator
            """
        case .infoNote(let text):
            return """
                            .infoNote(text: "\(text)")
            """
        case .imagePicker:
            return """
                            .imagePicker(
                                title: \(displayName),
                                image: { element.\(name) },
                                handler: { element.\(name) = $0 }
                            )
            """
        }
    }
}
```

**Implementation note:** The `DeclSyntax(stringLiteral:)` approach for generating multi-line declarations is convenient but may have whitespace sensitivity. If the `assertMacroExpansion` test fails due to trivia (whitespace/newlines), switch to `SwiftSyntaxBuilder`'s typed DSL for the failing nodes. The test output will show the exact expected vs actual diff.

- [ ] **Step 4: Run the macro expansion test**

```bash
swift test --filter testBasicColorPickerExpansion
```

Expected: passes. If whitespace mismatches occur in `assertMacroExpansion`, adjust the `expandedSource` string to match the actual output exactly (run once, copy the actual output).

- [ ] **Step 5: Commit**

```bash
git add Sources/InspectorMacros/InspectorPanelMacro.swift \
        Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift
git commit -m "feat: implement InspectorPanelMacro — generates SectionDataSource and InspectorLibrary"
```

---

## Chunk 4: Tests + Verification

### Task 7: Complete test coverage

Add tests covering multi-property expansion, type inference, diagnostics.

**Files:**
- Modify: `Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift`

- [ ] **Step 1: Add multi-property test**

```swift
func testMultiplePropertiesExpansion() {
    assertMacroExpansion(
        """
        @InspectorPanel(title: "My View")
        class MyView: UIView {
            @InspectorProperty(.switch)
            var isEnabled: Bool = true
            @InspectorProperty(.stepper(range: 0...100, step: 1))
            var alpha: CGFloat = 1.0
        }
        """,
        expandedSource: """
        class MyView: UIView {
            var isEnabled: Bool = true
            var alpha: CGFloat = 1.0
            #if INSPECTOR_DEBUGGING
            final class SectionDataSource: InspectorElementSectionDataSource {
                // ... (copy actual output on first run)
            }
            struct InspectorLibrary: InspectorElementLibraryProtocol {
                // ...
            }
            #endif
        }
        """,
        macros: testMacros
    )
}
```

**Note:** Run the test once without `expandedSource` to capture the actual output, then paste it in. `assertMacroExpansion` prints the actual expansion on failure.

- [ ] **Step 2: Add type-inference test (no explicit descriptor)**

```swift
func testTypeInferenceForBool() {
    assertMacroExpansion(
        """
        @InspectorPanel(title: "Test")
        class TestView: UIView {
            @InspectorProperty
            var isHidden: Bool = false
        }
        """,
        expandedSource: """
        class TestView: UIView {
            var isHidden: Bool = false
            #if INSPECTOR_DEBUGGING
            final class SectionDataSource: InspectorElementSectionDataSource {
                // ... generates .switch case for Bool
            }
            struct InspectorLibrary: InspectorElementLibraryProtocol { }
            #endif
        }
        """,
        macros: testMacros
    )
}
```

- [ ] **Step 3: Add diagnostic test for unsupported type**

```swift
func testDiagnosticForUnsupportedType() {
    assertMacroExpansion(
        """
        @InspectorPanel(title: "Test")
        class TestView: UIView {
            @InspectorProperty
            var customEnum: MyEnum = .default
        }
        """,
        expandedSource: """
        class TestView: UIView {
            var customEnum: MyEnum = .default
        }
        """,
        diagnostics: [
            DiagnosticSpec(
                message: "@InspectorProperty requires an explicit descriptor for 'MyEnum' — no default control exists for this type",
                line: 4,
                column: 5
            )
        ],
        macros: testMacros
    )
}
```

- [ ] **Step 4: Add diagnostic test for non-class usage**

```swift
func testDiagnosticForStruct() {
    assertMacroExpansion(
        """
        @InspectorPanel(title: "Test")
        struct TestStruct {
            @InspectorProperty(.switch)
            var isOn: Bool = false
        }
        """,
        expandedSource: """
        struct TestStruct {
            var isOn: Bool = false
        }
        """,
        diagnostics: [
            DiagnosticSpec(
                message: "@InspectorPanel can only be applied to a class",
                line: 1,
                column: 1
            )
        ],
        macros: testMacros
    )
}
```

- [ ] **Step 5: Run all macro tests**

```bash
swift test --filter InspectorMacrosTests
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add Tests/InspectorMacrosTests/InspectorPanelMacroTests.swift
git commit -m "test: add InspectorPanelMacro coverage — multi-property, type inference, diagnostics"
```

---

### Task 8: Final build verification

- [ ] **Step 1: Run all tests**

```bash
swift test
```

Expected: all tests pass (InspectorTests, InspectorMacrosTests).

- [ ] **Step 2: Verify InspectorInterface builds with and without the trait**

```bash
# Without trait (release simulation) — InspectorInterface compiles to nothing
swift build --target InspectorInterface

# With trait (debug simulation)
swift build --target InspectorInterface --traits Debugging
```

Expected: both succeed.

- [ ] **Step 3: Verify the example app still builds**

```bash
xcodebuild build \
  -project Example/Example.xcodeproj \
  -scheme Inspector \
  -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=18.4' \
  | grep 'BUILD'
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Final commit**

```bash
git add .
git commit -m "chore: Inspector Macros — all tests passing, builds verified"
```
