//
//  UIViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

extension PropertyInspectorSection {
    
    final class UIViewSectionViewModel: PropertyInspectorSectionViewModelProtocol {
        
        enum Property: CaseIterable {
            case contentMode
            case semanticContentAttribute
            case tag
            case groupInteraction
            case isUserInteractionEnabled
            case isMultipleTouchEnabled
            case groupAlphaAndColors
            case alpha
            case backgroundColor
            case tintColor
            case groupDrawing
            case isOpaque
            case isHidden
            case clearsContextBeforeDrawing
            case clipsToBounds
            case autoresizesSubviews
        }
        
        private(set) weak var view: UIView?
        
        init?(view: UIView) {
            self.view = view
        }
        
        let title = "View"
        
        private(set) lazy var properties: [PropertyInspectorSectionProperty] = Property.allCases.compactMap {
            guard let view = view else {
                return nil
            }

            switch $0 {
            case .contentMode:
                return .optionsList(
                    title: "content mode",
                    options: UIView.ContentMode.allCases,
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
                    title: "semantic content",
                    options: UISemanticContentAttribute.allCases,
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
                    title: "tag",
                    value: { view.tag },
                    range: { 0...100 },
                    stepValue: { 1 }
                ) { newValue in
                    view.tag = newValue
                }

            case .groupInteraction:
                return .subSection(name: "Interaction")
                
            case .isUserInteractionEnabled:
                return .toggleButton(
                    title: "user interaction enabled",
                    isOn: { view.isUserInteractionEnabled }
                ) { isUserInteractionEnabled in
                    view.isUserInteractionEnabled = isUserInteractionEnabled
                }

            case .isMultipleTouchEnabled:
                return .toggleButton(
                    title: "multiple touch",
                    isOn: { view.isMultipleTouchEnabled }
                ) { isMultipleTouchEnabled in
                    view.isMultipleTouchEnabled = isMultipleTouchEnabled
                }
            
            case .groupAlphaAndColors:
                return .separator
            
            case .alpha:
                return .cgFloatStepper(
                    title: "alpha",
                    value: { view.alpha },
                    range: { 0...1 },
                    stepValue: { 0.05 }
                ) { alpha in
                    view.alpha = alpha
                }

            case .backgroundColor:
                return .colorPicker(
                    title: "background",
                    color: { view.backgroundColor }
                ) { backgroundColor in
                    view.backgroundColor = backgroundColor
                }

            case .tintColor:
                return .colorPicker(
                    title: "tint",
                    color: { view.tintColor }
                ) { tintColor in
                    view.tintColor = tintColor
                }
                
            case .groupDrawing:
                return .subSection(name: "drawing")
                
            case .isOpaque:
                return .toggleButton(
                    title: "opaque",
                    isOn: { view.isOpaque }
                ) { isOpaque in
                    view.isOpaque = isOpaque
                }

            case .isHidden:
                return .toggleButton(
                    title: "hidden",
                    isOn: { view.isHidden }
                ) { isHidden in
                    view.isHidden = isHidden
                }

            case .clearsContextBeforeDrawing:
                return .toggleButton(
                    title: "clears graphic context",
                    isOn: { view.clearsContextBeforeDrawing }
                ) { clearsContextBeforeDrawing in
                    view.clearsContextBeforeDrawing = clearsContextBeforeDrawing
                }

            case .clipsToBounds:
                return .toggleButton(
                    title: "clips to bounds",
                    isOn: { view.clipsToBounds }
                ) { clipsToBounds in
                    view.clipsToBounds = clipsToBounds
                }

            case .autoresizesSubviews:
                return .toggleButton(
                    title: "autoresize subviews",
                    isOn: { view.autoresizesSubviews }
                ) { autoresizesSubviews in
                    view.autoresizesSubviews = autoresizesSubviews
                }
            }
            
        }
    }

}
