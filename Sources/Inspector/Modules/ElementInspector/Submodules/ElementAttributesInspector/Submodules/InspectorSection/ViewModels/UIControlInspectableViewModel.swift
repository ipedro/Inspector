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

    final class UIControlInspectableViewModel: ElementInspectorFormViewModelProtocol {
        
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
        
        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
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
