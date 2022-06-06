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
                return .moduleImage(named: "UISearchController")
            case is UIPageViewController:
                return .moduleImage(named: "UIPageViewController")
            case is UINavigationController:
                return .light(systemName: "chevron.left.square")
            case is UICollectionViewController:
                return .light(systemName: "square.grid.3x3.square")
            case is UITableViewController:
                return .moduleImage(named: "UITableViewController")
            case is UITabBarController:
                return .moduleImage(named: "TabbedView-32_Normal")
            default:
                return .light(systemName: "shippingbox")
            }
        }

        guard view.isHidden == false else { return .hiddenViewSymbol }

        switch view {
        case is UIWindow:
            return .light(systemName: "uiwindow.split.2x1")

        case is UIActivityIndicatorView:
            return .moduleImage(named: "UIActivityIndicator_32_Dark_Normal")

        case is UISlider:
            return .moduleImage(named: "Slider-32_Normal")

        case is UIDatePicker:
            return .moduleImage(named: "UIDatePicker_32_Normal")

        case is UISwitch:
            return .moduleImage(named: "Toggle-32_Normal")

        case is UIButton,
             is UIControl where view.className.contains("Button"):
            return .moduleImage(named: "Button-32_Normal")

        case let imageView as UIImageView:
            guard let image = imageView.isHighlighted ? imageView.highlightedImage : imageView.image else {
                return .moduleImage(named: "ImageView-32_Normal")
            }

            if image.renderingMode == .alwaysTemplate {
                return image.withTintColor(imageView.tintColor)
            }

            return image

        case is UILabel:
            return .moduleImage(named: "UILabel_32-Dark_Normal")

        case is UISegmentedControl:
            return .moduleImage(named: "UISegmentedControl_32_Normal")

        case let stackView as UIStackView:
            switch stackView.axis {
            case .horizontal:
                return .moduleImage(named: "HStack-32_Normal")

            case .vertical:
                return .moduleImage(named: "VStack-32_Normal")

            @unknown default:
                return .missingSymbol
            }

        case is UITextField:
            return .moduleImage(named: "TextField-32_Normal")

        case is UITextView:
            return .moduleImage(named: "TextView-32_Normal")

        case is WKWebView:
            return .moduleImage(named: "Webview-32_Normal")

        case is UIScrollView:
            return .moduleImage(named: "UIScrollView_32_Normal")

        case is UINavigationBar:
            return .moduleImage(named: "NavigationBar-32_Normal")

        case is UITabBar:
            return .moduleImage(named: "TabbedView-32_Normal")

        case is UIToolbar:
            return .moduleImage(named: "UIToolbar-32_Normal")

        case is UIControl:
            return .moduleImage(named: "UIControl-32_Normal")

        case let view where view.className.contains("VisualEffect"):
            return .moduleImage(named: "VisualEffectsView-32_Normal")

        case let view where view.className.contains("TransitionView"):
            return .moduleImage(named: "UITransitionView-32_Normal")

        case let view where view.className.contains("DropShadow"):
            return .moduleImage(named: "DropShadow-32_Normal")

        case let view where view.className.contains("Background"):
            return .moduleImage(named: "BackgroundView-32_Normal")

        case let view where view.className.contains("_UI"):
            return .moduleImage(named: "keyboardShortcut-32_Normal")

        case let view where !view.children.isEmpty:
            return .moduleImage(named: "filled-view-32_Normal")

        default:
            return .emptyViewSymbol
        }
    }
}
