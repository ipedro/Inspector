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
                return .icon("UISearchController")
            case is UIPageViewController:
                return .icon("UIPageViewController")
            case is UINavigationController:
                return .navigationController
            case is UICollectionViewController:
                return .collectionViewController
            case is UITableViewController:
                return .icon("UITableViewController")
            case is UITabBarController:
                return .icon("TabbedView-32_Normal")
            default:
                return .nsObject
            }
        }

        guard view.isHidden == false else { return .hiddenViewSymbol }

        switch view {
        case let window as UIWindow where window.isKeyWindow:
            return .icon("Key-UIWindow-32_Normal")

        case is UIWindow:
            return .icon("UIWindow-32_Normal")

        case is UIActivityIndicatorView:
            return .icon("UIActivityIndicator_32_Dark_Normal")

        case is UISlider:
            return .icon("Slider-32_Normal")

        case is UIDatePicker:
            return .icon("UIDatePicker_32_Normal")

        case is UISwitch:
            return .icon("Toggle-32_Normal")

        case is UIButton,
             is UIControl where view.className.contains("Button"):
            return .icon("Button-32_Normal")

        case let imageView as UIImageView:
            guard let image = imageView.isHighlighted ? imageView.highlightedImage : imageView.image else {
                return .icon("ImageView-32_Normal")
            }

            if image.renderingMode == .alwaysTemplate {
                return image.withTintColor(imageView.tintColor)
            }

            return image

        case is UILabel:
            return .icon("UILabel_32-Dark_Normal")

        case is UISegmentedControl:
            return .icon("UISegmentedControl_32_Normal")

        case let stackView as UIStackView:
            switch stackView.axis {
            case .horizontal:
                return .icon("HStack-32_Normal")

            case .vertical:
                return .icon("VStack-32_Normal")

            @unknown default:
                return .missingSymbol
            }

        case is UITextField:
            return .icon("TextField-32_Normal")

        case is UITextView:
            return .icon("TextView-32_Normal")

        case is WKWebView:
            return .icon("Webview-32_Normal")

        case is UIScrollView:
            return .icon("UIScrollView_32_Normal")

        case is UINavigationBar:
            return .icon("NavigationBar-32_Normal")

        case is UITabBar:
            return .icon("TabbedView-32_Normal")

        case is UIToolbar:
            return .icon("UIToolbar-32_Normal")

        case is UIControl:
            return .icon("UIControl-32_Normal")

        case let view where view.className.contains("VisualEffect"):
            return .icon("VisualEffectsView-32_Normal")

        case let view where view.className.contains("TransitionView"):
            return .icon("UITransitionView-32_Normal")

        case let view where view.className.contains("DropShadow"):
            return .icon("DropShadow-32_Normal")

        case let view where view.className.contains("Background"):
            return .icon("BackgroundView-32_Normal")

        case let view where view.className.contains("_UI"):
            return .icon("keyboardShortcut-32_Normal")

        case let view where !view.children.isEmpty:
            return .icon("filled-view-32_Normal")

        default:
            return .emptyViewSymbol
        }
    }
}
