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

extension DefaultElementAttributesLibrary {
    final class ButtonAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Button"

        private weak var button: UIButton?

        init?(with object: NSObject) {
            guard let button = object as? UIButton else { return nil }

            self.button = button
            selectedControlState = button.state
        }

        private var selectedControlState: UIControl.State

        private enum Property: String, Swift.CaseIterable {
            case type = "Type"
            case fontName = "Font Name"
            case fontPointSize = "Font Point Size"
            case groupState = "State"
            case stateConfig = "State Config"
            case titleText = "Title"
            case currentTitleColor = "Text Color"
            case currentTitleShadowColor = "Shadow Color"
            case image = "Image"
            case backgroundImage = "Background Image"
            case isPointerInteractionEnabled = "Pointer Interaction Enabled"
            case adjustsImageSizeForAccessibilityContentSizeCategory = "Adjusts Image Size"
            case groupDrawing = "Drawing"
            case reversesTitleShadowWhenHighlighted = "Reverses On Highlight"
            case showsTouchWhenHighlighted = "Shows Touch On Highlight"
            case adjustsImageWhenHighlighted = "Highlighted Adjusts Image"
            case adjustsImageWhenDisabled = "Disabled Adjusts Image"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let button else { return [] }

            return Property.allCases.compactMap { property in
                binding(for: property, button: button)
            }
        }

        private func binding(for property: Property, button: UIButton) -> InspectorPropertyBinding? {
            let id = property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased()
            switch property {
            case .type:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIButton.ButtonType.allCases.map(\.description),
                    selectedIndex: { UIButton.ButtonType.allCases.firstIndex(of: button.buttonType) },
                    handler: nil
                ).makeBinding(id: id)
            case .fontName:
                return InspectorElementProperty.fontNamePicker(
                    title: property.rawValue,
                    fontProvider: { button.titleLabel?.font }
                ) { font in
                    button.titleLabel?.font = font
                }.makeBinding(id: id)
            case .fontPointSize:
                return InspectorElementProperty.fontSizeStepper(
                    title: property.rawValue,
                    fontProvider: { button.titleLabel?.font }
                ) { font in
                    button.titleLabel?.font = font
                }.makeBinding(id: id)
            case .groupState, .groupDrawing:
                return InspectorElementProperty.group(title: property.rawValue).makeBinding(id: id)
            case .stateConfig:
                return InspectorElementProperty.optionsList(
                    title: property.rawValue,
                    options: UIControl.State.configurableButtonStates.map(\.description),
                    selectedIndex: { UIControl.State.configurableButtonStates.firstIndex(of: self.selectedControlState) }
                ) { [weak self] in
                    guard let newIndex = $0 else { return }
                    self?.selectedControlState = UIControl.State.configurableButtonStates[newIndex]
                }.makeBinding(id: id)
            case .titleText:
                return InspectorElementProperty.textField(
                    title: property.rawValue,
                    placeholder: button.title(for: selectedControlState) ?? property.rawValue,
                    value: { button.title(for: self.selectedControlState) }
                ) { title in
                    button.setTitle(title, for: self.selectedControlState)
                }.makeBinding(id: id)
            case .currentTitleColor:
                return InspectorElementProperty.colorPicker(
                    title: property.rawValue,
                    color: { button.titleColor(for: self.selectedControlState) }
                ) { currentTitleColor in
                    button.setTitleColor(currentTitleColor, for: self.selectedControlState)
                }.makeBinding(id: id)
            case .currentTitleShadowColor:
                return InspectorElementProperty.colorPicker(
                    title: property.rawValue,
                    color: { button.titleShadowColor(for: self.selectedControlState) }
                ) { currentTitleShadowColor in
                    button.setTitleShadowColor(currentTitleShadowColor, for: self.selectedControlState)
                }.makeBinding(id: id)
            case .image:
                return InspectorElementProperty.imagePicker(
                    title: property.rawValue,
                    image: { button.image(for: self.selectedControlState) }
                ) { image in
                    button.setImage(image, for: self.selectedControlState)
                }.makeBinding(id: id)
            case .backgroundImage:
                return InspectorElementProperty.imagePicker(
                    title: property.rawValue,
                    image: { button.backgroundImage(for: self.selectedControlState) }
                ) { backgroundImage in
                    button.setBackgroundImage(backgroundImage, for: self.selectedControlState)
                }.makeBinding(id: id)
            case .isPointerInteractionEnabled:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { button.isPointerInteractionEnabled }
                ) { isPointerInteractionEnabled in
                    button.isPointerInteractionEnabled = isPointerInteractionEnabled
                }.makeBinding(id: id)
            case .adjustsImageSizeForAccessibilityContentSizeCategory:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { button.adjustsImageSizeForAccessibilityContentSizeCategory }
                ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                    button.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
                }.makeBinding(id: id)
            case .reversesTitleShadowWhenHighlighted:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { button.reversesTitleShadowWhenHighlighted }
                ) { reversesTitleShadowWhenHighlighted in
                    button.reversesTitleShadowWhenHighlighted = reversesTitleShadowWhenHighlighted
                }.makeBinding(id: id)
            case .showsTouchWhenHighlighted:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { button.showsTouchWhenHighlighted }
                ) { showsTouchWhenHighlighted in
                    button.showsTouchWhenHighlighted = showsTouchWhenHighlighted
                }.makeBinding(id: id)
            case .adjustsImageWhenHighlighted:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { button.adjustsImageWhenHighlighted }
                ) { adjustsImageWhenHighlighted in
                    button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted
                }.makeBinding(id: id)
            case .adjustsImageWhenDisabled:
                return InspectorElementProperty.switch(
                    title: property.rawValue,
                    isOn: { button.adjustsImageWhenDisabled }
                ) { adjustsImageWhenDisabled in
                    button.adjustsImageWhenDisabled = adjustsImageWhenDisabled
                }.makeBinding(id: id)
            }
        }
    }
}

private extension UIControl.State {
    static let configurableButtonStates: [UIControl.State] = [
        .normal,
        .highlighted,
        .selected,
        .disabled
    ]
}
