//
//  PropertyInspectorInputSection+UIControlSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

private enum UIControlProperty: CaseIterable {
    case groupAlignment
    case contentHorizontalAlignment
    case contentVerticalAlignment
    case groupState
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
            case .groupAlignment:
                return .subSection(name: "alignment")
                
            case .contentHorizontalAlignment:
                return .inlineOptions(
                    title: "horizontal alignment",
                    items: UIControl.ContentHorizontalAlignment.allCases,
                    selectedSegmentIndex: UIControl.ContentHorizontalAlignment.allCases.firstIndex(of: control.contentHorizontalAlignment)
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.allCases[newIndex]

                    control.contentHorizontalAlignment = contentHorizontalAlignment
                }
                
            case .contentVerticalAlignment:
                return .inlineOptions(
                    title: "vertical alignment",
                    items: UIControl.ContentVerticalAlignment.allCases,
                    selectedSegmentIndex: UIControl.ContentVerticalAlignment.allCases.firstIndex(of: control.contentVerticalAlignment)
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let contentVerticalAlignment = UIControl.ContentVerticalAlignment.allCases[newIndex]
                    
                    control.contentVerticalAlignment = contentVerticalAlignment
                }
                
            case .groupState:
                return .subSection(name: "state")
                
            case .isSelected:
                return .toggleButton(
                    title: "selected",
                    isOn: control.isSelected
                ) { isSelected in
                    control.isSelected = isSelected
                }
                
            case .isEnabled:
                return .toggleButton(
                    title: "enabled",
                    isOn: control.isEnabled
                ) { isEnabled in
                    control.isEnabled = isEnabled
                }
                
            case .isHighlighted:
                return .toggleButton(
                    title: "highlighted",
                    isOn: control.isHighlighted
                ) { isHighlighted in
                    control.isHighlighted = isHighlighted
                }
            }
            
        })
    }
}
