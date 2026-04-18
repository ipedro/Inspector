#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import InspectorContract
import XCTest

@MainActor
final class InspectorAutobuiltPanelTests: XCTestCase {
    func testAttributesPanelAppendsAutobuiltSectionForCustomSubclassWithoutExactLibrary() throws {
        final class CustomBadgeView: UIView {
            var isCompact = true
            var titleText = "Badge"
            var count = 3
        }

        let view = CustomBadgeView()

        let libraries = DefaultElementAttributesLibrary.allCases.map { $0 as InspectorElementLibraryProtocol }
        let sections = libraries.formItems(for: view, panel: .attributes)

        XCTAssertGreaterThanOrEqual(sections.count, 2)
        XCTAssertEqual(sections.last?.title, "Autobuilt")

        let dataSource = try XCTUnwrap(sections.last?.dataSources.first)
        XCTAssertEqual(dataSource.title, "Runtime Fields")
        XCTAssertEqual(dataSource.subtitle, String(describing: CustomBadgeView.self))

        let titles = dataSource.propertyBindings.map { $0.descriptor.title }
        XCTAssertTrue(titles.contains("Generated at runtime"))
        XCTAssertTrue(titles.contains("Is Compact"))
        XCTAssertTrue(titles.contains("Title Text"))
        XCTAssertTrue(titles.contains("Count"))
    }

    func testIdentityPanelNoLongerIncludesRuntimeAttributesSection() {
        final class CustomBadgeView: UIView {
            var isCompact = true
            var titleText = "Badge"
        }

        let libraries = DefaultElementIdentityLibrary.allCases.map { $0 as InspectorElementLibraryProtocol }
        let sections = libraries.formItems(for: CustomBadgeView(), panel: .identity)

        XCTAssertFalse(sections.contains { $0.title == "Runtime Attributes" })
    }

    func testAutobuiltBindingsAreReadOnly() throws {
        final class CustomBadgeView: UIView {
            var isCompact = true
        }

        let view = CustomBadgeView()
        let libraries = DefaultElementAttributesLibrary.allCases.map { $0 as InspectorElementLibraryProtocol }
        let sections = libraries.formItems(for: view, panel: .attributes)
        let dataSource = try XCTUnwrap(sections.last?.dataSources.first)

        let binding = try XCTUnwrap(
            dataSource.propertyBindings.first(where: { $0.descriptor.title == "Is Compact" })
        )

        XCTAssertEqual(binding.descriptor.editability, InspectorEditability.readOnly)
        XCTAssertNil(binding.write)
        if case let .bool(value) = binding.currentValue() {
            XCTAssertTrue(value)
        } else {
            XCTFail("expected bool current value")
        }
    }

    func testAutobuiltSectionSkipsSystemSubclassWithoutExactLibrary() {
        let view = UIVisualEffectView(effect: nil)

        let libraries = DefaultElementAttributesLibrary.allCases.map { $0 as InspectorElementLibraryProtocol }
        let sections = libraries.formItems(for: view, panel: .attributes)

        XCTAssertFalse(sections.contains(where: { $0.title == "Autobuilt" }))
    }

    func testHierarchyIdentitySectionUsesBindingBackedNotes() throws {
        final class CustomBadgeView: UIView {}

        let dataSource = DefaultElementIdentityLibrary.HierarchyIdentitySectionDataSource(with: CustomBadgeView())
        let bindings = dataSource.propertyBindings

        XCTAssertFalse(bindings.isEmpty)
        XCTAssertTrue(bindings.allSatisfy { $0.descriptor.kind == .note })
        XCTAssertEqual(bindings.first?.descriptor.title, String(describing: CustomBadgeView.self))
    }

    func testPreviewIdentitySectionUsesBindingBackedPreviewAndColor() throws {
        let view = UIView()
        let dataSource = DefaultElementIdentityLibrary.PreviewIdentitySectionDataSource(with: view)
        let bindings = dataSource.propertyBindings

        XCTAssertEqual(bindings.count, 2)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.preview, .color])
        XCTAssertEqual(bindings.first?.descriptor.editability, .readOnly)
        XCTAssertEqual(bindings.last?.descriptor.editability, .editable)
    }

    func testHighlightViewSectionUsesBindingBackedControls() throws {
        let view = UIView(frame: .init(x: 0, y: 0, width: 20, height: 20))
        let element = ViewHierarchyElement(with: view, iconProvider: .default)
        let highlightView = HighlightView(
            frame: view.frame,
            name: "View",
            colorScheme: .default,
            element: element
        )
        view.addSubview(highlightView)

        let dataSource = try XCTUnwrap(
            DefaultElementIdentityLibrary.HighlightViewSectionDataSource(with: view)
        )
        let bindings = dataSource.propertyBindings

        XCTAssertEqual(bindings.count, 2)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.options, .toggle])
    }

    func testViewFrameSizeSectionUsesBindingBackedFields() throws {
        let view = UIView(frame: .init(x: 1, y: 2, width: 30, height: 40))
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.ViewFrameSizeSectionDataSource(with: view)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 3)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.preview, .options, .preview])
        XCTAssertEqual(bindings.first?.descriptor.title, "Frame Rectangle")
    }

    func testContentLayoutPrioritySectionUsesBindingBackedFields() throws {
        let view = UIView(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.ContentLayoutPrioritySizeSectionDataSource(with: view)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 9)
        XCTAssertEqual(bindings.first?.descriptor.kind, .group)
        XCTAssertEqual(bindings[1].descriptor.kind, .options)
        XCTAssertEqual(bindings[2].descriptor.kind, .options)
        XCTAssertEqual(bindings.last?.descriptor.kind, .preview)
    }

    func testLabelSizeSectionUsesBindingBackedFields() throws {
        let label = UILabel()
        label.preferredMaxLayoutWidth = 42
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.LabelSizeSectionDataSource(with: label)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 1)
        XCTAssertEqual(bindings.first?.descriptor.kind, .stepper)
        if case let .number(value) = bindings.first?.currentValue() {
            XCTAssertEqual(value, 42)
        } else {
            XCTFail("expected numeric current value")
        }
    }

    func testSegmentedControlSizeSectionUsesBindingBackedFields() throws {
        let control = UISegmentedControl(items: ["One", "Two"])
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.SegmentedControlSizeSectionDataSource(with: control)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 4)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.options, .stepper, .separator, .options])
        if case let .selection(index) = bindings.first?.currentValue() {
            XCTAssertEqual(index, 0)
        } else {
            XCTFail("expected selected segment binding")
        }
    }
}
#endif
