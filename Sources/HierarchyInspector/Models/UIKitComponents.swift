//
//  UIKitComponents.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit
import MapKit

enum UIKitComponents: Swift.CaseIterable {
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
    
    static var standard: AllCases {
        Self.allCases
    }
}

// MARK: - HierarchyInspectableElementProtocol

extension UIKitComponents: HierarchyInspectableElementProtocol {
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
        }
    }
    
    func viewModel(with referenceView: UIView) -> HierarchyInspectableElementViewModelProtocol? {
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
        }
        
    }
    
    func icon(with referenceView: UIView) -> UIImage? {
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
            
        case .mapView,
             .slider,
             .view:
            return nil
        }
    }
}