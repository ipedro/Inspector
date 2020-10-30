//
//  UIStackViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {
        
    final class UIStackViewSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, CaseIterable {
            case axis                          = "Axis"
            case alignment                     = "Alignment"
            case distribution                  = "Distribution"
            case spacing                       = "Spacing"
            case isBaselineRelativeArrangement = "Baseline Relative"
        }
        
        let title = "Stack View"
        
        private(set) weak var stackView: UIStackView?
        
        init?(view: UIView) {
            guard let stackView = view as? UIStackView else {
                return nil
            }
            
            self.stackView = stackView
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let stackView = stackView else {
                return nil
            }

            switch property {
            case .axis:
                return .segmentedControl(
                    title: property.rawValue,
                    options: NSLayoutConstraint.Axis.allCases,
                    axis: .horizontal,
                    selectedIndex: { NSLayoutConstraint.Axis.allCases.firstIndex(of: stackView.axis) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let axis = NSLayoutConstraint.Axis.allCases[newIndex]
                    
                    stackView.axis = axis
                }
                
            case .alignment:
                return .optionsList(
                    title: property.rawValue,
                    options: UIStackView.Alignment.allCases,
                    selectedIndex: { UIStackView.Alignment.allCases.firstIndex(of: stackView.alignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let alignment = UIStackView.Alignment.allCases[newIndex]
                    
                    stackView.alignment = alignment
                }
                
            case .distribution:
                return .optionsList(
                    title: property.rawValue,
                    options: UIStackView.Distribution.allCases,
                    selectedIndex: { UIStackView.Distribution.allCases.firstIndex(of: stackView.distribution) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let distribution = UIStackView.Distribution.allCases[newIndex]
                    
                    stackView.distribution = distribution
                }
                
            case .spacing:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { stackView.spacing },
                    range: { 0 ... .infinity },
                    stepValue: { 1 }
                ) { spacing in
                    stackView.spacing = spacing
                }
            
            case .isBaselineRelativeArrangement:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { stackView.isBaselineRelativeArrangement }
                ) { isBaselineRelativeArrangement in
                    stackView.isBaselineRelativeArrangement = isBaselineRelativeArrangement
                }
            }
        }
    }

}
