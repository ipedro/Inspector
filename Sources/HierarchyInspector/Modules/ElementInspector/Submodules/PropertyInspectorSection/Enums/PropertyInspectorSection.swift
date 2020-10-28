//
//  PropertyInspectorSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 28.10.20.
//

import UIKit

enum PropertyInspectorSection {
    case activityIndicator
    case button
    case control
    case imageView
    case label
    case slider
    case stackView
    case `switch`
    case view
    
    var targetClass: AnyClass {
        switch self {
        case .activityIndicator:
            return UIActivityIndicatorView.self
            
        case .button:
            return UIButton.self
            
        case .control:
            return UIControl.self
            
        case .imageView:
            return UIImageView.self
            
        case .label:
            return UILabel.self
            
        case .slider:
            return UISlider.self
            
        case .stackView:
            return UIStackView.self
            
        case .switch:
            return UISwitch.self
            
        case .view:
            return UIView.self
        }
    }
    
    func viewModel(with referenceView: UIView) -> PropertyInspectorSectionViewModelProtocol? {
        switch self {
            
        case .activityIndicator:
            return UIActivityIndicatorViewSectionViewModel(view: referenceView)
            
        case .button:
            return UIButtonSectionViewModel(view: referenceView)
            
        case .control:
            return UIControlSectionViewModel(view: referenceView)
            
        case .imageView:
            return UIImageViewSectionViewModel(view: referenceView)
            
        case .label:
            return UILabelSectionViewModel(view: referenceView)
            
        case .slider:
            return UISliderSectionViewModel(view: referenceView)
            
        case .stackView:
            return UIStackViewSectionViewModel(view: referenceView)
            
        case .switch:
            return UISwitchSectionViewModel(view: referenceView)
            
        case .view:
            return UIViewSectionViewModel(view: referenceView)
        }
    }
}

// MARK: - CaseIterable

extension PropertyInspectorSection: CaseIterable {
    
    static func allCases(matching object: NSObject) -> [PropertyInspectorSection] {
        allCases.matching(object)
    }
}

// MARK: - Array Extension

private extension Array where Element == PropertyInspectorSection {
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
