//
//  UIStackViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension PropertyInspectorSection {
        
    final class UIStackViewSectionViewModel: PropertyInspectorSectionViewModelProtocol {
        
        enum Property: CaseIterable {
            case axis
            case alignment
            case distribution
            case spacing
            case isBaselineRelativeArrangement
        }
        
        private(set) weak var stackView: UIStackView?
        
        init?(view: UIView) {
            guard let stackView = view as? UIStackView else {
                return nil
            }
            
            self.stackView = stackView
        }
        
        let title = "Stack View"
        
        private(set) lazy var properties: [PropertyInspectorSectionProperty] = Property.allCases.compactMap {
            guard let stackView = stackView else {
                return nil
            }

            switch $0 {
            case .axis:
                return .segmentedControl(
                    title: "axis",
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
                    title: "alignment",
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
                    title: "distribution",
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
                    title: "spacing",
                    value: { stackView.spacing },
                    range: { 0 ... .infinity },
                    stepValue: { 1 }
                ) { spacing in
                    stackView.spacing = spacing
                }
            
            case .isBaselineRelativeArrangement:
                return .toggleButton(
                    title: "baseline relative",
                    isOn: { stackView.isBaselineRelativeArrangement }
                ) { isBaselineRelativeArrangement in
                    stackView.isBaselineRelativeArrangement = isBaselineRelativeArrangement
                }
            }
        }
    }

}
