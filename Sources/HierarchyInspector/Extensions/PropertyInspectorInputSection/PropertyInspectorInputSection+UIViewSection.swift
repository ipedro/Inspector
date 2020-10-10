//
//  PropertyInspectorInputSection+UIViewSection.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 10.10.20.
//

import UIKit

private enum UIViewProperty: CaseIterable {
    case contentMode
    case semanticContentAttribute
    case tag
    case isUserInteractionEnabled
    case isMultipleTouchEnabled
    case alpha
    case backgroundColor
    case tintColor
    case isOpaque
    case isHidden
    case clearsContextBeforeDrawing
    case clipsToBounds
    case autoresizesSubviews
}

extension PropertyInspectorInputSection {
    static func UIViewSection(view: UIView?) -> PropertyInspectorInputSection {
        PropertyInspectorInputSection(title: "View", propertyInpus: UIViewProperty.allCases.compactMap {
            guard let view = view else {
                return nil
            }

            switch $0 {
            case .contentMode:
                return .optionSelector(
                    title: "content mode",
                    options: UIView.ContentMode.allCases,
                    selectedIndex: UIView.ContentMode.allCases.firstIndex(of: view.contentMode)
                ) { newValue in
                    guard
                        let value = newValue,
                        let contentMode = UIView.ContentMode(rawValue: value)
                    else {
                        return
                    }

                    view.contentMode = contentMode
                }

            case .semanticContentAttribute:
                return .optionSelector(
                    title: "semantic content",
                    options: UISemanticContentAttribute.allCases,
                    selectedIndex: UISemanticContentAttribute.allCases.firstIndex(of: view.semanticContentAttribute)
                ) { newValue in
                    guard
                        let value = newValue,
                        let semanticContentAttribute = UISemanticContentAttribute(rawValue: value)
                    else {
                        return
                    }

                    view.semanticContentAttribute = semanticContentAttribute
                }

            case .tag:
                return .integerStepper(
                    title: "tag",
                    value: view.tag,
                    range: 0...100,
                    stepValue: 1
                ) { newValue in
                    view.tag = newValue
                }

            case .isUserInteractionEnabled:
                return .toggleButton(
                    title: "user interaction enabled",
                    isOn: view.isUserInteractionEnabled
                ) { newValue in
                    view.isUserInteractionEnabled = newValue
                }

            case .isMultipleTouchEnabled:
                return .toggleButton(
                    title: "multiple touch",
                    isOn: view.isMultipleTouchEnabled
                ) { newValue in
                    view.isMultipleTouchEnabled = newValue
                }

            case .alpha:
                return .doubleStepper(
                    title: "alpha",
                    value: Double(view.alpha),
                    range: 0...1,
                    stepValue: 0.05
                ) { newValue in
                    view.alpha = CGFloat(newValue)
                }

            case .backgroundColor:
                return .colorPicker(
                    title: "background",
                    color: view.backgroundColor
                ) { newValue in
                    view.backgroundColor = newValue
                }

            case .tintColor:
                return .colorPicker(
                    title: "tint",
                    color: view.tintColor
                ) { newValue in
                    view.tintColor = newValue
                }

            case .isOpaque:
                return .toggleButton(
                    title: "opaque",
                    isOn: view.isOpaque
                ) { newValue in
                    view.isOpaque = newValue
                }

            case .isHidden:
                return .toggleButton(
                    title: "hidden",
                    isOn: view.isHidden
                ) { newValue in
                    view.isHidden = newValue
                }

            case .clearsContextBeforeDrawing:
                return .toggleButton(
                    title: "clears graphic context",
                    isOn: view.clearsContextBeforeDrawing
                ) { newValue in
                    view.clearsContextBeforeDrawing = newValue
                }

            case .clipsToBounds:
                return .toggleButton(
                    title: "clips to bounds",
                    isOn: view.clipsToBounds
                ) { newValue in
                    view.clipsToBounds = newValue
                }

            case .autoresizesSubviews:
                return .toggleButton(
                    title: "autoresize subviews",
                    isOn: view.autoresizesSubviews
                ) { newValue in
                    view.autoresizesSubviews = newValue
                }
            }
            
        })
    }
}
