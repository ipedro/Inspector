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

@available(iOS 26.0, *)
extension DefaultElementAttributesLibrary {
    final class ButtonConfigurationAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed
        let title = "Button Configuration"

        private weak var button: UIButton?

        init?(with object: NSObject) {
            guard let button = object as? UIButton, button.configuration != nil else { return nil }
            self.button = button
        }

        private enum Property: String, Swift.CaseIterable {
            case backgroundEffect = "Background Effect"
            case baseForegroundColor = "Base Foreground"
            case baseBackgroundColor = "Base Background"
            case glassInteractive = "Glass Interactive"
            case glassTintColor = "Glass Tint Color"
            case cornerStyle = "Corner Style"
            case buttonSize = "Button Size"
            case titleAlignment = "Title Alignment"
            case imagePlacement = "Image Placement"
            case imagePadding = "Image Padding"
            case titlePadding = "Title Padding"
            case showsActivityIndicator = "Shows Activity Indicator"
            case automaticallyUpdateForSelection = "Auto-update For Selection"
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
            case .backgroundEffect:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: InspectorVisualEffectKind.appearanceCases.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                    read: { .selection(button.configuration.flatMap { InspectorVisualEffectKind.current(for: $0.background.visualEffect) }.flatMap(InspectorVisualEffectKind.appearanceCases.firstIndex(of:))) },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index, var configuration = button.configuration else { return }
                        configuration.background.visualEffect = InspectorVisualEffectKind.appearanceCases[index].makeEffect()
                        button.configuration = configuration
                    }
                )
            case .baseForegroundColor:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(button.configuration?.baseForegroundColor) },
                    write: { newValue in
                        guard case let .color(value) = newValue, var configuration = button.configuration else { return }
                        configuration.baseForegroundColor = value
                        button.configuration = configuration
                    }
                )
            case .baseBackgroundColor:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color(button.configuration?.baseBackgroundColor) },
                    write: { newValue in
                        guard case let .color(value) = newValue, var configuration = button.configuration else { return }
                        configuration.baseBackgroundColor = value
                        button.configuration = configuration
                    }
                )
            case .glassInteractive:
                guard button.configuration?.background.visualEffect is UIGlassEffect else { return nil }
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                    read: { .bool((button.configuration?.background.visualEffect as? UIGlassEffect)?.isInteractive ?? false) },
                    write: { newValue in
                        guard case let .bool(value) = newValue, var configuration = button.configuration, let currentGlass = configuration.background.visualEffect as? UIGlassEffect else { return }
                        let updated = UIGlassEffect(style: currentGlass.resolvedStyle)
                        updated.tintColor = currentGlass.tintColor
                        updated.isInteractive = value
                        configuration.background.visualEffect = updated
                        button.configuration = configuration
                    }
                )
            case .glassTintColor:
                guard button.configuration?.background.visualEffect is UIGlassEffect else { return nil }
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .color, value: .color(allowsNil: true), editability: .editable),
                    read: { .color((button.configuration?.background.visualEffect as? UIGlassEffect)?.tintColor) },
                    write: { newValue in
                        guard case let .color(value) = newValue, var configuration = button.configuration, let currentGlass = configuration.background.visualEffect as? UIGlassEffect else { return }
                        let updated = UIGlassEffect(style: currentGlass.resolvedStyle)
                        updated.isInteractive = currentGlass.isInteractive
                        updated.tintColor = value
                        configuration.background.visualEffect = updated
                        button.configuration = configuration
                    }
                )
            case .cornerStyle:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: ButtonConfigurationCornerStyleOption.all.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                    read: {
                        guard let configuration = button.configuration else { return .selection(nil) }
                        return .selection(ButtonConfigurationCornerStyleOption.all.firstIndex(where: { $0.value == configuration.cornerStyle }))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index, var configuration = button.configuration else { return }
                        configuration.cornerStyle = ButtonConfigurationCornerStyleOption.all[index].value
                        button.configuration = configuration
                    }
                )
            case .buttonSize:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: ButtonConfigurationSizeOption.all.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                    read: {
                        guard let configuration = button.configuration else { return .selection(nil) }
                        return .selection(ButtonConfigurationSizeOption.all.firstIndex(where: { $0.value == configuration.buttonSize }))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index, var configuration = button.configuration else { return }
                        configuration.buttonSize = ButtonConfigurationSizeOption.all[index].value
                        button.configuration = configuration
                    }
                )
            case .titleAlignment:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: ButtonConfigurationTitleAlignmentOption.all.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                    read: {
                        guard let configuration = button.configuration else { return .selection(nil) }
                        return .selection(ButtonConfigurationTitleAlignmentOption.all.firstIndex(where: { $0.value == configuration.titleAlignment }))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index, var configuration = button.configuration else { return }
                        configuration.titleAlignment = ButtonConfigurationTitleAlignmentOption.all[index].value
                        button.configuration = configuration
                    }
                )
            case .imagePlacement:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .options, value: .selection(.init(options: ButtonConfigurationImagePlacementOption.all.enumerated().map { .init(id: "\($0.offset)", title: $0.element.description) }, allowsNil: true)), editability: .editable),
                    read: {
                        guard let configuration = button.configuration else { return .selection(nil) }
                        return .selection(ButtonConfigurationImagePlacementOption.all.firstIndex(where: { $0.value == configuration.imagePlacement }))
                    },
                    write: { newValue in
                        guard case let .selection(index) = newValue, let index, var configuration = button.configuration else { return }
                        configuration.imagePlacement = ButtonConfigurationImagePlacementOption.all[index].value
                        button.configuration = configuration
                    }
                )
            case .imagePadding:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, step: 1, isDecimal: true)), editability: .editable),
                    read: { .number(Double(button.configuration?.imagePadding ?? 0)) },
                    write: { newValue in
                        guard case let .number(value) = newValue, var configuration = button.configuration else { return }
                        configuration.imagePadding = CGFloat(value)
                        button.configuration = configuration
                    }
                )
            case .titlePadding:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .stepper, value: .number(.init(min: 0, step: 1, isDecimal: true)), editability: .editable),
                    read: { .number(Double(button.configuration?.titlePadding ?? 0)) },
                    write: { newValue in
                        guard case let .number(value) = newValue, var configuration = button.configuration else { return }
                        configuration.titlePadding = CGFloat(value)
                        button.configuration = configuration
                    }
                )
            case .showsActivityIndicator:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                    read: { .bool(button.configuration?.showsActivityIndicator ?? false) },
                    write: { newValue in
                        guard case let .bool(value) = newValue, var configuration = button.configuration else { return }
                        configuration.showsActivityIndicator = value
                        button.configuration = configuration
                    }
                )
            case .automaticallyUpdateForSelection:
                return .init(
                    descriptor: .init(id: id, title: property.rawValue, kind: .toggle, value: .bool, editability: .editable),
                    read: { .bool(button.configuration?.automaticallyUpdateForSelection ?? false) },
                    write: { newValue in
                        guard case let .bool(value) = newValue, var configuration = button.configuration else { return }
                        configuration.automaticallyUpdateForSelection = value
                        button.configuration = configuration
                    }
                )
            }
        }
    }
}

