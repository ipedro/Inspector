//
//  PropertyInspectorInputSection+UIStackViewSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

private enum UIStackViewProperty: CaseIterable {
    case axis
    case separator
    case alignment
    case distribution
    case spacing
    case isBaselineRelativeArrangement
}

extension PropertyInspectorInputSection {
    static func UIStackViewSection(stackView: UIStackView?) -> PropertyInspectorInputSection {
        PropertyInspectorInputSection(title: "Stack View", propertyInpus: UIStackViewProperty.allCases.compactMap {
            guard let stackView = stackView else {
                return nil
            }

            switch $0 {
            case .axis:
                return .inlineTextOptions(
                    title: "axis",
                    texts: NSLayoutConstraint.Axis.allCases,
                    selectedSegmentIndex: NSLayoutConstraint.Axis.allCases.firstIndex(of: stackView.axis)
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let axis = NSLayoutConstraint.Axis.allCases[newIndex]
                    
                    stackView.axis = axis
                }
            case .separator:
                return .separator
                
            case .alignment:
                return .optionsList(
                    title: "alignment",
                    options: UIStackView.Alignment.allCases,
                    selectedIndex: UIStackView.Alignment.allCases.firstIndex(of: stackView.alignment)
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let alignment = UIStackView.Alignment.allCases[newIndex]
                    
                    stackView.alignment = alignment
                }
                
            case .distribution:
                return .optionsList(
                    title: "distribution",
                    options: UIStackView.Distribution.allCases,
                    selectedIndex: UIStackView.Distribution.allCases.firstIndex(of: stackView.distribution)
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let distribution = UIStackView.Distribution.allCases[newIndex]
                    
                    stackView.distribution = distribution
                }
                
            case .spacing:
                return .cgFloatStepper(
                    title: "spacing",
                    value: stackView.spacing,
                    range: 0 ... .infinity,
                    stepValue: 1
                ) { spacing in
                    stackView.spacing = spacing
                }
            
            case .isBaselineRelativeArrangement:
                return .toggleButton(
                    title: "baseline relative",
                    isOn: stackView.isBaselineRelativeArrangement
                ) { isBaselineRelativeArrangement in
                    stackView.isBaselineRelativeArrangement = isBaselineRelativeArrangement
                }
            }
            
        })
    }
}
