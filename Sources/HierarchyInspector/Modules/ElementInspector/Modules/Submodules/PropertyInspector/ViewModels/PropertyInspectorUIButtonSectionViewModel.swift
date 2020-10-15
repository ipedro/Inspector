//
//  PropertyInspectorUIButtonSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorUIButtonSectionViewModel: PropertyInspectorSectionViewModelProtocol {
    
    enum Property: CaseIterable {
        case fontName
        case fontPointSize
        case titleText
        case currentTitleColor
        case currentTitleShadowColor
        case image
        case backgroundImage
        case isPointerInteractionEnabled
        case adjustsImageSizeForAccessibilityContentSizeCategory
        case groupDrawing
        case reversesTitleShadowWhenHighlighted
        case showsTouchWhenHighlighted
        case adjustsImageWhenHighlighted
        case adjustsImageWhenDisabled
    }
    
    private(set) weak var button: UIButton?
    
    init(button: UIButton) {
        self.button = button
    }
    
    private(set) lazy var title: String? = "Button"
    
    private(set) lazy var propertyInpus: [PropertyInspectorInput] = Property.allCases.compactMap {
        guard let button = button else {
            return nil
        }
        
        switch $0 {
        
        #warning("improve ")
        case .fontName:
            return .fontNamePicker(
                fontProvider: {
                    button.titleLabel?.font
                },
                handler: { font in
                    button.titleLabel?.font = font
                }
            )
            
        case .fontPointSize:
            return .fontSizeStepper(
                fontProvider: {
                    button.titleLabel?.font
                },
                handler: { font in
                    button.titleLabel?.font = font
                }
            )
        
        case .titleText:
            return .optionsList(
                title: "title",
                options: [button.title(for: button.state) ?? "–"],
                selectedIndex: 0,
                handler: nil
            )
        
        case .currentTitleColor:
            return .colorPicker(
                title: "text color",
                color: button.currentTitleColor
            ) { currentTitleColor in
                button.setTitleColor(currentTitleColor, for: button.state)
            }
        
        case .currentTitleShadowColor:
            return .colorPicker(
                title: "shadow color",
                color: button.currentTitleShadowColor
            ) { currentTitleShadowColor in
                button.setTitleShadowColor(currentTitleShadowColor, for: button.state)
            }
        
        #warning("finish button properties implementation")
        case .image:
            return nil
        
        #warning("finish button properties implementation")
        case .backgroundImage:
            return nil
        
        case .isPointerInteractionEnabled:
            #if swift(>=5.0)
            if #available(iOS 13.4, *) {
                return .toggleButton(
                    title: "pointer interaction enabled",
                    isOn: button.isPointerInteractionEnabled
                ) { isPointerInteractionEnabled in
                    button.isPointerInteractionEnabled = isPointerInteractionEnabled
                }
            }
            #endif
            return nil
         
        case .adjustsImageSizeForAccessibilityContentSizeCategory:
            return .toggleButton(
                title: "adjusts image size",
                isOn: button.adjustsImageSizeForAccessibilityContentSizeCategory
            ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                button.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
            }
            
        case .groupDrawing:
            return .subSection(name: "drawing")
            
        case .reversesTitleShadowWhenHighlighted:
            return .toggleButton(
                title: "reverses on highlight",
                isOn: button.reversesTitleShadowWhenHighlighted
            ) { reversesTitleShadowWhenHighlighted in
                button.reversesTitleShadowWhenHighlighted = reversesTitleShadowWhenHighlighted
            }
            
        case .showsTouchWhenHighlighted:
            return .toggleButton(
                title: "shows touch on highlight",
                isOn: button.showsTouchWhenHighlighted
            ) { showsTouchWhenHighlighted in
                button.showsTouchWhenHighlighted = showsTouchWhenHighlighted
            }
            
        case .adjustsImageWhenHighlighted:
            return .toggleButton(
                title: "highglighted adjusts image",
                isOn: button.adjustsImageWhenHighlighted
            ) { adjustsImageWhenHighlighted in
                button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted
            }
        
            
        case .adjustsImageWhenDisabled:
            return .toggleButton(
                title: "disabled adjusts image",
                isOn: button.adjustsImageWhenDisabled
            ) { adjustsImageWhenDisabled in
                button.adjustsImageWhenDisabled = adjustsImageWhenDisabled
            }
        
        }
        
    }
}
