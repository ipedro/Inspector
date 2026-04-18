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
}
#endif
