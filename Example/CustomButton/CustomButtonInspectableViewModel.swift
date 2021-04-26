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
import HierarchyInspector

final class CustomButtonInspectableViewModel: HierarchyInspectorElementViewModelProtocol {
    var title: String = "Custom Button"
    
    let customButton: CustomButton
    
    init?(view: UIView) {
        guard let customButton = view as? CustomButton else {
            return nil
        }
        self.customButton = customButton
    }
    
    enum Properties: String, CaseIterable {
        case animateOnTouch = "Animate On Touch"
        case cornerRadius = "Round Corners"
        case backgroundColor = "Background Color"
    }
    
    var properties: [HiearchyInspectableElementProperty] {
        Properties.allCases.map { property in
            switch property {
            case .animateOnTouch:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { self.customButton.animateOnTouch }
                ) { animateOnTouch in
                    self.customButton.animateOnTouch = animateOnTouch
                }
                
            case .cornerRadius:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { self.customButton.roundCorners }
                ) { roundCorners in
                    self.customButton.roundCorners = roundCorners
                }
                
            case .backgroundColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { self.customButton.backgroundColor }
                ) { newBackgroundColor in
                    
                    self.customButton.backgroundColor = newBackgroundColor
                }
            }
            
        }
    }
}
