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

extension ViewHierarchyElementIconProvider {
    static let `default` = ViewHierarchyElementIconProvider { object in

        guard let object = object else { return .missingSymbol }

        guard let view = object as? UIView else {
            switch object {
            case is UISearchController:
                return .searchController

            case is UIPageViewController:
                return .pageViewController

            case is UINavigationController:
                return .navigationController

            case is UICollectionViewController:
                return .collectionViewController

            case is UITableViewController:
                return .tableViewController

            case is UITabBarController:
                return .tabBarController

            default:
                return .nsObject
            }
        }

        guard view.isHidden == false else { return .hiddenViewSymbol }

        switch view {
        case let window as UIWindow:
            if window._className.contains("Keyboard") { return .keyboardWindow }
            if window.isKeyWindow { return .keyWindow }
            return .window

        case is UIActivityIndicatorView:
            return .activityIndicatorView

        case is UISlider:
            return .slider

        case is UIDatePicker:
            return .datePicker

        case is UISwitch:
            return .toggle

        case is UIButton,
             is UIControl where view.className.contains("Button"):
            return .button

        case let imageView as UIImageView:
            guard let image = imageView.isHighlighted ? imageView.highlightedImage : imageView.image else {
                return .imageView
            }
            return image

        case is UISegmentedControl:
            return .segmentedControl

        case let stackView as UIStackView:
            return stackView.axis == .horizontal ? .horizontalStack : .verticalStack

        case is UILabel:
            return .staticText

        case is UITextField:
            return .textField

        case is UITextView:
            return .textView

        case is WKWebView:
            return .webView

        case is UICollectionView:
            return .collectionView

        case is UITableView:
            return .tableView

        case is UIScrollView:
            return .scrollView

        case is UINavigationBar:
            return .navigationBar

        case is UITabBar:
            return .tabBar

        case is UIToolbar:
            return .toolbar

        case is UIControl:
            return .control

        case is MKMapView:
            return .mapView

        case let view:
            if view._className == "CGDrawingView" { return .staticText }
            if view._className.contains("Effects") { return .systemIcon("wand.and.stars")! }
            if view.children.isEmpty { return .emptyViewSymbol }
            if view.className.contains("Background") { return .icon("BackgroundView-32_Normal") }
            if view.className.contains("DropShadow") { return .icon("DropShadow-32_Normal") }
            if view.className.contains("Label") { return .staticText }
            if view.className.contains("TransitionView") { return .icon("UITransitionView-32_Normal") }
            return .containerViewSymbol
        }
    }
}

private extension UIImage {
    static let activityIndicatorView: UIImage = .systemIcon("rays", weight: .bold)!
    static let button: UIImage = .systemIcon("hand.tap.fill")!
    static let collectionView: UIImage = .systemIcon("square.grid.3x1.below.line.grid.1x2")!
    static let collectionViewController: UIImage = .systemIcon("square.grid.3x3")!
    static let containerViewSymbol: UIImage = .icon("filled-view-32_Normal")!
    static let control: UIImage = .systemIcon("dial.min.fill")!
    static let datePicker: UIImage = .icon("UIDatePicker_32_Normal")!
    static let emptyViewSymbol: UIImage = .icon("EmptyView-32_Normal")!
    static let horizontalStack: UIImage = .icon("HStack-32_Normal")!
    static let imageView: UIImage = .systemIcon("photo")!
    static let keyWindow: UIImage = .icon("Key-UIWindow-32_Normal")!
    static let keyboardWindow: UIImage = .systemIcon("keyboard.macwindow", weight: .regular)!
    static let mapView: UIImage = .systemIcon("map")!
    static let navigationBar: UIImage = .icon("NavigationBar-32_Normal")!
    static let navigationController: UIImage = .systemIcon("chevron.left.square")!
    static let nsObject: UIImage = .systemIcon("shippingbox", weight: .regular)!
    static let pageViewController: UIImage = .icon("UIPageViewController")!
    static let scrollView: UIImage = .icon("UIScrollView_32_Normal")!
    static let searchController: UIImage = .icon("UISearchController")!
    static let segmentedControl: UIImage = .icon("UISegmentedControl_32_Normal")!
    static let slider: UIImage = .icon("UISlider_32_Normal")!
    static let staticText: UIImage = .systemIcon("textformat.abc", weight: .bold)!
    static let tabBar: UIImage = .icon("TabbedView-32_Normal")!
    static let tabBarController: UIImage = .icon("TabbedView-32_Normal")!
    static let tableView: UIImage = .systemIcon("square.fill.text.grid.1x2")!
    static let tableViewController: UIImage = .icon("UITableViewController")!
    static let textField: UIImage = .systemIcon("character.textbox", weight: .bold)!
    static let textView: UIImage = .systemIcon("textformat.abc.dottedunderline", weight: .bold)!
    static let toggle: UIImage = .icon("Toggle-32_Normal")!
    static let toolbar: UIImage = .icon("UIToolbar-32_Normal")!
    static let verticalStack: UIImage = .icon("VStack-32_Normal")!
    static let webView: UIImage = .systemIcon("safari")!
    static let window: UIImage = .systemIcon("macwindow", weight: .regular)!
}
