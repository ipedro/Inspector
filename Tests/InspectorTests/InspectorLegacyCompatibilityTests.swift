#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import InspectorContract
import XCTest

@MainActor
final class InspectorLegacyCompatibilityTests: XCTestCase {
    // This suite intentionally exercises the deprecated InspectorElementProperty compatibility bridge.
    // Keep legacy APIs isolated here until the final removal pass deletes them.

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

    func testLegacyImageButtonGroupCreatesBindingWithRuntimeImages() throws {
        var selectedIndex: Int? = 0
        let property = InspectorElementProperty.imageButtonGroup(
            title: "Modes",
            images: [UIImage(), UIImage()],
            selectedIndex: { selectedIndex },
            handler: { selectedIndex = $0 }
        )

        let binding = try XCTUnwrap(property.makeBinding(id: "modes"))
        XCTAssertEqual(binding.descriptor.kind, .imageButtons)
        let view = try XCTUnwrap(binding.makeFormView())
        let segmentedControl = try XCTUnwrap(view as? SegmentedControl)
        XCTAssertEqual(segmentedControl.selectedIndex, 0)

        segmentedControl.selectedIndex = 1
        binding.applyUpdate(from: segmentedControl)
        XCTAssertEqual(selectedIndex, 1)
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
        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 1)
        XCTAssertEqual(bindings.first?.descriptor.title, "Enabled")
    }

    func testSectionDataSourcePropertyBindingsIncludeLegacyImageButtonGroup() throws {
        final class LegacyDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Legacy"
            var properties: [InspectorElementProperty] {
                [
                    .imageButtonGroup(
                        title: "Alignment",
                        images: [UIImage(), UIImage()],
                        selectedIndex: { 0 },
                        handler: { _ in }
                    )
                ]
            }
        }

        let dataSource = LegacyDataSource()
        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 1)
        XCTAssertEqual(bindings.first?.descriptor.kind, .imageButtons)
    }

    func testTitleAccessoryBindingFallsBackFromLegacyTitleAccessoryProperty() throws {
        final class LegacyTitleAccessoryDataSource: InspectorElementSectionDataSource {
            var state: InspectorElementSectionState = .collapsed
            let title = "Legacy"
            var properties: [InspectorElementProperty] { [] }
            var titleAccessoryProperty: InspectorElementProperty? {
                .switch(title: "Enabled", isOn: { true }, handler: { _ in })
            }
        }

        let dataSource = LegacyTitleAccessoryDataSource()
        let binding = try XCTUnwrap(dataSource.titleAccessoryBinding)
        XCTAssertEqual(binding.descriptor.title, "Enabled")
        XCTAssertEqual(binding.descriptor.kind, .toggle)
    }


}
#endif
