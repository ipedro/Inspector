//
//  UIControlSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIKitComponents {

    final class UIControlInspectableViewModel: HierarchyInspectableElementViewModelProtocol {
        
        private enum Property: String, Swift.CaseIterable {
            case contentHorizontalAlignment = "Horizontal Alignment"
            case contentVerticalAlignment   = "Vertical Alignment"
            case groupState                 = "State"
            case isSelected                 = "Selected"
            case isEnabled                  = "Enabled"
            case isHighlighted              = "Highlighted"
        }
        
        let title = "Control"
        
        private(set) weak var control: UIControl?
        
        init?(view: UIView) {
            guard let control = view as? UIControl else {
                return nil
            }
            
            self.control = control
        }
        
        private(set) lazy var properties: [HiearchyInspectableElementProperty] = Property.allCases.compactMap { property in
            guard let control = control else {
                return nil
            }

            switch property {
            case .contentHorizontalAlignment:
                let allCases = UIControl.ContentHorizontalAlignment.allCases.withImages
                
                return .imageButtonGroup(
                    title: property.rawValue,
                    images: allCases.compactMap { $0.image },
                    selectedIndex: { allCases.firstIndex(of: control.contentHorizontalAlignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }

                    let contentHorizontalAlignment = allCases[newIndex]
                    
                    control.contentHorizontalAlignment = contentHorizontalAlignment
                }

            case .contentVerticalAlignment:
                let knownCases = UIControl.ContentVerticalAlignment.allCases.filter { $0.image?.withRenderingMode(.alwaysTemplate) != nil }

                return .imageButtonGroup(
                    title: property.rawValue,
                    images: knownCases.compactMap { $0.image },
                    selectedIndex: { knownCases.firstIndex(of: control.contentVerticalAlignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }

                    let contentVerticalAlignment = UIControl.ContentVerticalAlignment.allCases[newIndex]

                    control.contentVerticalAlignment = contentVerticalAlignment
                }

            case .groupState:
                return .group(title: property.rawValue)

            case .isSelected:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { control.isSelected }
                ) { isSelected in
                    control.isSelected = isSelected
                }

            case .isEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { control.isEnabled }
                ) { isEnabled in
                    control.isEnabled = isEnabled
                }

            case .isHighlighted:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { control.isHighlighted }
                ) { isHighlighted in
                    control.isHighlighted = isHighlighted
                }
            }

        }
    }
    
}
