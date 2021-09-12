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

enum UIViewElementLibrary: Swift.CaseIterable {
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
    case navigationBar
    case oldWebview
    case webView
    
    static var standard: AllCases {
        Self.allCases
    }
}

// MARK: - HierarchyInspectorElementLibraryProtocol

extension UIViewElementLibrary: InspectorElementLibraryProtocol {
    var targetClass: AnyClass {
        switch self {
        case .navigationBar:
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
            
        case .oldWebview:
            return UIWebView.self
            
        case .webView:
            return WKWebView.self
        }
    }
    
    func viewModel(for referenceView: UIView) -> InspectorElementFormViewModelProtocol? {
        switch self {
        case .window,
             .navigationBar:
            return nil
            
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
            
        case .oldWebview:
            return nil
            
        case .webView:
            return nil
        }
    }
    
    func icon(for referenceView: UIView) -> UIImage? {
        switch self {
        case .navigationBar:
            return .moduleImage(named: "NavigationBar-32_Normal")
            
        case .window:
            return .moduleImage(named: "UIWindow-32_Normal")
            
        case .activityIndicator:
            return .moduleImage(named: "UIActivityIndicator_32_Dark_Normal")
            
        case .button:
            return .moduleImage(named: "UIButton_32-Dark_Normal")
            
        case .datePicker:
            return .moduleImage(named: "UIDatePicker_32_Normal")
            
        case .imageView:
            guard let image = (referenceView as? UIImageView)?.image else {
                return .moduleImage(named: "UIImageView-32_Normal")
            }
            return image
            
        case .label:
            return .moduleImage(named: "UILabel_32-Dark_Normal")
            
        case .scrollView:
            return .moduleImage(named: "UIScrollView_32_Normal")
            
        case .segmentedControl:
            return .moduleImage(named: "UISegmentedControl_32_Normal")
            
        case .switch:
            return .moduleImage(named: "Toggle-32_Normal")
            
        case .stackView:
            guard (referenceView as? UIStackView)?.axis == .horizontal else {
                return .moduleImage(named: "VStack-32_Normal")
            }
            return .moduleImage(named: "HStack-32_Normal")
            
        case .textField:
            return .moduleImage(named: "TextField-32_Normal")
            
        case .textView:
            return .moduleImage(named: "TextView-32_Normal")
            
        case .control:
            return .moduleImage(named: "UIControl-32_Normal")
            
        case .oldWebview,
             .webView:
            return .moduleImage(named: "Webview-32_Normal")
            
        case .mapView,
             .slider,
             .view:
            return nil
        }
    }
}
