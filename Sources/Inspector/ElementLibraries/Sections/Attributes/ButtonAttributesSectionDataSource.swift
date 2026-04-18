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

import InspectorContract
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
            switch property {
            case .type:
                return .init(
                    descriptor: .init(
                        id: "type",
                        title: property.rawValue,
                        kind: .options,
                        value: .selection(.init(options: UIButton.ButtonType.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                        editability: .readOnly
                    ),
                    read: { .selection(UIButton.ButtonType.allCases.firstIndex(of: button.buttonType)) },
                    write: nil,
                    refreshHint: .none
                )
            case .fontName:
                return .init(
                    descriptor: .init(
                        id: "font-name",
                        title: property.rawValue,
                        kind: .options,
                        value: .selection(.init(options: FontReference.allCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                        editability: .editable,
                        presentation: .init(axis: .vertical)
                    ),
                    read: {
                        let fontName = button.titleLabel?.font.fontName ?? UIFont.systemFont(ofSize: UIFont.systemFontSize).fontName
                        return .selection(FontReference.firstIndex(of: fontName))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue,
                              let index,
                              let font = FontReference.font(at: index, size: button.titleLabel?.font.pointSize ?? UIFont.systemFontSize) else { return }
                        button.titleLabel?.font = font
                    },
                    runtimePresentation: .init(selectionOptionIcons: FontReference.allCases.map(\.icon))
                )
            case .fontPointSize:
                return .init(
                    descriptor: .init(
                        id: "font-point-size",
                        title: property.rawValue,
                        kind: .stepper,
                        value: .number(.init(min: 0, max: 256, step: 1, isDecimal: true)),
                        editability: .editable
                    ),
                    read: { .number(Double(button.titleLabel?.font.pointSize ?? UIFont.systemFontSize)) },
                    write: { newValue in
                        guard case let .number(value) = newValue else { return }
                        guard let font = button.titleLabel?.font.withSize(CGFloat(value)) else { return }
                        button.titleLabel?.font = font
                    }
                )
            case .groupState, .groupDrawing:
                return .init(
                    descriptor: .init(id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(), title: property.rawValue, kind: .group, value: .none, editability: .readOnly),
                    read: { .none },
                    write: nil,
                    refreshHint: .none
                )
            case .stateConfig:
                return .init(
                    descriptor: .init(
                        id: "state-config",
                        title: property.rawValue,
                        kind: .options,
                        value: .selection(.init(options: UIControl.State.configurableButtonStates.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)),
                        editability: .editable
                    ),
                    read: { .selection(UIControl.State.configurableButtonStates.firstIndex(of: self.selectedControlState)) },
                    write: { [weak self] newValue in
                        guard case let .selection(index) = newValue, let index else { return }
                        self?.selectedControlState = UIControl.State.configurableButtonStates[index]
                    }
                )
            case .titleText:
                return .init(
                    descriptor: .init(id: "title-text", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: button.title(for: selectedControlState) ?? property.rawValue, allowsNil: true)), editability: .editable),
                    read: { .string(button.title(for: self.selectedControlState)) },
                    write: { newValue in
                        guard case let .string(title) = newValue else { return }
                        button.setTitle(title, for: self.selectedControlState)
                    }
                )
            case .currentTitleColor:
                return .init(
                    descriptor: .init(id: "current-title-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(button.titleColor(for: self.selectedControlState)) },
                    write: { newValue in
                        guard case let .color(color) = newValue else { return }
                        button.setTitleColor(color, for: self.selectedControlState)
                    }
                )
            case .currentTitleShadowColor:
                return .init(
                    descriptor: .init(id: "current-title-shadow-color", title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(button.titleShadowColor(for: self.selectedControlState)) },
                    write: { newValue in
                        guard case let .color(color) = newValue else { return }
                        button.setTitleShadowColor(color, for: self.selectedControlState)
                    }
                )
            case .image:
                return .init(
                    descriptor: .init(id: "image", title: property.rawValue, kind: .preview, value: .none, editability: .editable),
                    read: { .image(button.image(for: self.selectedControlState)) },
                    write: { newValue in
                        guard case let .image(image) = newValue else { return }
                        button.setImage(image, for: self.selectedControlState)
                    }
                )
            case .backgroundImage:
                return .init(
                    descriptor: .init(id: "background-image", title: property.rawValue, kind: .preview, value: .none, editability: .editable),
                    read: { .image(button.backgroundImage(for: self.selectedControlState)) },
                    write: { newValue in
                        guard case let .image(image) = newValue else { return }
                        button.setBackgroundImage(image, for: self.selectedControlState)
                    }
                )
            case .isPointerInteractionEnabled:
                return .init(descriptor: .init(id: "is-pointer-interaction-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(button.isPointerInteractionEnabled) }, write: { newValue in guard case let .bool(value) = newValue else { return }; button.isPointerInteractionEnabled = value })
            case .adjustsImageSizeForAccessibilityContentSizeCategory:
                return .init(descriptor: .init(id: "adjusts-image-size-for-accessibility-content-size-category", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(button.adjustsImageSizeForAccessibilityContentSizeCategory) }, write: { newValue in guard case let .bool(value) = newValue else { return }; button.adjustsImageSizeForAccessibilityContentSizeCategory = value })
            case .reversesTitleShadowWhenHighlighted:
                return .init(descriptor: .init(id: "reverses-title-shadow-when-highlighted", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(button.reversesTitleShadowWhenHighlighted) }, write: { newValue in guard case let .bool(value) = newValue else { return }; button.reversesTitleShadowWhenHighlighted = value })
            case .showsTouchWhenHighlighted:
                return .init(descriptor: .init(id: "shows-touch-when-highlighted", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(button.showsTouchWhenHighlighted) }, write: { newValue in guard case let .bool(value) = newValue else { return }; button.showsTouchWhenHighlighted = value })
            case .adjustsImageWhenHighlighted:
                return .init(descriptor: .init(id: "adjusts-image-when-highlighted", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(button.adjustsImageWhenHighlighted) }, write: { newValue in guard case let .bool(value) = newValue else { return }; button.adjustsImageWhenHighlighted = value })
            case .adjustsImageWhenDisabled:
                return .init(descriptor: .init(id: "adjusts-image-when-disabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(button.adjustsImageWhenDisabled) }, write: { newValue in guard case let .bool(value) = newValue else { return }; button.adjustsImageWhenDisabled = value })
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
