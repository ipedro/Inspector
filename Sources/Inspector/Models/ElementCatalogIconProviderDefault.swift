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
    static let `default` = ViewHierarchyElementIconProvider { view in

        guard let view = view else { return .missingViewSymbol }

        guard view.isHidden == false else { return .hiddenViewSymbol }

        switch view {
        case is UINavigationBar:
            return .moduleImage(named: "NavigationBar-32_Normal")

        case is UIWindow:
            return .moduleImage(named: "Window-32_Normal")

        case is UIActivityIndicatorView:
            return .moduleImage(named: "UIActivityIndicator_32_Dark_Normal")!

        case is UISlider:
            return .moduleImage(named: "Slider-32_Normal")

        case is UIDatePicker:
            return .moduleImage(named: "UIDatePicker_32_Normal")

        case is UISwitch:
            return .moduleImage(named: "Toggle-32_Normal")

        case is UIButton,
             is UIControl where view.className.contains("Button"):
            return .moduleImage(named: "UIButton_32-Dark_Normal")!

        case let imageView as UIImageView:
            if imageView.isHighlighted, let highlightImage = imageView.highlightedImage {
                if #available(iOS 13.0, *) {
                    if highlightImage.renderingMode != .alwaysOriginal {
                        return highlightImage.withTintColor(imageView.tintColor)
                    }
                }
                return highlightImage
            }
            if let image = imageView.image {
                if #available(iOS 13.0, *) {
                    if image.renderingMode != .alwaysOriginal {
                        return image.withTintColor(imageView.tintColor)
                    }
                }
                return image
            }
            return .moduleImage(named: "ImageView-32_Normal")

        case is UILabel:
            return .moduleImage(named: "UILabel_32-Dark_Normal")!

        case is UIScrollView:
            return .moduleImage(named: "UIScrollView_32_Normal")

        case is UISegmentedControl:
            return .moduleImage(named: "UISegmentedControl_32_Normal")

        case let stackView as UIStackView:
            switch stackView.axis {
            case .horizontal:
                return .moduleImage(named: "HStack-32_Normal")

            case .vertical:
                return .moduleImage(named: "VStack-32_Normal")

            @unknown default:
                return nil
            }

        case is UITextField:
            return .moduleImage(named: "TextField-32_Normal")

        case is UITextView:
            return .moduleImage(named: "TextView-32_Normal")

        case is WKWebView:
            return .moduleImage(named: "Webview-32_Normal")

        case is UITabBar:
            return .moduleImage(named: "TabbedView-32_Normal")

        case is UIToolbar:
            return .moduleImage(named: "UITtoolbar-32_Normal")

        case is UIControl:
            return .moduleImage(named: "UIControl-32_Normal")

        case _ where view.className.contains("VisualEffect"):
            return .moduleImage(named: "VisualEffectsView-32_Normal")

        case _ where view.className.contains("TransitionView"):
            return .moduleImage(named: "UITransitionView-32_Normal")

        case _ where view.className.contains("DropShadow"):
            return .moduleImage(named: "DropShadow-32_Normal")

        case _ where view.className.contains("Background"):
            return .moduleImage(named: "BackgroundView-32_Normal")

        case _ where view.className.contains("_UI"):
            return .moduleImage(named: "keyboardShortcut-32_Normal")

        case _ where !view.originalSubviews.isEmpty:
            return .moduleImage(named: "filled-view-32_Normal")

        default:
            return .emptyViewSymbol
        }
    }
}
