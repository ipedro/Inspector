#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import InspectorContract
import XCTest

@MainActor
final class InspectorPropertyBindingTests: XCTestCase {
    func testToggleBindingProducesSwitchProperty() throws {
        var value = false
        let descriptor = InspectorPropertyDescriptor(
            id: "enabled",
            title: "Enabled",
            kind: .toggle,
            value: .bool,
            editability: .editable
        )
        let binding = InspectorPropertyBinding(
            descriptor: descriptor,
            read: { .bool(value) },
            write: { newValue in
                guard case let .bool(updated) = newValue else { return }
                value = updated
            }
        )

        let property = try XCTUnwrap(binding.makeInspectorElementProperty())
        if case let .switch(title, isOn, handler) = property {
            XCTAssertEqual(title, "Enabled")
            XCTAssertFalse(isOn())
            handler?(true)
            XCTAssertTrue(value)
        } else {
            XCTFail("expected switch property")
        }
    }

    func testStepperBindingUsesDescriptorConstraints() throws {
        var value = 0.5
        let descriptor = InspectorPropertyDescriptor(
            id: "alpha",
            title: "Alpha",
            kind: .stepper,
            value: .number(.init(min: 0, max: 1, step: 0.1, isDecimal: true)),
            editability: .editable
        )
        let binding = InspectorPropertyBinding(
            descriptor: descriptor,
            read: { .number(value) },
            write: { newValue in
                guard case let .number(updated) = newValue else { return }
                value = updated
            }
        )

        let property = try XCTUnwrap(binding.makeInspectorElementProperty())
        if case let .stepper(title, currentValue, range, stepValue, isDecimal, handler) = property {
            XCTAssertEqual(title, "Alpha")
            XCTAssertEqual(currentValue(), 0.5)
            XCTAssertEqual(range(), 0...1)
            XCTAssertEqual(stepValue(), 0.1)
            XCTAssertTrue(isDecimal)
            handler?(0.8)
            XCTAssertEqual(value, 0.8)
        } else {
            XCTFail("expected stepper property")
        }
    }

    func testSectionBindingUsesExtraPropertiesForSubpanel() {
        let descriptor = InspectorPropertyDescriptor(
            id: "child",
            title: "Child",
            kind: .subpanel,
            value: .none,
            editability: .readOnly
        )
        let binding = InspectorSectionBinding(
            descriptor: .init(id: "section", title: "Section"),
            fields: [
                .init(descriptor: descriptor, read: { .none }, write: nil, refreshHint: .none)
            ]
        )

        let properties = binding.makeInspectorElementProperties(
            extraProperties: [
                "child": { [.group(title: "Child")] }
            ]
        )

        XCTAssertEqual(properties.count, 1)
        if case let .group(title, _) = properties[0] {
            XCTAssertEqual(title, "Child")
        } else {
            XCTFail("expected group property")
        }
    }

    func testSectionDataSourceDefaultPropertiesUseSectionBinding() {
        final class BindingOnlyDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Binding Only"
            let sectionBinding: InspectorSectionBinding?

            init() {
                let descriptor = InspectorPropertyDescriptor(
                    id: "enabled",
                    title: "Enabled",
                    kind: .toggle,
                    value: .bool,
                    editability: .editable
                )
                var value = false
                self.sectionBinding = InspectorSectionBinding(
                    descriptor: .init(id: "binding-only"),
                    fields: [
                        .init(
                            descriptor: descriptor,
                            read: { .bool(value) },
                            write: { newValue in
                                guard case let .bool(updated) = newValue else { return }
                                value = updated
                            }
                        )
                    ]
                )
            }
        }

        let dataSource = BindingOnlyDataSource()
        let properties = dataSource.properties
        XCTAssertEqual(properties.count, 1)
        if case let .switch(title, isOn, _) = properties[0] {
            XCTAssertEqual(title, "Enabled")
            XCTAssertFalse(isOn())
        } else {
            XCTFail("expected switch property")
        }
    }

    func testLegacyTogglePropertyCreatesBinding() throws {
        var value = false
        let property = InspectorElementProperty.switch(
            title: "Enabled",
            isOn: { value },
            handler: { value = $0 }
        )

        let binding = try XCTUnwrap(property.makeBinding(id: "enabled"))
        XCTAssertEqual(binding.descriptor.title, "Enabled")
        if case let .bool(current) = binding.read() {
            XCTAssertFalse(current)
        } else {
            XCTFail("expected bool value")
        }
    }

    func testLegacyImageButtonGroupCurrentlyReturnsNilBinding() {
        let property = InspectorElementProperty.imageButtonGroup(
            title: "Modes",
            images: [UIImage(), UIImage()],
            selectedIndex: { 0 },
            handler: { _ in }
        )

        XCTAssertNil(property.makeBinding(id: "modes"))
    }

    func testSectionDataSourcePropertyBindingsFallbacksForLegacyProperties() throws {
        final class LegacyDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Legacy"
            var properties: [InspectorElementProperty] {
                [
                    .switch(title: "Enabled", isOn: { false }, handler: { _ in })
                ]
            }
        }

        let dataSource = LegacyDataSource()
        let bindings = try XCTUnwrap(dataSource.propertyBindings)
        XCTAssertEqual(bindings.count, 1)
        XCTAssertEqual(bindings.first?.descriptor.title, "Enabled")
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
