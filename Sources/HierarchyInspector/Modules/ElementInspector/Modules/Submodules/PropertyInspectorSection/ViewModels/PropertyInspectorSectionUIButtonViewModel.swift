//
//  PropertyInspectorSectionUIButtonViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

final class PropertyInspectorSectionUIButtonViewModel: PropertyInspectorSectionViewModelProtocol {
    
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
    
    let title = "Button"
    
    private(set) lazy var properties: [PropertyInspectorSectionProperty] = Property.allCases.compactMap {
        guard let button = button else {
            return nil
        }
        
        switch $0 {
        
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
            return .textInput(
                title: "title",
                value: button.title(for: button.state),
                placeholder: button.title(for: button.state) ?? "Title"
            ) { title in
                button.setTitle(title, for: button.state)
            }
            
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
        
        case .image:
            return .imagePicker(
                title: "image",
                image: button.image(for: button.state)
            ) { image in
                button.setImage(image, for: button.state)
            }
        
        case .backgroundImage:
            return .imagePicker(
                title: "background image",
                image: button.backgroundImage(for: button.state)
            ) { backgroundImage in
                button.setBackgroundImage(backgroundImage, for: button.state)
            }
        
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
