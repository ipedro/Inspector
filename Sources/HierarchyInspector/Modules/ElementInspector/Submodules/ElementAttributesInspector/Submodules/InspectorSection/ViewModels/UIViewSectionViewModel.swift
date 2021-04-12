//
//  UIViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension UIKitComponents {
    
    final class UIViewInspectableViewModel: HiearchyInspectableElementViewModelProtocol {
        
        enum Property: String, Swift.CaseIterable {
            case contentMode                = "Content Mode"
            case semanticContentAttribute   = "Semantic Content"
            case tag                        = "Tag"
            case groupInteraction           = "Interaction"
            case isUserInteractionEnabled   = "User Interaction Enabled"
            case isMultipleTouchEnabled     = "Multiple Touch Enabled"
            case groupAlphaAndColors        = "Alpha And Colors"
            case alpha                      = "Alpha"
            case backgroundColor            = "Background"
            case tintColor                  = "Tint"
            case groupDrawing               = "Drawing"
            case isOpaque                   = "Opaque"
            case isHidden                   = "Hidden"
            case clearsContextBeforeDrawing = "Clears Graphic Context"
            case clipsToBounds              = "Clips To Bounds"
            case autoresizesSubviews        = "Autoresize Subviews"
        }
        
        let title = "View"
        
        private(set) weak var view: UIView?
        
        init?(view: UIView) {
            self.view = view
        }
        
        private(set) lazy var properties: [HiearchyInspectableElementProperty] = Property.allCases.compactMap { property in
            guard let view = view else {
                return nil
            }

            switch property {
            case .contentMode:
                return .optionsList(
                    title: property.rawValue,
                    options: UIView.ContentMode.allCases.map { $0.description },
                    selectedIndex: { UIView.ContentMode.allCases.firstIndex(of: view.contentMode) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }

                    let contentMode = UIView.ContentMode.allCases[newIndex]
                    
                    view.contentMode = contentMode
                }

            case .semanticContentAttribute:
                return .optionsList(
                    title: property.rawValue,
                    options: UISemanticContentAttribute.allCases.map { $0.description },
                    selectedIndex: { UISemanticContentAttribute.allCases.firstIndex(of: view.semanticContentAttribute) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let semanticContentAttribute = UISemanticContentAttribute.allCases[newIndex]

                    view.semanticContentAttribute = semanticContentAttribute
                }

            case .tag:
                return .integerStepper(
                    title: property.rawValue,
                    value: { view.tag },
                    range: { 0...100 },
                    stepValue: { 1 }
                ) { newValue in
                    view.tag = newValue
                }

            case .groupInteraction:
                return .group(title: property.rawValue)
                
            case .isUserInteractionEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.isUserInteractionEnabled }
                ) { isUserInteractionEnabled in
                    view.isUserInteractionEnabled = isUserInteractionEnabled
                }

            case .isMultipleTouchEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.isMultipleTouchEnabled }
                ) { isMultipleTouchEnabled in
                    view.isMultipleTouchEnabled = isMultipleTouchEnabled
                }
            
            case .groupAlphaAndColors:
                return .separator(title: property.rawValue)
            
            case .alpha:
                return .cgFloatStepper(
                    title: property.rawValue,
                    value: { view.alpha },
                    range: { 0...1 },
                    stepValue: { 0.05 }
                ) { alpha in
                    view.alpha = alpha
                }

            case .backgroundColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { view.backgroundColor }
                ) { backgroundColor in
                    view.backgroundColor = backgroundColor
                }

            case .tintColor:
                return .colorPicker(
                    title: property.rawValue,
                    color: { view.tintColor }
                ) { tintColor in
                    view.tintColor = tintColor
                }
                
            case .groupDrawing:
                return .group(title: property.rawValue)
                
            case .isOpaque:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.isOpaque }
                ) { isOpaque in
                    view.isOpaque = isOpaque
                }

            case .isHidden:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.isHidden }
                ) { isHidden in
                    view.isHidden = isHidden
                }

            case .clearsContextBeforeDrawing:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.clearsContextBeforeDrawing }
                ) { clearsContextBeforeDrawing in
                    view.clearsContextBeforeDrawing = clearsContextBeforeDrawing
                }

            case .clipsToBounds:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.clipsToBounds }
                ) { clipsToBounds in
                    view.clipsToBounds = clipsToBounds
                }

            case .autoresizesSubviews:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { view.autoresizesSubviews }
                ) { autoresizesSubviews in
                    view.autoresizesSubviews = autoresizesSubviews
                }
            }
            
        }
    }

}
