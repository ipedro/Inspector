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

        var properties: [InspectorElementProperty] {
            guard let button = button else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .type:
                    return .optionsList(
                        title: property.rawValue,
                        options: UIButton.ButtonType.allCases.map(\.description),
                        selectedIndex: { UIButton.ButtonType.allCases.firstIndex(of: button.buttonType) },
                        handler: nil
                    )
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
                case .groupState, .groupDrawing:
                    return .group(title: property.rawValue)

                case .stateConfig:
                    return .optionsList(
                        title: property.rawValue,
                        options: UIControl.State.configurableButtonStates.map(\.description),
                        selectedIndex: { UIControl.State.configurableButtonStates.firstIndex(of: self.selectedControlState) }
                    ) { [weak self] in

                        guard let newIndex = $0 else { return }

                        let selectedStateConfig = UIControl.State.configurableButtonStates[newIndex]

                        self?.selectedControlState = selectedStateConfig
                    }
                case .titleText:
                    return .textField(
                        title: property.rawValue,
                        placeholder: button.title(for: self.selectedControlState) ?? property.rawValue,
                        value: { button.title(for: self.selectedControlState) }
                    ) { title in
                        button.setTitle(title, for: self.selectedControlState)
                    }
                case .currentTitleColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { button.titleColor(for: self.selectedControlState) }
                    ) { currentTitleColor in
                        button.setTitleColor(currentTitleColor, for: self.selectedControlState)
                    }
                case .currentTitleShadowColor:
                    return .colorPicker(
                        title: property.rawValue,
                        color: { button.titleShadowColor(for: self.selectedControlState) }
                    ) { currentTitleShadowColor in
                        button.setTitleShadowColor(currentTitleShadowColor, for: self.selectedControlState)
                    }
                case .image:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { button.image(for: self.selectedControlState) }
                    ) { image in
                        button.setImage(image, for: self.selectedControlState)
                    }

                case .backgroundImage:
                    return .imagePicker(
                        title: property.rawValue,
                        image: { button.backgroundImage(for: self.selectedControlState) }
                    ) { backgroundImage in
                        button.setBackgroundImage(backgroundImage, for: self.selectedControlState)
                    }
                case .isPointerInteractionEnabled:
                    return .switch(
                        title: property.rawValue,
                        isOn: { button.isPointerInteractionEnabled }
                    ) { isPointerInteractionEnabled in
                        button.isPointerInteractionEnabled = isPointerInteractionEnabled
                    }
                case .adjustsImageSizeForAccessibilityContentSizeCategory:
                    return .switch(
                        title: property.rawValue,
                        isOn: { button.adjustsImageSizeForAccessibilityContentSizeCategory }
                    ) { adjustsImageSizeForAccessibilityContentSizeCategory in
                        button.adjustsImageSizeForAccessibilityContentSizeCategory = adjustsImageSizeForAccessibilityContentSizeCategory
                    }
                case .reversesTitleShadowWhenHighlighted:
                    return .switch(
                        title: property.rawValue,
                        isOn: { button.reversesTitleShadowWhenHighlighted }
                    ) { reversesTitleShadowWhenHighlighted in
                        button.reversesTitleShadowWhenHighlighted = reversesTitleShadowWhenHighlighted
                    }
                case .showsTouchWhenHighlighted:
                    return .switch(
                        title: property.rawValue,
                        isOn: { button.showsTouchWhenHighlighted }
                    ) { showsTouchWhenHighlighted in
                        button.showsTouchWhenHighlighted = showsTouchWhenHighlighted
                    }
                case .adjustsImageWhenHighlighted:
                    return .switch(
                        title: property.rawValue,
                        isOn: { button.adjustsImageWhenHighlighted }
                    ) { adjustsImageWhenHighlighted in
                        button.adjustsImageWhenHighlighted = adjustsImageWhenHighlighted
                    }
                case .adjustsImageWhenDisabled:
                    return .switch(
                        title: property.rawValue,
                        isOn: { button.adjustsImageWhenDisabled }
                    ) { adjustsImageWhenDisabled in
                        button.adjustsImageWhenDisabled = adjustsImageWhenDisabled
                    }
                }
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
