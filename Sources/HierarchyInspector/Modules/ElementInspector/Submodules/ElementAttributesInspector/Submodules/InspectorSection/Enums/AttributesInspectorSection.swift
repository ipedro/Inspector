//
//  AttributesInspectorSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit
import MapKit

enum AttributesInspectorSection {
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
    
    var targetClass: AnyClass {
        switch self {
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
    
    func viewModel(with referenceView: UIView) -> AttributesInspectorSectionViewModelProtocol? {
        switch self {
            
        case .activityIndicator:
            return UIActivityIndicatorViewSectionViewModel(view: referenceView)
            
        case .button:
            return UIButtonSectionViewModel(view: referenceView)
            
        case .control:
            return UIControlSectionViewModel(view: referenceView)
            
        case .datePicker:
            return UIDatePickerSectionViewModel(view: referenceView)
            
        case .imageView:
            return UIImageViewSectionViewModel(view: referenceView)
            
        case .label:
            return UILabelSectionViewModel(view: referenceView)
            
        case .mapView:
            return MKMapViewSectionViewModel(view: referenceView)
            
        case .scrollView:
            return UIScrollViewSectionViewModel(view: referenceView)
            
        case .segmentedControl:
            return UISegmentedControlSectionViewModel(view: referenceView)
            
        case .slider:
            return UISliderSectionViewModel(view: referenceView)
            
        case .switch:
            return UISwitchSectionViewModel(view: referenceView)
            
        case .stackView:
            return UIStackViewSectionViewModel(view: referenceView)
            
        case .textField:
            return UITextFieldSectionViewModel(view: referenceView)
            
        case .textView:
            return UITextViewSectionViewModel(view: referenceView)
            
        case .view:
            return UIViewSectionViewModel(view: referenceView)
        }
        
    }
}

// MARK: - CaseIterable

extension AttributesInspectorSection: Swift.CaseIterable {
    
    static func allCases(matching object: NSObject) -> [AttributesInspectorSection] {
        allCases.matching(object)
    }
}

// MARK: - Array Extension

private extension Array where Element == AttributesInspectorSection {
    func matching(_ object: NSObject) -> Self {
        var subarray = [Element]()
        
        for anyClass in object.classesForCoder {
            
            for section in Element.allCases where section.targetClass == anyClass {
                
                subarray.append(section)
                
            }
            
        }
        
        return subarray
    }
}