@available(iOS 26.0, *)
private struct ButtonConfigurationCornerStyleOption: CustomStringConvertible {
    let value: UIButton.Configuration.CornerStyle
    let description: String

    static let all: [ButtonConfigurationCornerStyleOption] = [
        .init(value: .fixed, description: "Fixed"),
        .init(value: .dynamic, description: "Dynamic"),
        .init(value: .small, description: "Small"),
        .init(value: .medium, description: "Medium"),
        .init(value: .large, description: "Large"),
        .init(value: .capsule, description: "Capsule")
    ]
}

@available(iOS 26.0, *)
private struct ButtonConfigurationSizeOption: CustomStringConvertible {
    let value: UIButton.Configuration.Size
    let description: String

    static let all: [ButtonConfigurationSizeOption] = [
        .init(value: .medium, description: "Medium"),
        .init(value: .small, description: "Small"),
        .init(value: .mini, description: "Mini"),
        .init(value: .large, description: "Large")
    ]
}

@available(iOS 26.0, *)
private struct ButtonConfigurationTitleAlignmentOption: CustomStringConvertible {
    let value: UIButton.Configuration.TitleAlignment
    let description: String

    static let all: [ButtonConfigurationTitleAlignmentOption] = [
        .init(value: .automatic, description: "Automatic"),
        .init(value: .leading, description: "Leading"),
        .init(value: .center, description: "Center"),
        .init(value: .trailing, description: "Trailing")
    ]
}

@available(iOS 26.0, *)
private struct ButtonConfigurationImagePlacementOption: CustomStringConvertible {
    let value: NSDirectionalRectEdge
    let description: String

    static let all: [ButtonConfigurationImagePlacementOption] = [
        .init(value: .leading, description: "Leading"),
        .init(value: .trailing, description: "Trailing"),
        .init(value: .top, description: "Top"),
        .init(value: .bottom, description: "Bottom")
    ]
}
