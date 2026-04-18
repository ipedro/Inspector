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

        bindings[0].apply(.rect(.init(x: 10, y: 20, width: 50, height: 60)))
        XCTAssertEqual(view.frame, .init(x: 10, y: 20, width: 50, height: 60))
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

        bindings[1].apply(.selection(2))
        XCTAssertEqual(view.contentHuggingPriority(for: .horizontal), UILayoutPriority.allCases[2])
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

        bindings[0].apply(.number(100))
        XCTAssertEqual(label.preferredMaxLayoutWidth, 100)
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

        bindings[0].apply(.selection(1))
        bindings[1].apply(.number(88))
        bindings[3].apply(.selection(1))

        XCTAssertEqual(control.widthForSegment(at: 1), 88)
        XCTAssertTrue(control.apportionsSegmentWidthsByContent)
    }

    func testScrollViewSizeSectionUsesBindingBackedFields() throws {
        let scrollView = UIScrollView(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.ScrollViewSizeSectionDataSource(with: scrollView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 6)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.preview, .preview, .options, .preview, .separator, .preview])
        XCTAssertEqual(bindings[2].descriptor.presentation?.axis, .vertical)

        let newInsets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
        bindings[0].apply(.edgeInsets(newInsets))
        bindings[3].apply(.edgeInsets(newInsets))
        bindings[2].apply(.selection(1))

        XCTAssertEqual(scrollView.verticalScrollIndicatorInsets, newInsets)
        XCTAssertEqual(scrollView.contentInset, newInsets)
        XCTAssertEqual(scrollView.contentInsetAdjustmentBehavior, UIScrollView.ContentInsetAdjustmentBehavior.allCases[1])
    }

    func testTableViewSizeSectionUsesBindingBackedFields() throws {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.TableViewSizeSectionDataSource(with: tableView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 11)
        XCTAssertEqual(bindings.first?.descriptor.kind, .stepper)
        XCTAssertEqual(bindings[2].descriptor.kind, .separator)
        XCTAssertEqual(bindings[3].descriptor.kind, .group)
        XCTAssertEqual(bindings.last?.descriptor.kind, .toggle)

        bindings[0].apply(.number(44))
        bindings[1].apply(.number(55))
        bindings[10].apply(.bool(false))

        XCTAssertEqual(tableView.rowHeight, 44)
        XCTAssertEqual(tableView.estimatedRowHeight, 55)
        XCTAssertFalse(tableView.insetsContentViewsToSafeArea)
    }

    func testButtonSizeSectionUsesBindingBackedFieldsAndMutatesInsets() throws {
        let button = UIButton(type: .system)
        let dataSource = try XCTUnwrap(
            DefaultElementSizeLibrary.ButtonSizeSectionDataSource(with: button)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 3)
        XCTAssertTrue(bindings.allSatisfy { $0.descriptor.kind == .preview })

        let newInsets = UIEdgeInsets(top: 9, left: 8, bottom: 7, right: 6)
        bindings[0].apply(.edgeInsets(newInsets))
        bindings[1].apply(.edgeInsets(newInsets))
        bindings[2].apply(.edgeInsets(newInsets))

        XCTAssertEqual(button.contentEdgeInsets, newInsets)
        XCTAssertEqual(button.imageEdgeInsets, newInsets)
        XCTAssertEqual(button.titleEdgeInsets, newInsets)
    }

    func testActivityIndicatorAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let indicator = UIActivityIndicatorView(style: .medium)
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ActivityIndicatorViewAttributesSectionDataSource(with: indicator)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 5)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.options, .color, .group, .toggle, .toggle])

        bindings[0].apply(.selection(0))
        bindings[1].apply(.color(.red))
        bindings[3].apply(.bool(true))
        bindings[4].apply(.bool(false))

        XCTAssertEqual(indicator.style, UIActivityIndicatorView.Style.allCases[0])
        XCTAssertEqual(indicator.color, .red)
        XCTAssertTrue(indicator.isAnimating)
        XCTAssertFalse(indicator.hidesWhenStopped)
    }

    func testSwitchAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let control = UISwitch(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.SwitchAttributesSectionDataSource(with: control)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 5)
        XCTAssertEqual(bindings.map(\.descriptor.kind), [.textField, .textButtons, .toggle, .color, .color])
        XCTAssertEqual(bindings[0].descriptor.editability, .readOnly)

        bindings[2].apply(.bool(true))
        bindings[3].apply(.color(.green))
        bindings[4].apply(.color(.yellow))

        XCTAssertTrue(control.isOn)
        XCTAssertEqual(control.onTintColor, .green)
        XCTAssertEqual(control.thumbTintColor, .yellow)
    }

    func testTabBarAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let tabBar = UITabBar(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.TabBarAttributesSectionDataSource(with: tabBar)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 7)
        XCTAssertEqual(bindings[0].descriptor.kind, .preview)
        XCTAssertEqual(bindings[3].descriptor.kind, .separator)
        XCTAssertEqual(bindings[4].descriptor.kind, .options)
        XCTAssertEqual(bindings[5].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[6].descriptor.kind, .color)

        bindings[4].apply(.selection(0))
        bindings[5].apply(.bool(false))
        bindings[6].apply(.color(.purple))

        XCTAssertEqual(tabBar.barStyle, UIBarStyle.allCases[0])
        XCTAssertFalse(tabBar.isTranslucent)
        XCTAssertEqual(tabBar.barTintColor, .purple)
    }

    func testDatePickerAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let datePicker = UIDatePicker(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.DatePickerAttributesSectionDataSource(with: datePicker)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 3)
        XCTAssertTrue(bindings.allSatisfy { $0.descriptor.kind == .options })

        bindings[0].apply(.selection(0))
        bindings[1].apply(.selection(0))
        bindings[2].apply(.selection(1))

        XCTAssertEqual(datePicker.preferredDatePickerStyle, UIDatePickerStyle.allCases[0])
        XCTAssertEqual(datePicker.datePickerMode, UIDatePicker.Mode.allCases[0])
        XCTAssertEqual(datePicker.minuteInterval, 2)
    }

}
#endif
