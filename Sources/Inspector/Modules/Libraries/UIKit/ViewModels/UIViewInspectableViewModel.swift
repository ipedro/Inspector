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
    final class UIViewInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Property: String, Swift.CaseIterable {
            case contentMode = "Content Mode"
            case semanticContentAttribute = "Semantic Content"
            case tag = "Tag"
            case accessibilityIdentifier = "Accessibility Identifier"
            case groupInteraction = "Interaction"
            case isUserInteractionEnabled = "User Interaction Enabled"
            case isMultipleTouchEnabled = "Multiple Touch Enabled"
            case groupAlphaAndColors = "Alpha And Colors"
            case alpha = "Alpha"
            case backgroundColor = "Background"
            case tintColor = "Tint"
            case groupDrawing = "Drawing"
            case isOpaque = "Opaque"
            case isHidden = "Hidden"
            case clearsContextBeforeDrawing = "Clears Graphic Context"
            case clipsToBounds = "Clips To Bounds"
            case autoresizesSubviews = "Autoresize Subviews"
        }
        
        let title = "View"
        
        private(set) weak var view: UIView?
        
        init?(view: UIView) {
            self.view = view
        }
        
        private(set) lazy var properties: [InspectorElementViewModelProperty] = Property.allCases.compactMap { property in
            guard let view = view else {
                return nil
            }

            switch property {
            case .contentMode:
                return .optionsList(
                    title: property.rawValue,
                    options: UIView.ContentMode.allCases.map(\.description),
                    selectedIndex: { UIView.ContentMode.allCases.firstIndex(of: view.contentMode) }
                ) {
                    guard let newIndex = $0 else { return }

                    let contentMode = UIView.ContentMode.allCases[newIndex]
                    
                    view.contentMode = contentMode
                }

            case .semanticContentAttribute:
                return .optionsList(
                    title: property.rawValue,
                    options: UISemanticContentAttribute.allCases.map(\.description),
                    selectedIndex: { UISemanticContentAttribute.allCases.firstIndex(of: view.semanticContentAttribute) }
                ) {
                    guard let newIndex = $0 else { return }
                    
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
                
            case .accessibilityIdentifier:
                return .textField(
                    title: property.rawValue,
                    placeholder: view.accessibilityIdentifier?.trimmed ?? property.rawValue,
                    value: { view.accessibilityIdentifier?.trimmed }
                ) { accessibilityIdentifier in
                    view.accessibilityIdentifier = accessibilityIdentifier?.trimmed
                    view.hightlightView?.updateElementName()
                }
                
            case .groupInteraction:
                return .group(title: property.rawValue)
                
            case .isUserInteractionEnabled:
                return .switch(
                    title: property.rawValue,
                    isOn: { view.hightlightView?.viewReference.isUserInteractionEnabled ?? view.isUserInteractionEnabled }
                ) { isUserInteractionEnabled in
                    guard let viewReference = view.hightlightView?.viewReference else {
                        view.isUserInteractionEnabled = isUserInteractionEnabled
                        return
                    }
                    
                    viewReference.isUserInteractionEnabled = isUserInteractionEnabled
                    view.hightlightView?.updateViews()
                }

            case .isMultipleTouchEnabled:
                return .switch(
                    title: property.rawValue,
                    isOn: { view.isMultipleTouchEnabled }
                ) { isMultipleTouchEnabled in
                    view.isMultipleTouchEnabled = isMultipleTouchEnabled
                }
            
            case .groupAlphaAndColors:
                return .separator
            
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
                return .switch(
                    title: property.rawValue,
                    isOn: { view.isOpaque }
                ) { isOpaque in
                    view.isOpaque = isOpaque
                }

            case .isHidden:
                return .switch(
                    title: property.rawValue,
                    isOn: { view.isHidden }
                ) { isHidden in
                    view.isHidden = isHidden
                }

            case .clearsContextBeforeDrawing:
                return .switch(
                    title: property.rawValue,
                    isOn: { view.clearsContextBeforeDrawing }
                ) { clearsContextBeforeDrawing in
                    view.clearsContextBeforeDrawing = clearsContextBeforeDrawing
                }

            case .clipsToBounds:
                return .switch(
                    title: property.rawValue,
                    isOn: { view.clipsToBounds }
                ) { clipsToBounds in
                    view.clipsToBounds = clipsToBounds
                }

            case .autoresizesSubviews:
                return .switch(
                    title: property.rawValue,
                    isOn: { view.autoresizesSubviews }
                ) { autoresizesSubviews in
                    view.autoresizesSubviews = autoresizesSubviews
                }
            }
        }
    }
}
