//
//  UIControlSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {

    final class UIControlSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        private enum Property: CaseIterable {
            case contentHorizontalAlignment
            case contentVerticalAlignment
            case groupState
            case isSelected
            case isEnabled
            case isHighlighted
        }
        
        private(set) weak var control: UIControl?
        
        init?(view: UIView) {
            guard let control = view as? UIControl else {
                return nil
            }
            
            self.control = control
        }
        
        let title = "Control"
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap {
            guard let control = control else {
                return nil
            }

            switch $0 {
            case .contentHorizontalAlignment:
                return .segmentedControl(
                    title: "horizontal alignment",
                    options: UIControl.ContentHorizontalAlignment.allCases,
                    selectedIndex: { UIControl.ContentHorizontalAlignment.allCases.firstIndex(of: control.contentHorizontalAlignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }

                    let contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.allCases[newIndex]

                    control.contentHorizontalAlignment = contentHorizontalAlignment
                }

            case .contentVerticalAlignment:
                let knownCases = UIControl.ContentVerticalAlignment.allCases.filter { $0.image?.withRenderingMode(.alwaysTemplate) != nil }

                return .segmentedControl(
                    title: "vertical alignment",
                    options: knownCases.compactMap { $0.image },
                    selectedIndex: { knownCases.firstIndex(of: control.contentVerticalAlignment) }
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
                    isOn: { control.isSelected }
                ) { isSelected in
                    control.isSelected = isSelected
                }

            case .isEnabled:
                return .toggleButton(
                    title: "enabled",
                    isOn: { control.isEnabled }
                ) { isEnabled in
                    control.isEnabled = isEnabled
                }

            case .isHighlighted:
                return .toggleButton(
                    title: "highlighted",
                    isOn: { control.isHighlighted }
                ) { isHighlighted in
                    control.isHighlighted = isHighlighted
                }
            }

        }
    }
    
}
