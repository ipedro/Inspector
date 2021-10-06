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

enum ElementInspectorAttributesLibrary: Swift.CaseIterable, InspectorElementLibraryProtocol {
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

    // MARK: - InspectorElementLibraryProtocol

    var targetClass: AnyClass {
        switch self {
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
        case .coreAnimationLayer:
            return CALayerAttributesViewModel(view: referenceView)

        case .window:
            return UIWindowAttributesViewModel(view: referenceView)

        case .navigationBar:
            return UINavigationBarAttributesViewModel(view: referenceView)

        case .navigationBarStandardAppearance:
            guard #available(iOS 13.0, *) else { return nil }
            return UINavigationBarAppearanceAttributesViewModel(type: .standard, view: referenceView)

        case .navigationBarCompactAppearance:
            guard #available(iOS 13.0, *) else { return nil }
            return UINavigationBarAppearanceAttributesViewModel(type: .compact, view: referenceView)

        case .navigationBarScrollEdgeAppearance:
            guard #available(iOS 13.0, *) else { return nil }
            return UINavigationBarAppearanceAttributesViewModel(type: .scrollEdge, view: referenceView)

        case .navigationBarCompactScrollEdgeAppearance:
            #if swift(>=5.5)
            guard #available(iOS 15.0, *) else { return nil }
            return UINavigationBarAppearanceAttributesViewModel(type: .compactScrollEdge, view: referenceView)
            #else
            return nil
            #endif

        case .activityIndicator:
            return UIActivityIndicatorViewAttributesViewModel(view: referenceView)

        case .button:
            return UIButtonAttributesViewModel(view: referenceView)

        case .control:
            return UIControlAttributesViewModel(view: referenceView)

        case .datePicker:
            return UIDatePickerAttributesViewModel(view: referenceView)

        case .imageView:
            return UIImageViewAttributesViewModel(view: referenceView)

        case .label:
            return UILabelAttributesViewModel(view: referenceView)

        case .mapView:
            return MKMapViewAttributesViewModel(view: referenceView)

        case .scrollView:
            return UIScrollViewAttributesViewModel(view: referenceView)

        case .segmentedControl:
            return UISegmentedControlAttributesViewModel(view: referenceView)

        case .slider:
            return UISliderAttributesViewModel(view: referenceView)

        case .switch:
            return UISwitchAttributesViewModel(view: referenceView)

        case .stackView:
            return UIStackViewAttributesViewModel(view: referenceView)

        case .textField:
            return UITextFieldAttributesViewModel(view: referenceView)

        case .textView:
            return UITextViewAttributesViewModel(view: referenceView)

        case .view:
            return UIViewAttributesViewModel(view: referenceView)

        case .tabBar:
            return UITabBarAttributesViewModel(view: referenceView)

        case .webView:
            return nil
        }
    }
}
