//
//  UIButtonSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension AttributesInspectorSection {
    
    final class UIButtonSectionViewModel: AttributesInspectorSectionViewModelProtocol {
        
        enum Property: String, CaseIterable {
            case fontName                                            = "Font Name"
            case fontPointSize                                       = "Font Point Size"
            case titleText                                           = "Title"
            case currentTitleColor                                   = "Text Color"
            case currentTitleShadowColor                             = "Shadow Color"
            case image                                               = "Image"
            case backgroundImage                                     = "Background Image"
            case isPointerInteractionEnabled                         = "Pointer Interaction Enabled"
            case adjustsImageSizeForAccessibilityContentSizeCategory = "Adjusts Image Size"
            case groupDrawing                                        = "Drawing"
            case reversesTitleShadowWhenHighlighted                  = "Reverses On Highlight"
            case showsTouchWhenHighlighted                           = "Shows Touch On Highlight"
            case adjustsImageWhenHighlighted                         = "Highlighted Adjusts Image"
            case adjustsImageWhenDisabled                            = "Disabled Adjusts Image"
        }
        
        let title = "Button"
        
        private(set) weak var button: UIButton?
        
        init?(view: UIView) {
            guard let button = view as? UIButton else {
                return nil
            }
            
            self.button = button
        }
        
        private(set) lazy var properties: [AttributesInspectorSectionProperty] = Property.allCases.compactMap { property in
            guard let button = button else {
                return nil
            }
            
            switch property {
            
            case .fontName:
                return .fontNamePicker(
                    title: property.rawValue,
                    fontProvider: {
                        button.titleLabel?.font
                    },
                    handler: { font in
                        button.titleLabel?.font = font
                    }
                )
                
            case .fontPointSize:
                return .fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: {
                        button.titleLabel?.font
                    },
                    handler: { font in
                        button.titleLabel?.font = font
                    }
                )
            
            case .titleText:
                return .textInput(
                    title: property.rawValue,
                    value: { button.title(for: button.state) },
                    placeholder: { button.title(for: button.state) ?? property.rawValue }
                ) { title in
                    button.setTitle(title, for: button.state)
                }
                
            case .currentTitleColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { button.currentTitleColor }
                ) { currentTitleColor in
                    button.setTitleColor(currentTitleColor, for: button.state)
                }
            
            case .currentTitleShadowColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { button.currentTitleShadowColor }
                ) { currentTitleShadowColor in
                    button.setTitleShadowColor(currentTitleShadowColor, for: button.state)
                }
            
            case .image:
                return .imagePicker(
                    title: property.rawValue,
                    image: { button.image(for: button.state) }
                ) { image in
                    button.setImage(image, for: button.state)
                }
            
            case .backgroundImage:
                return .imagePicker(
                    title: property.rawValue,
                    image: { button.backgroundImage(for: button.state) }
                ) { backgroundImage in
                    button.setBackgroundImage(backgroundImage, for: button.state)
                }
            
            case .isPointerInteractionEnabled:
                #if swift(>=5.0)
                if #available(iOS 13.4, *) {
                    return .toggleButton(
                        title: property.rawValue,
                        isOn: { button.isPointerInteractionEnabled }
                    ) { isPointerInteractionEnabled in
                        button.isPointerInteractionEnabled = isPointerInteractionEnabled
                    }
                }
                #endif
                return nil
             
            case .adjustsImageSizeForAccessibilityContentSizeCategory:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { button.adjustsImageSizeForAccessibilityContentSizeCategory }
                ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                    button.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
                }
                
            case .groupDrawing:
                return .group(title: property.rawValue)
                
            case .reversesTitleShadowWhenHighlighted:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { button.reversesTitleShadowWhenHighlighted }
                ) { reversesTitleShadowWhenHighlighted in
                    button.reversesTitleShadowWhenHighlighted = reversesTitleShadowWhenHighlighted
                }
                
            case .showsTouchWhenHighlighted:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { button.showsTouchWhenHighlighted }
                ) { showsTouchWhenHighlighted in
                    button.showsTouchWhenHighlighted = showsTouchWhenHighlighted
                }
                
            case .adjustsImageWhenHighlighted:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { button.adjustsImageWhenHighlighted }
                ) { adjustsImageWhenHighlighted in
                    button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted
                }
            
                
            case .adjustsImageWhenDisabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { button.adjustsImageWhenDisabled }
                ) { adjustsImageWhenDisabled in
                    button.adjustsImageWhenDisabled = adjustsImageWhenDisabled
                }
            
            }
            
        }
    }
    
}
