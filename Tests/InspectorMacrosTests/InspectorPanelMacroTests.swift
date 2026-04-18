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
                static let inspectorSectionDescriptor: InspectorContract.InspectorSectionDescriptor = .init(
                    id: "My Card View",
                    title: "My Card View",
                    defaultState: .collapsed,
                    fields: [
                        .init(
                            id: "borderColor",
                            title: "Border Color",
                            kind: .color,
                            value: .color(allowsNil: false),
                            editability: .editable,
                            presentation: nil
                        )
                    ]
                )
                final class SectionDataSource: Inspector.InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "My Card View"
                    private weak var element: MyCardView?
                    init?(with object: NSObject) {
                        guard let element = object as? MyCardView else {
                            return nil
                        }
                        self.element = element
                    }
                    private enum Property: String, Swift.CaseIterable {
                        case borderColor = "Border Color"
                    }
                    var properties: [Inspector.InspectorElementProperty] {
                        guard let element else {
                            return []
                        }
                        return Property.allCases.flatMap { property -> [Inspector.InspectorElementProperty] in
                            switch property {
                            case .borderColor:
                                return [.colorPicker(
                                    title: property.rawValue,
                                    color: {
                                            element.borderColor
                                        },
                                    handler: { newColor in
                                        if let newColor {
                                                element.borderColor = newColor
                                            }
                                    }
                                    )]
                            }
                        }
                    }
                }
                struct InspectorLibrary: Inspector.InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        MyCardView.self
                    }
                    func sections(for object: NSObject) -> Inspector.InspectorElementSections {
                        .init(with: SectionDataSource(with: object))
                    }
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }

    func testSubpanelExpansion() {
        assertMacroExpansion(
            """
            @InspectorPanel(title: "Playground")
            class PlaygroundViewController: BaseViewController {
                @InspectorProperty(.subpanel)
                var inspectBarButton: RoundedButton!
            }
            """,
            expandedSource: """
            class PlaygroundViewController: BaseViewController {
                var inspectBarButton: RoundedButton!

                #if INSPECTOR_DEBUGGING
                static let inspectorSectionDescriptor: InspectorContract.InspectorSectionDescriptor = .init(
                    id: "Playground",
                    title: "Playground",
                    defaultState: .collapsed,
                    fields: [
                        .init(
                            id: "inspectBarButton",
                            title: "Inspect Bar Button",
                            kind: .subpanel,
                            value: .none,
                            editability: .readOnly,
                            presentation: nil
                        )
                    ]
                )
                final class SectionDataSource: Inspector.InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "Playground"
                    private weak var element: PlaygroundViewController?
                    init?(with object: NSObject) {
                        guard let element = object as? PlaygroundViewController else {
                            return nil
                        }
                        self.element = element
                    }
                    private enum Property: String, Swift.CaseIterable {
                        case inspectBarButton = "Inspect Bar Button"
                    }
                    var properties: [Inspector.InspectorElementProperty] {
                        guard let element else {
                            return []
                        }
                        return Property.allCases.flatMap { property -> [Inspector.InspectorElementProperty] in
                            switch property {
                            case .inspectBarButton:
                                guard let child = element.inspectBarButton else {
                                    return []
                                }
                                return [.group(title: property.rawValue)] + (RoundedButton.SectionDataSource(with: child)?.properties ?? [])
                            }
                        }
                    }
                }
                struct InspectorLibrary: Inspector.InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        PlaygroundViewController.self
                    }
                    func sections(for object: NSObject) -> Inspector.InspectorElementSections {
                        .init(with: SectionDataSource(with: object))
                    }
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }

    func testStoredPropertyWithDidSetIsCollected() {
        assertMacroExpansion(
            """
            @InspectorPanel(title: "Slider")
            class SliderView: UIView {
                @InspectorProperty(.stepper(range: 0...120, step: 1))
                var value: Double = 0 {
                    didSet { print(value) }
                }
            }
            """,
            expandedSource: """
            class SliderView: UIView {
                var value: Double = 0 {
                    didSet { print(value) }
                }

                #if INSPECTOR_DEBUGGING
                static let inspectorSectionDescriptor: InspectorContract.InspectorSectionDescriptor = .init(
                    id: "Slider",
                    title: "Slider",
                    defaultState: .collapsed,
                    fields: [
                        .init(
                            id: "value",
                            title: "Value",
                            kind: .stepper,
                            value: .number(.init(min: 0.0, max: 120.0, step: 1.0, isDecimal: true)),
                            editability: .editable,
                            presentation: nil
                        )
                    ]
                )
                final class SectionDataSource: Inspector.InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "Slider"
                    private weak var element: SliderView?
                    init?(with object: NSObject) {
                        guard let element = object as? SliderView else {
                            return nil
                        }
                        self.element = element
                    }
                    private enum Property: String, Swift.CaseIterable {
                        case value = "Value"
                    }
                    var properties: [Inspector.InspectorElementProperty] {
                        guard let element else {
                            return []
                        }
                        return Property.allCases.flatMap { property -> [Inspector.InspectorElementProperty] in
                            switch property {
                            case .value:
                                return [.stepper(
                                    title: property.rawValue,
                                    value: { element.value },
                                    range: { 0.0...120.0 },
                                    stepValue: { 1.0 },
                                    isDecimalValue: true,
                                    handler: { element.value = $0 }
                                )]
                            }
                        }
                    }
                }
                struct InspectorLibrary: Inspector.InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        SliderView.self
                    }
                    func sections(for object: NSObject) -> Inspector.InspectorElementSections {
                        .init(with: SectionDataSource(with: object))
                    }
                }
                #endif
            }
            """,
            macros: testMacros
        )
    }

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

                #if INSPECTOR_DEBUGGING
                static let inspectorSectionDescriptor: InspectorContract.InspectorSectionDescriptor = .init(
                    id: "Test",
                    title: "Test",
                    defaultState: .collapsed,
                    fields: [

                    ]
                )
                final class SectionDataSource: Inspector.InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "Test"
                    private weak var element: TestView?
                    init?(with object: NSObject) {
                        guard let element = object as? TestView else {
                            return nil
                        }
                        self.element = element
                    }
                    private enum Property: String, Swift.CaseIterable {

                    }
                    var properties: [Inspector.InspectorElementProperty] {
                        guard let element else {
                            return []
                        }
                        return Property.allCases.flatMap { property -> [Inspector.InspectorElementProperty] in
                            switch property {

                            }
                        }
                    }
                }
                struct InspectorLibrary: Inspector.InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        TestView.self
                    }
                    func sections(for object: NSObject) -> Inspector.InspectorElementSections {
                        .init(with: SectionDataSource(with: object))
                    }
                }
                #endif
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@InspectorProperty requires an explicit descriptor for 'MyEnum' — no default control exists for this type",
                    line: 4,
                    column: 21
                ),
                DiagnosticSpec(
                    message: "@InspectorPanel found no @InspectorProperty-annotated stored properties — panel will be empty",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
    }
}
