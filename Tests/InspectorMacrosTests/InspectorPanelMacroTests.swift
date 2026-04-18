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
                func makeInspectorSectionBinding() -> InspectorSectionBinding {
                    guard let element else {
                        return InspectorSectionBinding(
                            descriptor: MyCardView.inspectorSectionDescriptor,
                            fields: []
                        )
                    }
                    return InspectorSectionBinding(
                        descriptor: MyCardView.inspectorSectionDescriptor,
                        fields: [
                            .init(
                                descriptor: MyCardView.inspectorSectionDescriptor.fields[0],
                                read: { .color(element.borderColor) },
                                write: { value in
                                    guard case let .color(newValue) = value, let newValue else { return }
                                    element.borderColor = newValue
                                },
                                refreshHint: .reloadInspector
                            )
                        ]
                    )
                }
                final class SectionDataSource: InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "My Card View"
                    private weak var element: MyCardView?
                    init?(with object: NSObject) {
                        guard let element = object as? MyCardView else {
                            return nil
                        }
                        self.element = element
                    }
                    var sectionBinding: InspectorSectionBinding? {
                        guard element != nil else { return nil }
                        return makeInspectorSectionBinding()
                    }
                    var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] { [:] }
                }
                struct InspectorLibrary: InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        MyCardView.self
                    }
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
                func makeInspectorSectionBinding() -> InspectorSectionBinding {
                    guard let element else {
                        return InspectorSectionBinding(
                            descriptor: PlaygroundViewController.inspectorSectionDescriptor,
                            fields: []
                        )
                    }
                    return InspectorSectionBinding(
                        descriptor: PlaygroundViewController.inspectorSectionDescriptor,
                        fields: [
                            .init(
                                descriptor: PlaygroundViewController.inspectorSectionDescriptor.fields[0],
                                read: { .none },
                                write: nil,
                                refreshHint: .none
                            )
                        ]
                    )
                }
                final class SectionDataSource: InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "Playground"
                    private weak var element: PlaygroundViewController?
                    init?(with object: NSObject) {
                        guard let element = object as? PlaygroundViewController else {
                            return nil
                        }
                        self.element = element
                    }
                    var sectionBinding: InspectorSectionBinding? {
                        guard element != nil else { return nil }
                        return makeInspectorSectionBinding()
                    }
                    var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] {
                        [
                            "inspectBarButton": {
                                guard let child = element.inspectBarButton, let section = RoundedButton.SectionDataSource(with: child) else { return [] }
                                return [
                                    .init(
                                        descriptor: .init(
                                            id: "group-inspectBarButton",
                                            title: "Inspect Bar Button",
                                            kind: .group,
                                            value: .none,
                                            editability: .readOnly
                                        ),
                                        read: { .none },
                                        write: nil,
                                        refreshHint: .none
                                    )
                                ] + section.propertyBindings
                            }
                        ]
                    }
                }
                struct InspectorLibrary: InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        PlaygroundViewController.self
                    }
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
                func makeInspectorSectionBinding() -> InspectorSectionBinding {
                    guard let element else {
                        return InspectorSectionBinding(
                            descriptor: SliderView.inspectorSectionDescriptor,
                            fields: []
                        )
                    }
                    return InspectorSectionBinding(
                        descriptor: SliderView.inspectorSectionDescriptor,
                        fields: [
                            .init(
                                descriptor: SliderView.inspectorSectionDescriptor.fields[0],
                                read: { .number(element.value) },
                                write: { value in
                                    guard case let .number(newValue) = value else { return }
                                    element.value = newValue
                                },
                                refreshHint: .reloadInspector
                            )
                        ]
                    )
                }
                final class SectionDataSource: InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "Slider"
                    private weak var element: SliderView?
                    init?(with object: NSObject) {
                        guard let element = object as? SliderView else {
                            return nil
                        }
                        self.element = element
                    }
                    var sectionBinding: InspectorSectionBinding? {
                        guard element != nil else { return nil }
                        return makeInspectorSectionBinding()
                    }
                    var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] { [:] }
                }
                struct InspectorLibrary: InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        SliderView.self
                    }
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
                func makeInspectorSectionBinding() -> InspectorSectionBinding {
                    guard let element else {
                        return InspectorSectionBinding(
                            descriptor: TestView.inspectorSectionDescriptor,
                            fields: []
                        )
                    }
                    return InspectorSectionBinding(
                        descriptor: TestView.inspectorSectionDescriptor,
                        fields: [

                        ]
                    )
                }
                final class SectionDataSource: InspectorElementSectionDataSource {
                    var state: InspectorContract.InspectorElementSectionState = .collapsed
                    let title = "Test"
                    private weak var element: TestView?
                    init?(with object: NSObject) {
                        guard let element = object as? TestView else {
                            return nil
                        }
                        self.element = element
                    }
                    var sectionBinding: InspectorSectionBinding? {
                        guard element != nil else { return nil }
                        return makeInspectorSectionBinding()
                    }
                    var sectionBindingExtraBindings: [String: () -> [InspectorPropertyBinding]] { [:] }
                }
                struct InspectorLibrary: InspectorElementLibraryProtocol {
                    var targetClass: AnyClass {
                        TestView.self
                    }
                    func sections(for object: NSObject) -> InspectorElementSections {
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
