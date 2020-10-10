//
//  PropertyInspectorInputSection+UIControlSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

private enum UIControlProperty: CaseIterable {
    case contentHorizontalAlignment
    case contentVerticalAlignment
    case isSelected
    case isEnabled
    case isHighlighted
}

extension PropertyInspectorInputSection {
    static func UIControlSection(control: UIControl?) -> PropertyInspectorInputSection {
        PropertyInspectorInputSection(title: "Control", propertyInpus: UIControlProperty.allCases.compactMap {
            guard let control = control else {
                return nil
            }

            switch $0 {
            case .contentHorizontalAlignment:
                return .segmentedControl(
                    title: "horizontal alignment",
                    items: UIControl.ContentHorizontalAlignment.allCases,
                    selectedSegmentIndex: UIControl.ContentHorizontalAlignment.allCases.firstIndex(of: control.contentHorizontalAlignment)
                ) { newValue in
                    guard
                        let value = newValue,
                        let contentHorizontalAlignment = UIControl.ContentHorizontalAlignment(rawValue: value)
                    else {
                        return
                    }

                    control.contentHorizontalAlignment = contentHorizontalAlignment
                }
                
            case .contentVerticalAlignment:
                return .segmentedControl(
                    title: "vertical alignment",
                    items: UIControl.ContentVerticalAlignment.allCases,
                    selectedSegmentIndex: UIControl.ContentVerticalAlignment.allCases.firstIndex(of: control.contentVerticalAlignment)
                ) { newValue in
                    guard
                        let value = newValue,
                        let contentVerticalAlignment = UIControl.ContentVerticalAlignment(rawValue: value)
                    else {
                        return
                    }

                    control.contentVerticalAlignment = contentVerticalAlignment
                }
                
            case .isSelected:
                return .toggleButton(
                    title: "selected",
                    isOn: control.isSelected
                ) { newValue in
                    control.isSelected = newValue
                }
                
            case .isEnabled:
                return .toggleButton(
                    title: "enabled",
                    isOn: control.isEnabled
                ) { newValue in
                    control.isEnabled = newValue
                }
                
            case .isHighlighted:
                return .toggleButton(
                    title: "highlighted",
                    isOn: control.isHighlighted
                ) { newValue in
                    control.isHighlighted = newValue
                }
                
            }
            
        })
    }
}

extension UIControl.ContentVerticalAlignment: CaseIterable {
    public typealias AllCases = [UIControl.ContentVerticalAlignment]
    
    public static var allCases: [UIControl.ContentVerticalAlignment] {
        [
            .center,
            .top,
            .bottom,
            .fill
        ]
    }
}

extension UIControl.ContentVerticalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .center:
            return "center"
            
        case .top:
            return "top"
            
        case .bottom:
            return "bottom"
            
        case .fill:
            return "fill"
            
        @unknown default:
            return String(describing: self)
        }
    }
}

extension UIControl.ContentHorizontalAlignment: CaseIterable {
    public typealias AllCases = [UIControl.ContentHorizontalAlignment]
    
    public static var allCases: [UIControl.ContentHorizontalAlignment] {
        [
            .leading,
            .left,
            .center,
            .trailing,
            .right,
            .fill
        ]
    }
}

extension UIControl.ContentHorizontalAlignment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .leading:
            return "|L]"
            
        case .left:
            return "| ]"
            
        case .center:
            return "[|]"
            
        case .right:
            return "[ |"
            
        case .trailing:
            return "[T|"
            
        case .fill:
            return "[⟷]"
            
        @unknown default:
            return String(describing: self)
        }
    }
}
