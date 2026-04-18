#if INSPECTOR_DEBUGGING && canImport(UIKit) && targetEnvironment(simulator)
@testable import Inspector
import InspectorContract
import MapKit
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

    func testWindowAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let window = UIWindow(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.WindowAttributesSectionDataSource(with: window)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 8)
        XCTAssertEqual(bindings[0].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[1].descriptor.editability, .readOnly)
        XCTAssertEqual(bindings[4].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[6].descriptor.kind, .preview)

        bindings[0].apply(.bool(true))
        XCTAssertTrue(window.canResizeToFitContent)
    }

    func testSegmentedControlAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let control = UISegmentedControl(items: ["One", "Two"])
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.SegmentedControlAttributesSectionDataSource(with: control)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 9)
        XCTAssertEqual(bindings[0].descriptor.kind, .color)
        XCTAssertEqual(bindings[3].descriptor.kind, .separator)
        XCTAssertEqual(bindings[4].descriptor.kind, .options)
        XCTAssertEqual(bindings[5].descriptor.kind, .textField)
        XCTAssertEqual(bindings[7].descriptor.kind, .toggle)

        bindings[4].apply(.selection(1))
        bindings[5].apply(.string("Second"))
        bindings[7].apply(.bool(false))
        bindings[8].apply(.bool(true))

        XCTAssertEqual(control.titleForSegment(at: 1), "Second")
        XCTAssertFalse(control.isEnabledForSegment(at: 1))
        XCTAssertEqual(control.selectedSegmentIndex, 1)
    }

    func testTabBarItemAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let viewController = UIViewController()
        let item = UITabBarItem(title: "Home", image: nil, selectedImage: nil)
        viewController.tabBarItem = item

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.TabBarItemAttributesSectionDataSource(with: viewController)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 6)
        XCTAssertEqual(bindings[0].descriptor.kind, .textField)
        XCTAssertEqual(bindings[1].descriptor.kind, .color)
        XCTAssertEqual(bindings[3].descriptor.kind, .preview)
        XCTAssertEqual(bindings[4].descriptor.kind, .group)
        XCTAssertEqual(bindings[5].descriptor.kind, .toggle)

        bindings[0].apply(.string("9"))
        bindings[1].apply(.color(.orange))
        bindings[3].apply(.offset(.init(horizontal: 3, vertical: 4)))
        bindings[5].apply(.bool(true))

        XCTAssertEqual(item.badgeValue, "9")
        XCTAssertEqual(item.badgeColor, .orange)
        XCTAssertEqual(item.titlePositionAdjustment, .init(horizontal: 3, vertical: 4))
        XCTAssertTrue(item.isSpringLoaded)
    }

    func testSliderAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = 0
        slider.maximumValue = 10

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.SliderAttributesSectionDataSource(with: slider)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 12)
        XCTAssertEqual(bindings[0].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[3].descriptor.kind, .separator)
        XCTAssertEqual(bindings[7].descriptor.kind, .color)
        XCTAssertEqual(bindings[11].descriptor.kind, .toggle)

        bindings[0].apply(.number(4.5))
        bindings[7].apply(.color(.red))
        bindings[11].apply(.bool(false))

        XCTAssertEqual(slider.value, 4.5, accuracy: 0.001)
        XCTAssertEqual(slider.minimumTrackTintColor, .red)
        XCTAssertFalse(slider.isContinuous)
    }

    func testStackViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let stackView = UIStackView()
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.StackViewAttributesSectionDataSource(with: stackView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 6)
        XCTAssertEqual(bindings[0].descriptor.kind, .textButtons)
        XCTAssertEqual(bindings[1].descriptor.kind, .options)
        XCTAssertEqual(bindings[2].descriptor.kind, .options)
        XCTAssertEqual(bindings[3].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[4].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[5].descriptor.kind, .toggle)

        bindings[0].apply(.selection(1))
        bindings[2].apply(.selection(1))
        bindings[3].apply(.number(24))
        bindings[4].apply(.bool(true))
        bindings[5].apply(.bool(true))

        XCTAssertEqual(stackView.axis, NSLayoutConstraint.Axis.allCases[1])
        XCTAssertEqual(stackView.distribution, UIStackView.Distribution.allCases[1])
        XCTAssertEqual(stackView.spacing, 24)
        XCTAssertTrue(stackView.isBaselineRelativeArrangement)
        XCTAssertTrue(stackView.isLayoutMarginsRelativeArrangement)
    }

    func testControlAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let control = UIControl(frame: .zero)
        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ControlAttributesSectionDataSource(with: control)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 6)
        XCTAssertEqual(bindings[0].descriptor.kind, .imageButtons)
        XCTAssertEqual(bindings[1].descriptor.kind, .imageButtons)
        XCTAssertEqual(bindings[2].descriptor.kind, .group)
        XCTAssertEqual(bindings[3].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[4].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[5].descriptor.kind, .toggle)

        bindings[3].apply(.bool(true))
        bindings[4].apply(.bool(false))

        XCTAssertTrue(control.isSelected)
        XCTAssertFalse(control.isEnabled)
    }

    func testScrollViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.maximumZoomScale = 4

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ScrollViewAttributesSectionDataSource(with: scrollView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 21)
        XCTAssertEqual(bindings[0].descriptor.kind, .group)
        XCTAssertEqual(bindings[1].descriptor.kind, .options)
        XCTAssertEqual(bindings[5].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[13].descriptor.kind, .separator)
        XCTAssertEqual(bindings[14].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[20].descriptor.kind, .options)

        bindings[1].apply(.selection(1))
        bindings[6].apply(.bool(true))
        bindings[12].apply(.bool(true))
        bindings[15].apply(.number(0.5))
        bindings[16].apply(.number(3))
        bindings[18].apply(.bool(false))
        bindings[20].apply(.selection(1))

        XCTAssertEqual(scrollView.indicatorStyle, UIScrollView.IndicatorStyle.allCases[1])
        XCTAssertTrue(scrollView.isPagingEnabled)
        XCTAssertTrue(scrollView.alwaysBounceVertical)
        XCTAssertEqual(scrollView.minimumZoomScale, 0.5, accuracy: 0.001)
        XCTAssertEqual(scrollView.maximumZoomScale, 3, accuracy: 0.001)
        XCTAssertFalse(scrollView.delaysContentTouches)
        XCTAssertEqual(scrollView.keyboardDismissMode, UIScrollView.KeyboardDismissMode.allCases[1])
    }

    func testTableViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let tableView = UITableView(frame: .zero, style: .plain)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.TableViewAttributesSectionDataSource(with: tableView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 8)
        XCTAssertEqual(bindings[0].descriptor.kind, .options)
        XCTAssertEqual(bindings[0].descriptor.editability, .readOnly)
        XCTAssertEqual(bindings[1].descriptor.kind, .options)
        XCTAssertEqual(bindings[2].descriptor.kind, .color)
        XCTAssertEqual(bindings[3].descriptor.kind, .separator)
        XCTAssertEqual(bindings[4].descriptor.kind, .preview)
        XCTAssertEqual(bindings[7].descriptor.kind, .toggle)

        bindings[1].apply(.selection(1))
        bindings[2].apply(.color(.blue))
        bindings[4].apply(.edgeInsets(.init(top: 1, left: 2, bottom: 3, right: 4)))
        bindings[5].apply(.selection(2))
        bindings[6].apply(.selection(1))
        bindings[7].apply(.bool(true))

        XCTAssertEqual(tableView.separatorStyle, UITableViewCell.SeparatorStyle.allCases[1])
        XCTAssertEqual(tableView.separatorColor, .blue)
        XCTAssertEqual(tableView.separatorInset, .init(top: 1, left: 2, bottom: 3, right: 4))
        XCTAssertTrue(tableView.allowsSelection)
        XCTAssertTrue(tableView.allowsMultipleSelection)
        XCTAssertTrue(tableView.allowsSelectionDuringEditing)
        XCTAssertFalse(tableView.allowsMultipleSelectionDuringEditing)
        XCTAssertTrue(tableView.isSpringLoaded)
    }

    func testNavigationControllerAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let rootViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setToolbarHidden(true, animated: false)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.NavigationControllerAttributesSectionDataSource(with: navigationController)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 8)
        XCTAssertEqual(bindings[0].descriptor.kind, .group)
        XCTAssertEqual(bindings[1].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[2].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[3].descriptor.kind, .group)
        XCTAssertEqual(bindings[4].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[7].descriptor.kind, .toggle)

        bindings[1].apply(.bool(true))
        bindings[2].apply(.bool(true))
        bindings[4].apply(.bool(true))
        bindings[5].apply(.bool(true))
        bindings[6].apply(.bool(true))
        bindings[7].apply(.bool(true))

        XCTAssertFalse(navigationController.isNavigationBarHidden)
        XCTAssertFalse(navigationController.isToolbarHidden)
        XCTAssertTrue(navigationController.hidesBarsOnSwipe)
        XCTAssertTrue(navigationController.hidesBarsOnTap)
        XCTAssertTrue(navigationController.hidesBarsWhenKeyboardAppears)
        XCTAssertTrue(navigationController.hidesBarsWhenVerticallyCompact)
    }

    func testViewControllerAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let viewController = UIViewController()
        viewController.modalTransitionStyle = .coverVertical
        viewController.modalPresentationStyle = .fullScreen

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ViewControllerAttributesSectionDataSource(with: viewController)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 14)
        XCTAssertEqual(bindings[0].descriptor.kind, .textField)
        XCTAssertEqual(bindings[1].descriptor.kind, .separator)
        XCTAssertEqual(bindings[2].descriptor.kind, .group)
        XCTAssertEqual(bindings[8].descriptor.kind, .separator)
        XCTAssertEqual(bindings[9].descriptor.kind, .options)
        XCTAssertEqual(bindings[13].descriptor.kind, .preview)

        bindings[0].apply(.string("Details"))
        bindings[3].apply(.bool(true))
        bindings[5].apply(.bool(false))
        bindings[7].apply(.bool(true))
        bindings[9].apply(.selection(1))
        bindings[10].apply(.selection(1))
        bindings[11].apply(.bool(true))
        bindings[13].apply(.size(.init(width: 320, height: 200)))

        XCTAssertEqual(viewController.title, "Details")
        XCTAssertTrue(viewController.hidesBottomBarWhenPushed)
        XCTAssertFalse(viewController.edgesForExtendedLayout.contains(.top))
        XCTAssertTrue(viewController.extendedLayoutIncludesOpaqueBars)
        XCTAssertEqual(viewController.modalTransitionStyle, UIModalTransitionStyle.allCases[1])
        XCTAssertEqual(viewController.modalPresentationStyle, UIModalPresentationStyle.allCases[1])
        XCTAssertTrue(viewController.definesPresentationContext)
        XCTAssertEqual(viewController.preferredContentSize, .init(width: 320, height: 200))
    }

    func testImageViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let imageView = UIImageView()
        imageView.animationImages = [UIImage(), UIImage()]
        imageView.highlightedAnimationImages = [UIImage()]

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ImageViewAttributesSectionDataSource(with: imageView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 12)
        XCTAssertEqual(bindings[0].descriptor.kind, .preview)
        XCTAssertEqual(bindings[1].descriptor.kind, .group)
        XCTAssertEqual(bindings[2].descriptor.kind, .preview)
        XCTAssertEqual(bindings[4].descriptor.kind, .separator)
        XCTAssertEqual(bindings[5].descriptor.kind, .preview)
        XCTAssertEqual(bindings[6].descriptor.kind, .group)
        XCTAssertEqual(bindings[9].descriptor.kind, .separator)
        XCTAssertEqual(bindings[10].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[11].descriptor.kind, .toggle)

        let image = UIGraphicsImageRenderer(size: .init(width: 2, height: 2)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        let highlightedImage = UIGraphicsImageRenderer(size: .init(width: 2, height: 2)).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }
        bindings[0].apply(.image(image))
        bindings[5].apply(.image(highlightedImage))
        bindings[10].apply(.bool(true))
        bindings[11].apply(.bool(true))

        XCTAssertEqual(imageView.image?.pngData(), image.pngData())
        XCTAssertEqual(imageView.highlightedImage?.pngData(), highlightedImage.pngData())
        XCTAssertTrue(imageView.isHighlighted)
        XCTAssertTrue(imageView.adjustsImageSizeForAccessibilityContentSizeCategory)
    }

    func testMapViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let mapView = MKMapView(frame: .zero)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.MapViewAttributesSectionDataSource(with: mapView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 12)
        XCTAssertEqual(bindings[0].descriptor.kind, .options)
        XCTAssertEqual(bindings[1].descriptor.kind, .group)
        XCTAssertEqual(bindings[2].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[6].descriptor.kind, .group)
        XCTAssertEqual(bindings[9].descriptor.kind, .options)
        XCTAssertEqual(bindings[11].descriptor.kind, .toggle)

        bindings[0].apply(.selection(1))
        bindings[2].apply(.bool(false))
        bindings[3].apply(.bool(false))
        bindings[7].apply(.bool(true))
        bindings[8].apply(.bool(true))
        bindings[9].apply(.selection(1))
        bindings[11].apply(.bool(true))

        XCTAssertEqual(mapView.mapType, MKMapType.allCases[1])
        XCTAssertFalse(mapView.isZoomEnabled)
        XCTAssertFalse(mapView.isRotateEnabled)
        XCTAssertTrue(mapView.showsBuildings)
        XCTAssertTrue(mapView.showsScale)
        XCTAssertEqual(mapView.pointOfInterestFilter, MKPointOfInterestFilter.allCases[0])
        XCTAssertTrue(mapView.showsTraffic)
    }

    func testLayoutConstraintSizeSectionUsesBindingsAndMutatesBehavior() throws {
        let view = UIView(frame: .zero)
        let constraint = view.widthAnchor.constraint(equalToConstant: 80)
        constraint.identifier = "width"
        constraint.priority = .defaultHigh
        constraint.isActive = true

        let element = try XCTUnwrap(LayoutConstraintElement(with: constraint, in: view))
        let dataSource = DefaultElementSizeLibrary.LayoutConstraintSizeSectionDataSource(constraint: element)

        let titleAccessoryBinding = try XCTUnwrap(dataSource.titleAccessoryBinding)
        XCTAssertEqual(titleAccessoryBinding.descriptor.kind, .toggle)

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 8)
        XCTAssertEqual(bindings[0].descriptor.kind, .options)
        XCTAssertEqual(bindings[2].descriptor.kind, .separator)
        XCTAssertEqual(bindings[3].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[4].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[5].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[7].descriptor.kind, .textField)

        titleAccessoryBinding.apply(.bool(false))
        bindings[3].apply(.number(120))
        bindings[4].apply(.number(500))
        bindings[7].apply(.string("updated-width"))

        XCTAssertFalse(constraint.isActive)
        XCTAssertEqual(constraint.constant, 120, accuracy: 0.001)
        XCTAssertEqual(constraint.priority, .init(500))
        XCTAssertEqual(constraint.identifier, "updated-width")
    }

    func testViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let view = UIView(frame: .zero)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ViewAttributesSectionDataSource(with: view)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 21)
        XCTAssertEqual(bindings[0].descriptor.kind, .options)
        XCTAssertEqual(bindings[2].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[3].descriptor.kind, .group)
        XCTAssertEqual(bindings[5].descriptor.kind, .note)
        XCTAssertEqual(bindings[8].descriptor.kind, .group)
        XCTAssertEqual(bindings[11].descriptor.kind, .separator)
        XCTAssertEqual(bindings[15].descriptor.kind, .group)
        XCTAssertEqual(bindings[20].descriptor.kind, .toggle)

        bindings[0].apply(.selection(1))
        bindings[1].apply(.selection(1))
        bindings[2].apply(.number(42))
        bindings[4].apply(.string("view-id"))
        bindings[6].apply(.string("Primary Label"))
        bindings[9].apply(.bool(false))
        bindings[12].apply(.number(0.6))
        bindings[13].apply(.color(.red))
        bindings[17].apply(.bool(true))
        bindings[18].apply(.bool(true))
        bindings[20].apply(.bool(false))

        XCTAssertEqual(view.contentMode, UIView.ContentMode.allCases[1])
        XCTAssertEqual(view.semanticContentAttribute, UISemanticContentAttribute.allCases[1])
        XCTAssertEqual(view.tag, 42)
        XCTAssertEqual(view.accessibilityIdentifier, "view-id")
        XCTAssertEqual(view.accessibilityLabel, "Primary Label")
        XCTAssertFalse(view.isUserInteractionEnabled)
        XCTAssertEqual(view.alpha, 0.6, accuracy: 0.001)
        XCTAssertEqual(view.backgroundColor, .red)
        XCTAssertTrue(view.isHidden)
        XCTAssertTrue(view.clearsContextBeforeDrawing)
        XCTAssertFalse(view.autoresizesSubviews)
    }

    func testApplicationShortcutItemSectionUsesBindingsAndExposesValues() throws {
        let shortcutItem = UIApplicationShortcutItem(
            type: "com.example.open",
            localizedTitle: "Open",
            localizedSubtitle: "Recent",
            icon: nil,
            userInfo: nil
        )

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ApplicationShortcutItemSectionDataSource(with: shortcutItem)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 3)
        XCTAssertEqual(bindings[0].descriptor.kind, InspectorPropertyKind.textField)
        XCTAssertEqual(bindings[0].descriptor.editability, InspectorEditability.readOnly)
        XCTAssertEqual(bindings[1].descriptor.kind, InspectorPropertyKind.textField)
        XCTAssertEqual(bindings[2].descriptor.kind, InspectorPropertyKind.textField)

        guard case let .string(type) = bindings[0].currentValue() else {
            return XCTFail("Expected string value for shortcut type")
        }
        guard case let .string(title) = bindings[1].currentValue() else {
            return XCTFail("Expected string value for shortcut title")
        }
        guard case let .string(subtitle) = bindings[2].currentValue() else {
            return XCTFail("Expected string value for shortcut subtitle")
        }

        XCTAssertEqual(type, "com.example.open")
        XCTAssertEqual(title, "Open")
        XCTAssertEqual(subtitle, "Recent")
    }

    func testKeyCommandsSectionUsesBindingsAndExposesValues() throws {
        let keyCommand = UIKeyCommand(
            title: "Refresh",
            image: nil,
            action: #selector(UIViewController.viewDidLoad),
            input: "r",
            modifierFlags: [.command, .shift],
            propertyList: nil,
            alternates: [],
            discoverabilityTitle: "Refresh content",
            attributes: [],
            state: .off
        )

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.KeyCommandsSectionDataSource(with: keyCommand)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 6)
        XCTAssertEqual(bindings[0].descriptor.kind, .textField)
        XCTAssertEqual(bindings[1].descriptor.kind, .textField)
        XCTAssertEqual(bindings[2].descriptor.kind, .preview)
        XCTAssertEqual(bindings[3].descriptor.kind, .separator)
        XCTAssertEqual(bindings[5].descriptor.kind, .textField)

        guard case let .string(title) = bindings[0].currentValue() else { return XCTFail("Expected title string") }
        guard case let .string(discoverabilityTitle) = bindings[1].currentValue() else { return XCTFail("Expected discoverability title string") }
        guard case let .string(keys) = bindings[4].currentValue() else { return XCTFail("Expected key string") }
        guard case let .string(selector) = bindings[5].currentValue() else { return XCTFail("Expected selector string") }

        XCTAssertEqual(title, "Refresh")
        XCTAssertEqual(discoverabilityTitle, "Refresh content")
        XCTAssertEqual(keys, "⇧ + ⌘ + R")
        XCTAssertEqual(selector, String(describing: #selector(UIViewController.viewDidLoad)))
    }

    func testNavigationItemAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let viewController = UIViewController()
        viewController.navigationItem.title = "Old"
        viewController.navigationItem.prompt = "Prompt"
        viewController.navigationItem.backButtonTitle = "Back"

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.NavigationItemAttributesSectionDataSource(with: viewController)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 5)
        XCTAssertEqual(bindings[0].descriptor.kind, .textField)
        XCTAssertEqual(bindings[1].descriptor.kind, .textField)
        XCTAssertEqual(bindings[2].descriptor.kind, .textField)
        XCTAssertEqual(bindings[3].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[4].descriptor.kind, .options)

        bindings[0].apply(.string("New Title"))
        bindings[1].apply(.string("New Prompt"))
        bindings[2].apply(.string(nil))
        bindings[3].apply(.bool(true))
        bindings[4].apply(.selection(1))

        XCTAssertEqual(viewController.navigationItem.title, "New Title")
        XCTAssertEqual(viewController.navigationItem.prompt, "New Prompt")
        XCTAssertNil(viewController.navigationItem.backButtonTitle)
        XCTAssertTrue(viewController.navigationItem.leftItemsSupplementBackButton)
        XCTAssertEqual(viewController.navigationItem.largeTitleDisplayMode, UINavigationItem.LargeTitleDisplayMode.allCases[1])
    }

    func testLayerAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.LayerAttributesSectionDataSource(with: view)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 19)
        XCTAssertEqual(bindings[0].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[1].descriptor.kind, .color)
        XCTAssertEqual(bindings[2].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[6].descriptor.kind, .separator)
        XCTAssertEqual(bindings[8].descriptor.kind, .separator)
        XCTAssertEqual(bindings[9].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[10].descriptor.kind, .group)
        XCTAssertEqual(bindings[14].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[16].descriptor.kind, .preview)
        XCTAssertEqual(bindings[17].descriptor.kind, .color)
        XCTAssertEqual(bindings[18].descriptor.kind, .textField)

        bindings[0].apply(.number(0.4))
        bindings[1].apply(.color(.green))
        bindings[2].apply(.bool(true))
        bindings[7].apply(.bool(true))
        bindings[9].apply(.number(6))
        bindings[11].apply(.number(3))
        bindings[12].apply(.color(.blue))
        bindings[14].apply(.number(0.6))
        bindings[16].apply(.size(.init(width: 2, height: 3)))
        bindings[17].apply(.color(.black))

        XCTAssertEqual(view.layer.opacity, 0.4, accuracy: 0.001)
        XCTAssertEqual(UIColor(cgColor: view.layer.backgroundColor!), .green)
        XCTAssertTrue(view.layer.isHidden)
        XCTAssertTrue(view.layer.masksToBounds)
        XCTAssertEqual(view.layer.cornerRadius, 6, accuracy: 0.001)
        XCTAssertEqual(view.layer.borderWidth, 3, accuracy: 0.001)
        XCTAssertEqual(UIColor(cgColor: view.layer.borderColor!), .blue)
        XCTAssertEqual(view.layer.shadowOpacity, 0.6, accuracy: 0.001)
        XCTAssertEqual(view.layer.shadowOffset, .init(width: 2, height: 3))
        XCTAssertEqual(UIColor(cgColor: view.layer.shadowColor!), .black)
    }

    func testLabelAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.LabelAttributesSectionDataSource(with: label)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 15)
        XCTAssertEqual(bindings[0].descriptor.kind, .textView)
        XCTAssertEqual(bindings[1].descriptor.kind, .color)
        XCTAssertEqual(bindings[2].descriptor.kind, .options)
        XCTAssertEqual(bindings[3].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[5].descriptor.kind, .imageButtons)
        XCTAssertEqual(bindings[7].descriptor.kind, .group)
        XCTAssertEqual(bindings[10].descriptor.kind, .separator)
        XCTAssertEqual(bindings[11].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[12].descriptor.kind, .separator)
        XCTAssertEqual(bindings[13].descriptor.kind, .color)
        XCTAssertEqual(bindings[14].descriptor.kind, .color)

        bindings[0].apply(.string("Hello"))
        bindings[1].apply(.color(.red))
        bindings[3].apply(.number(18))
        bindings[5].apply(.selection(1))
        bindings[6].apply(.number(3))
        bindings[8].apply(.bool(false))
        bindings[11].apply(.bool(true))
        bindings[13].apply(.color(.blue))
        bindings[14].apply(.color(.green))

        XCTAssertEqual(label.text, "Hello")
        XCTAssertEqual(label.textColor, .red)
        XCTAssertEqual(label.font.pointSize, 18, accuracy: 0.001)
        XCTAssertEqual(label.textAlignment, NSTextAlignment.allCases.withImages[1])
        XCTAssertEqual(label.numberOfLines, 3)
        XCTAssertFalse(label.isEnabled)
        XCTAssertTrue(label.allowsDefaultTighteningForTruncation)
        XCTAssertEqual(label.highlightedTextColor, .blue)
        XCTAssertEqual(label.shadowColor, .green)
    }

    func testNavigationBarAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        navigationBar.largeTitleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.gray
        ]

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.NavigationBarAttributesSectionDataSource(with: navigationBar)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 17)
        XCTAssertEqual(bindings[0].descriptor.kind, .options)
        XCTAssertEqual(bindings[1].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[4].descriptor.kind, .preview)
        XCTAssertEqual(bindings[7].descriptor.kind, .separator)
        XCTAssertEqual(bindings[8].descriptor.kind, .group)
        XCTAssertEqual(bindings[9].descriptor.kind, .options)
        XCTAssertEqual(bindings[10].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[14].descriptor.kind, .options)
        XCTAssertEqual(bindings[16].descriptor.kind, .color)

        bindings[0].apply(.selection(1))
        bindings[1].apply(.bool(true))
        bindings[2].apply(.bool(true))
        bindings[3].apply(.color(.red))
        bindings[10].apply(.number(20))
        bindings[11].apply(.color(.blue))
        bindings[15].apply(.number(30))
        bindings[16].apply(.color(.green))

        XCTAssertEqual(navigationBar.barStyle, UIBarStyle.allCases[1])
        XCTAssertTrue(navigationBar.isTranslucent)
        XCTAssertTrue(navigationBar.prefersLargeTitles)
        XCTAssertEqual(navigationBar.barTintColor, .red)
        XCTAssertEqual(try XCTUnwrap(navigationBar.titleTextAttributes?[.font] as? UIFont).pointSize, 20, accuracy: 0.001)
        XCTAssertEqual(navigationBar.titleTextAttributes?[.foregroundColor] as? UIColor, .blue)
        XCTAssertEqual(try XCTUnwrap(navigationBar.largeTitleTextAttributes?[.font] as? UIFont).pointSize, 30, accuracy: 0.001)
        XCTAssertEqual(navigationBar.largeTitleTextAttributes?[.foregroundColor] as? UIColor, .green)
    }

    func testTextViewAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.TextViewAttributesSectionDataSource(with: textView)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 29)
        XCTAssertEqual(bindings[0].descriptor.kind, .textView)
        XCTAssertEqual(bindings[1].descriptor.kind, .color)
        XCTAssertEqual(bindings[2].descriptor.kind, .options)
        XCTAssertEqual(bindings[3].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[5].descriptor.kind, .imageButtons)
        XCTAssertEqual(bindings[6].descriptor.kind, .group)
        XCTAssertEqual(bindings[9].descriptor.kind, .group)
        XCTAssertEqual(bindings[17].descriptor.kind, .group)
        XCTAssertEqual(bindings[28].descriptor.kind, .toggle)

        bindings[0].apply(.string("Body"))
        bindings[1].apply(.color(.purple))
        bindings[3].apply(.number(18))
        bindings[5].apply(.selection(1))
        bindings[7].apply(.bool(false))
        bindings[8].apply(.bool(false))
        bindings[10].apply(.bool(true))
        bindings[18].apply(.selection(1))
        bindings[26].apply(.selection(1))
        bindings[28].apply(.bool(true))

        XCTAssertEqual(textView.text, "Body")
        XCTAssertEqual(textView.textColor, .purple)
        XCTAssertEqual(try XCTUnwrap(textView.font).pointSize, 18, accuracy: 0.001)
        XCTAssertEqual(textView.textAlignment, NSTextAlignment.allCases.withImages[1])
        XCTAssertFalse(textView.isEditable)
        XCTAssertFalse(textView.isSelectable)
        XCTAssertTrue(textView.dataDetectorTypes.contains(.phoneNumber))
        XCTAssertEqual(textView.textContentType, UITextContentType.allCases[1])
        XCTAssertEqual(textView.returnKeyType, UIReturnKeyType.allCases[1])
        XCTAssertTrue(textView.isSecureTextEntry)
    }

    func testTextFieldAttributesSectionUsesBindingsAndMutatesBehavior() throws {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 14)

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.TextFieldAttributesSectionDataSource(with: textField)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertEqual(bindings.count, 29)
        XCTAssertEqual(bindings[0].descriptor.kind, .textField)
        XCTAssertEqual(bindings[1].descriptor.kind, .color)
        XCTAssertEqual(bindings[2].descriptor.kind, .options)
        XCTAssertEqual(bindings[3].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[5].descriptor.kind, .imageButtons)
        XCTAssertEqual(bindings[7].descriptor.kind, .group)
        XCTAssertEqual(bindings[10].descriptor.kind, .separator)
        XCTAssertEqual(bindings[11].descriptor.kind, .imageButtons)
        XCTAssertEqual(bindings[14].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[28].descriptor.kind, .toggle)

        bindings[0].apply(.string("Field"))
        bindings[1].apply(.color(.orange))
        bindings[3].apply(.number(20))
        bindings[5].apply(.selection(1))
        bindings[6].apply(.string("Hint"))
        bindings[11].apply(.selection(1))
        bindings[13].apply(.selection(1))
        bindings[14].apply(.bool(true))
        bindings[16].apply(.number(10))
        bindings[18].apply(.selection(1))
        bindings[26].apply(.selection(1))
        bindings[28].apply(.bool(true))

        XCTAssertEqual(textField.text, "Field")
        XCTAssertEqual(textField.textColor, .orange)
        XCTAssertEqual(try XCTUnwrap(textField.font).pointSize, 20, accuracy: 0.001)
        XCTAssertEqual(textField.textAlignment, NSTextAlignment.allCases.withImages[1])
        XCTAssertEqual(textField.placeholder, "Hint")
        XCTAssertEqual(textField.borderStyle, UITextField.BorderStyle.allCases.withImages[1])
        XCTAssertEqual(textField.clearButtonMode, UITextField.ViewMode.allCases[1])
        XCTAssertTrue(textField.clearsOnBeginEditing)
        XCTAssertEqual(textField.minimumFontSize, 10, accuracy: 0.001)
        XCTAssertEqual(textField.textContentType, UITextContentType.allCases[1])
        XCTAssertEqual(textField.returnKeyType, UIReturnKeyType.allCases[1])
        XCTAssertTrue(textField.isSecureTextEntry)
    }

    func testApplicationAttributesSectionUsesBindingsAndMutatesEditableState() throws {
        let application = UIApplication.shared
        let originalIdleTimerDisabled = application.isIdleTimerDisabled
        let originalBadgeNumber = application.applicationIconBadgeNumber
        let originalShakeToEdit = application.applicationSupportsShakeToEdit

        let dataSource = try XCTUnwrap(
            DefaultElementAttributesLibrary.ApplicationAttributesSectionDataSource(with: application)
        )

        let bindings = dataSource.propertyBindings
        XCTAssertTrue(bindings.count >= 8)
        XCTAssertEqual(bindings[0].descriptor.kind, .textField)
        XCTAssertEqual(bindings[1].descriptor.kind, .stepper)
        XCTAssertEqual(bindings[2].descriptor.kind, .textField)
        XCTAssertEqual(bindings[3].descriptor.kind, .toggle)
        XCTAssertEqual(bindings[4].descriptor.kind, .toggle)

        bindings[1].apply(.number(7))
        bindings[3].apply(.bool(!originalShakeToEdit))
        bindings[4].apply(.bool(true))

        XCTAssertEqual(application.applicationIconBadgeNumber, 7)
        XCTAssertEqual(application.applicationSupportsShakeToEdit, !originalShakeToEdit)
        XCTAssertFalse(application.isIdleTimerDisabled)

        application.isIdleTimerDisabled = originalIdleTimerDisabled
        application.applicationIconBadgeNumber = originalBadgeNumber
        application.applicationSupportsShakeToEdit = originalShakeToEdit
    }

}
#endif
