//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import MapKit
import UIKit
import WebKit

enum DefaultElementAttributesLibrary: Swift.CaseIterable, InspectorElementLibraryProtocol {
    case activityIndicator
    case application
    case button
    case control
    case datePicker
    case imageView
    case label
    case mapView
    case navigationBar
    case navigationController
    case scrollView
    case segmentedControl
    case slider
    case stackView
    case `switch`
    case tabBar
    case tableView
    case textField
    case textView
    case view
    case viewController
    case webView
    case window

    // MARK: - InspectorElementLibraryProtocol

    var targetClass: AnyClass {
        switch self {
        case .activityIndicator: UIActivityIndicatorView.self
        case .application: UIApplication.self
        case .button: UIButton.self
        case .control: UIControl.self
        case .datePicker: UIDatePicker.self
        case .imageView: UIImageView.self
        case .label: UILabel.self
        case .mapView: MKMapView.self
        case .navigationBar: UINavigationBar.self
        case .navigationController: UINavigationController.self
        case .scrollView: UIScrollView.self
        case .segmentedControl: UISegmentedControl.self
        case .slider: UISlider.self
        case .stackView: UIStackView.self
        case .switch: UISwitch.self
        case .tabBar: UITabBar.self
        case .tableView: UITableView.self
        case .textField: UITextField.self
        case .textView: UITextView.self
        case .view: UIView.self
        case .viewController: UIViewController.self
        case .webView: WKWebView.self
        case .window: UIWindow.self
        }
    }

    func sections(for object: NSObject) -> InspectorElementSections {
        switch self {
        case .application:
            let firstSection = InspectorElementSection(rows: ApplicationAttributesSectionDataSource(with: object))

            guard
                let application = object as? UIApplication,
                let shortcutItems = application.shortcutItems,
                !shortcutItems.isEmpty
            else {
                return [firstSection]
            }

            return [
                firstSection,
                InspectorElementSection(
                    title: "Shortcut Items",
                    rows: shortcutItems.map(ApplicationShortcutItemSectionDataSource.init(with:))
                )
            ]

        case .viewController:
            guard let viewController = object as? UIViewController else { return .empty }

            let firstSection = InspectorElementSection(
                rows:
                ViewControllerAttributesSectionDataSource(with: viewController),
                TabBarItemAttributesSectionDataSource(with: viewController),
                NavigationItemAttributesSectionDataSource(with: viewController)
            )

            guard
                let keyCommands = viewController.keyCommands,
                !keyCommands.isEmpty
            else {
                return [firstSection]
            }

            return [
                firstSection,
                InspectorElementSection(
                    title: "Key Commands",
                    rows: keyCommands.map(KeyCommandsSectionDataSource.init(with:))
                )
            ]

        case .navigationBar:
            var section = InspectorElementSection(
                rows:
                NavigationBarAppearanceAttributesSectionDataSource(with: object, .standard),
                NavigationBarAppearanceAttributesSectionDataSource(with: object, .compact),
                NavigationBarAppearanceAttributesSectionDataSource(with: object, .scrollEdge)
            )

            if #available(iOS 15.0, *) {
                section.append(NavigationBarAppearanceAttributesSectionDataSource(with: object, .compactScrollEdge))
            }

            section.append(NavigationBarAttributesSectionDataSource(with: object))

            return [section]

        case .view: return .init(
                with:
                ViewAttributesSectionDataSource(with: object),
                LayerAttributesSectionDataSource(with: object)
            )

        case .navigationController: return .init(with: NavigationControllerAttributesSectionDataSource(with: object))

        case .tableView: return .init(with: TableViewAttributesSectionDataSource(with: object))

        case .window: return .init(with: WindowAttributesSectionDataSource(with: object))

        case .activityIndicator: return .init(with: ActivityIndicatorViewAttributesSectionDataSource(with: object))

        case .button: return .init(with: ButtonAttributesSectionDataSource(with: object))

        case .control: return .init(with: ControlAttributesSectionDataSource(with: object))

        case .datePicker: return .init(with: DatePickerAttributesSectionDataSource(with: object))

        case .imageView: return .init(with: ImageViewAttributesSectionDataSource(with: object))

        case .label: return .init(with: LabelAttributesSectionDataSource(with: object))

        case .mapView: return .init(with: MapViewAttributesSectionDataSource(with: object))

        case .scrollView: return .init(with: ScrollViewAttributesSectionDataSource(with: object))

        case .segmentedControl: return .init(with: SegmentedControlAttributesSectionDataSource(with: object))

        case .slider: return .init(with: SliderAttributesSectionDataSource(with: object))

        case .switch: return .init(with: SwitchAttributesSectionDataSource(with: object))

        case .stackView: return .init(with: StackViewAttributesSectionDataSource(with: object))

        case .textField: return .init(with: TextFieldAttributesSectionDataSource(with: object))

        case .textView: return .init(with: TextViewAttributesSectionDataSource(with: object))

        case .tabBar: return .init(with: TabBarAttributesSectionDataSource(with: object))

        case .webView: return []
        }
    }
}
