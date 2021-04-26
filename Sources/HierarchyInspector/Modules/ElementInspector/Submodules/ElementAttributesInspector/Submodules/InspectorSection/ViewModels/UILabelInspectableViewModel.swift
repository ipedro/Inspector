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

extension UIKitElementLibrary {
        
    final class UILabelInspectableViewModel: HierarchyInspectorElementViewModelProtocol {
        
        enum Property: String, Swift.CaseIterable {
            case text                                 = "Text"
            case textColor                            = "Text Color"
            case fontName                             = "Font Name"
            case fontSize                             = "Font Size"
            case adjustsFontSizeToFitWidth            = "Automatically Adjusts Font"
            case textAlignment                        = "Alignment"
            case numberOfLines                        = "Lines"
            case groupBehavior                        = "Behavior"
            case isEnabled                            = "Enabled"
            case isHighlighted                        = "Highlighted"
            case separator0                           = "Separator0"
            case baseline                             = "Baseline"
            case lineBreak                            = "Line Break"
            case autoShrink                           = "Auto Shrink"
            case allowsDefaultTighteningForTruncation = "Tighten Letter Spacing"
            case separator1                           = "Separator1"
            case highlightedTextColor                 = "Highlighted Color"
            case shadowColor                          = "Shadow"
        }
        
        let title = "Label"
        
        private(set) weak var label: UILabel?
        
        init?(view: UIView) {
            guard let label = view as? UILabel else {
                return nil
            }
            
            self.label = label
        }
        
        private(set) lazy var properties: [HiearchyInspectableElementProperty] = Property.allCases.compactMap { property in
            guard let label = label else {
                return nil
            }

            switch property {
            
            case .text:
                let originalText = label.text
                
                return .textView(
                    title: property.rawValue,
                    placeholder: { originalText },
                    value: { label.text }
                ) { text in
                    label.text = text
                }
                
            case .textColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { label.textColor }
                ) { textColor in
                    label.textColor = textColor
                }
                
            case .fontName:
                return .fontNamePicker(
                    title: property.rawValue,
                    fontProvider: { label.font }
                ) { font in
                    guard let font = font else {
                        return
                    }
                    
                    label.font = font
                }
                
            case .fontSize:
                return .fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: { label.font }
                ) { font in
                    guard let font = font else {
                        return
                    }
                    
                    label.font = font
                }
                
            case .adjustsFontSizeToFitWidth:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { label.adjustsFontSizeToFitWidth }
                ) { adjustsFontSizeToFitWidth in
                    label.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
                }
                
            case .textAlignment:
                let allCases = NSTextAlignment.allCases.withImages
                
                return .imageButtonGroup(
                    title: property.rawValue,
                    images: allCases.compactMap { $0.image },
                    selectedIndex: { allCases.firstIndex(of: label.textAlignment) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let textAlignment = allCases[newIndex]
                    
                    label.textAlignment = textAlignment
                }
                
            case .numberOfLines:
                return .integerStepper(
                    title: property.rawValue,
                    value: { label.numberOfLines },
                    range: { 0...100 },
                    stepValue: { 1 }
                ) { numberOfLines in
                    label.numberOfLines = numberOfLines
                }
                
            case .groupBehavior:
                return .group(title: property.rawValue)
                
            case .isEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { label.isEnabled }
                ) { isEnabled in
                    label.isEnabled = isEnabled
                }
            
            case .isHighlighted:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { label.isHighlighted }
                ) { isHighlighted in
                    label.isHighlighted = isHighlighted
                }
                
            case .separator0,
                 .separator1:
                return .separator(title: property.rawValue)
                
            case .baseline:
                return nil
                
            case .lineBreak:
                return nil
                
            case .autoShrink:
                return nil
                
            case .allowsDefaultTighteningForTruncation:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { label.allowsDefaultTighteningForTruncation }
                ) { allowsDefaultTighteningForTruncation in
                    label.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
                }
                
            case .highlightedTextColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { label.highlightedTextColor }
                ) { highlightedTextColor in
                    label.highlightedTextColor = highlightedTextColor
                }
                
            case .shadowColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { label.shadowColor }
                ) { shadowColor in
                    label.shadowColor = shadowColor
                }
                
            }
            
        }
    }
    
}
