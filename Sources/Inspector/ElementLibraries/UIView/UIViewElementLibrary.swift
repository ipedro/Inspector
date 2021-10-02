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

enum UIViewElementLibrary: Swift.CaseIterable, InspectorElementLibraryProtocol {
    case activityIndicator
    case button
    case control
    case datePicker
    case imageView
    case label
    case mapView
    case scrollView
    case segmentedControl
    case slider
    case `switch`
    case stackView
    case textField
    case textView
    case view
    case window
    case navigationBarStandardAppearance
    case navigationBarCompactAppearance
    case navigationBarScrollEdgeAppearance
    case navigationBarCompactScrollEdgeAppearance
    case navigationBar
    case tabBar
    case webView
    case coreAnimationLayer
    case runtimeAttributes

    // MARK: - InspectorElementLibraryProtocol

    var targetClass: AnyClass {
        switch self {
        case .runtimeAttributes:
            return NSObject.self

        case .coreAnimationLayer:
            return UIView.self

        case .navigationBar,
             .navigationBarStandardAppearance,
             .navigationBarCompactAppearance,
             .navigationBarScrollEdgeAppearance,
             .navigationBarCompactScrollEdgeAppearance:
            return UINavigationBar.self

        case .window:
            return UIWindow.self

        case .activityIndicator:
            return UIActivityIndicatorView.self

        case .button:
            return UIButton.self

        case .control:
            return UIControl.self

        case .datePicker:
            return UIDatePicker.self

        case .imageView:
            return UIImageView.self

        case .label:
            return UILabel.self

        case .mapView:
            return MKMapView.self

        case .scrollView:
            return UIScrollView.self

        case .segmentedControl:
            return UISegmentedControl.self

        case .slider:
            return UISlider.self

        case .switch:
            return UISwitch.self

        case .stackView:
            return UIStackView.self

        case .textField:
            return UITextField.self

        case .textView:
            return UITextView.self

        case .view:
            return UIView.self

        case .webView:
            return WKWebView.self

        case .tabBar:
            return UITabBar.self
        }
    }

    func viewModel(for referenceView: UIView) -> InspectorElementViewModelProtocol? {
        switch self {
        case .runtimeAttributes:
            return RuntimeAttributesInspectableViewModel(view: referenceView)

        case .coreAnimationLayer:
            return CALayerInspectableViewModel(view: referenceView)

        case .window:
            return UIWindowInspectableViewModel(view: referenceView)

        case .navigationBar:
            return UINavigationBarInspectableViewModel(view: referenceView)

        case .navigationBarStandardAppearance:
            guard #available(iOS 13.0, *) else { return nil }
            return UINavigationBarAppearanceInspectableViewModel(type: .standard, view: referenceView)

        case .navigationBarCompactAppearance:
            guard #available(iOS 13.0, *) else { return nil }
            return UINavigationBarAppearanceInspectableViewModel(type: .compact, view: referenceView)

        case .navigationBarScrollEdgeAppearance:
            guard #available(iOS 13.0, *) else { return nil }
            return UINavigationBarAppearanceInspectableViewModel(type: .scrollEdge, view: referenceView)

        case .navigationBarCompactScrollEdgeAppearance:
            #if swift(>=5.5)
            guard #available(iOS 15.0, *) else { return nil }
            return UINavigationBarAppearanceInspectableViewModel(type: .compactScrollEdge, view: referenceView)
            #else
            return nil
            #endif

        case .activityIndicator:
            return UIActivityIndicatorViewInspectableViewModel(view: referenceView)

        case .button:
            return UIButtonInspectableViewModel(view: referenceView)

        case .control:
            return UIControlInspectableViewModel(view: referenceView)

        case .datePicker:
            return UIDatePickerInspectableViewModel(view: referenceView)

        case .imageView:
            return UIImageViewInspectableViewModel(view: referenceView)

        case .label:
            return UILabelInspectableViewModel(view: referenceView)

        case .mapView:
            return MKMapViewInspectableViewModel(view: referenceView)

        case .scrollView:
            return UIScrollViewInspectableViewModel(view: referenceView)

        case .segmentedControl:
            return UISegmentedControlInspectableViewModel(view: referenceView)

        case .slider:
            return UISliderInspectableViewModel(view: referenceView)

        case .switch:
            return UISwitchInspectableViewModel(view: referenceView)

        case .stackView:
            return UIStackViewInspectableViewModel(view: referenceView)

        case .textField:
            return UITextFieldInspectableViewModel(view: referenceView)

        case .textView:
            return UITextViewInspectableViewModel(view: referenceView)

        case .view:
            return UIViewInspectableViewModel(view: referenceView)

        case .tabBar:
            return UITabBarInspectableViewModel(view: referenceView)

        case .webView:
            return nil
        }
    }

    func icon(for referenceView: UIView) -> UIImage? {
        switch referenceView {
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
            is UIControl where referenceView.className.contains("Button"):
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

        case _ where referenceView.className.contains("VisualEffect"):
            return .moduleImage(named: "VisualEffectsView-32_Normal")

        case _ where referenceView.className.contains("TransitionView"):
            return .moduleImage(named: "UITransitionView-32_Normal")

        case _ where referenceView.className.contains("DropShadow"):
            return .moduleImage(named: "DropShadow-32_Normal")

        case _ where referenceView.className.contains("Background"):
            return .moduleImage(named: "BackgroundView-32_Normal")

        case _ where referenceView.className.contains("_UI"):
            return .moduleImage(named: "keyboardShortcut-32_Normal")

        case _ where !referenceView.originalSubviews.isEmpty:
            return .moduleImage(named: "filled-view-32_Normal")

        default:
            return .moduleImage(named: "EmptyView-32_Normal")
        }
    }
}
