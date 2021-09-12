//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

extension UIViewElementLibrary {
    final class UIStackViewInspectableViewModel: InspectorElementFormViewModelProtocol {
        enum Property: String, Swift.CaseIterable {
            case axis = "Axis"
            case alignment = "Alignment"
            case distribution = "Distribution"
            case spacing = "Spacing"
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
        
        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
            guard let stackView = stackView else {
                return nil
            }

            switch property {
            case .axis:
                return .textButtonGroup(
                    title: property.rawValue,
                    texts: NSLayoutConstraint.Axis.allCases.map(\.description),
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
                    options: UIStackView.Alignment.allCases.map(\.description),
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
                    options: UIStackView.Distribution.allCases.map(\.description),
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
