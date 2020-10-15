//
//  PropertyInspectorUIControlSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorUIControlSectionViewModel: PropertyInspectorSectionViewModelProtocol {
    
    private enum Property: CaseIterable {
        case contentHorizontalAlignment
        case contentVerticalAlignment
        case groupState
        case isSelected
        case isEnabled
        case isHighlighted
    }
    
    private(set) weak var control: UIControl?
    
    init(control: UIControl) {
        self.control = control
    }
    
    private(set) lazy var title: String? = "Control"
    
    private(set) lazy var propertyInpus: [PropertyInspectorInput] = Property.allCases.compactMap {
        guard let control = control else {
            return nil
        }

        switch $0 {
        case .contentHorizontalAlignment:
            let knownCases = UIControl.ContentHorizontalAlignment.allCases.filter { $0.image?.withRenderingMode(.alwaysTemplate) != nil }

            return .inlineImageOptions(
                title: "horizontal alignment",
                images: knownCases.compactMap { $0.image },
                selectedSegmentIndex: knownCases.firstIndex(of: control.contentHorizontalAlignment)
            ) {
                guard let newIndex = $0 else {
                    return
                }

                let contentHorizontalAlignment = knownCases[newIndex]

                control.contentHorizontalAlignment = contentHorizontalAlignment
            }

        case .contentVerticalAlignment:
            let knownCases = UIControl.ContentVerticalAlignment.allCases.filter { $0.image?.withRenderingMode(.alwaysTemplate) != nil }

            return .inlineImageOptions(
                title: "vertical alignment",
                images: knownCases.compactMap { $0.image },
                selectedSegmentIndex: knownCases.firstIndex(of: control.contentVerticalAlignment)
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

    }
}
