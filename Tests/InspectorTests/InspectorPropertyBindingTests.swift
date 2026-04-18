#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import InspectorContract
import XCTest

@MainActor
final class InspectorPropertyBindingTests: XCTestCase {
    func testSectionDataSourcePropertyBindingsIncludeBindingExtras() {
        final class BindingExtraDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Extra"
            var sectionBinding: InspectorSectionBinding? {
                .init(
                    descriptor: .init(id: "section", title: "Section", defaultState: .collapsed, fields: [
                        .init(id: "child", title: "Child", kind: .subpanel, value: .none, editability: .readOnly)
                    ]),
                    fields: [
                        .init(
                            descriptor: .init(id: "child", title: "Child", kind: .subpanel, value: .none, editability: .readOnly),
                            read: { .none },
                            write: nil,
                            refreshHint: .none
                        )
                    ]
                )
            }
            var sectionBindingExtraBindings: [String : () -> [InspectorPropertyBinding]] {
                [
                    "child": {
                        [
                            .init(
                                descriptor: .init(id: "group-child", title: "Child", kind: .group, value: .none, editability: .readOnly),
                                read: { .none },
                                write: nil,
                                refreshHint: .none
                            )
                        ]
                    }
                ]
            }
        }

        let dataSource = BindingExtraDataSource()
        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 2)
        XCTAssertEqual(bindings[1].descriptor.kind, .group)
        let properties = dataSource.properties
        XCTAssertEqual(properties.count, 1)
        if case let .group(title, _) = properties[0] {
            XCTAssertEqual(title, "Child")
        } else {
            XCTFail("Expected group property")
        }
    }

    func testToggleBindingCreatesAndAppliesToggleFormView() throws {
        var value = false
        let binding = InspectorPropertyBinding(
            descriptor: .init(
                id: "enabled",
                title: "Enabled",
                kind: .toggle,
                value: .bool,
                editability: .editable
            ),
            read: { .bool(value) },
            write: { newValue in
                guard case let .bool(updated) = newValue else { return }
                value = updated
            }
        )

        let view = try XCTUnwrap(binding.makeFormView())
        let toggle = try XCTUnwrap(view as? ToggleControl)
        XCTAssertFalse(toggle.isOn)

        toggle.isOn = true
        binding.applyUpdate(from: toggle)

        XCTAssertTrue(value)
    }

    func testStepperBindingReloadsExistingStepperFormView() throws {
        var value = 0.25
        let binding = InspectorPropertyBinding(
            descriptor: .init(
                id: "alpha",
                title: "Alpha",
                kind: .stepper,
                value: .number(.init(min: 0, max: 1, step: 0.05, isDecimal: true)),
                editability: .editable
            ),
            read: { .number(value) },
            write: { newValue in
                guard case let .number(updated) = newValue else { return }
                value = updated
            }
        )

        let view = try XCTUnwrap(binding.makeFormView())
        let stepper = try XCTUnwrap(view as? StepperControl)
        XCTAssertEqual(stepper.value, 0.25)

        value = 0.75
        binding.reload(formView: stepper)

        XCTAssertEqual(stepper.value, 0.75)
        XCTAssertEqual(stepper.range, 0...1)
        XCTAssertEqual(stepper.stepValue, 0.05)
    }

    func testTextFieldBindingAppliesAndReloadsTextFieldFormView() throws {
        var value = "Before"
        let binding = InspectorPropertyBinding(
            descriptor: .init(
                id: "title",
                title: "Title",
                kind: .textField,
                value: .string(.init(multiline: false, placeholder: "Placeholder", allowsNil: true)),
                editability: .editable
            ),
            read: { .string(value) },
            write: { newValue in
                guard case let .string(updated) = newValue else { return }
                value = updated ?? ""
            }
        )

        let view = try XCTUnwrap(binding.makeFormView())
        let textField = try XCTUnwrap(view as? TextFieldControl)
        XCTAssertEqual(textField.value, "Before")

        textField.value = "After"
        binding.applyUpdate(from: textField)
        XCTAssertEqual(value, "After")

        value = "Reloaded"
        binding.reload(formView: textField)
        XCTAssertEqual(textField.value, "Reloaded")
        XCTAssertEqual(textField.placeholder, "Placeholder")
    }

    func testSelectionBindingAppliesAndReloadsSegmentedControlFormView() throws {
        var value: Int? = 0
        let binding = InspectorPropertyBinding(
            descriptor: .init(
                id: "distribution",
                title: "Distribution",
                kind: .textButtons,
                value: .selection(.init(options: [
                    .init(id: "fill", title: "Fill"),
                    .init(id: "equal", title: "Equal")
                ], allowsNil: true)),
                editability: .editable
            ),
            read: { .selection(value) },
            write: { newValue in
                guard case let .selection(updated) = newValue else { return }
                value = updated
            }
        )

        let view = try XCTUnwrap(binding.makeFormView())
        let segmentedControl = try XCTUnwrap(view as? SegmentedControl)
        XCTAssertEqual(segmentedControl.selectedIndex, 0)

        segmentedControl.selectedIndex = 1
        binding.applyUpdate(from: segmentedControl)
        XCTAssertEqual(value, 1)

        value = nil
        binding.reload(formView: segmentedControl)
        XCTAssertNil(segmentedControl.selectedIndex)
    }
}
#endif
