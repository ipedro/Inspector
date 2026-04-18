#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import InspectorContract
import XCTest

final class InspectorPropertyBindingTests: XCTestCase {
    func testToggleBindingProducesSwitchProperty() {
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

    func testStepperBindingUsesDescriptorConstraints() {
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
}
#endif
