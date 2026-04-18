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
    final class KeyCommandsSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .expanded

        let title: String

        var subtitle: String?

        private weak var keyCommand: UIKeyCommand?

        var customClass: InspectorElementSectionView.Type? {
            InspectorElementKeyCommandSectionView.self
        }

        init?(with object: NSObject) {
            guard let keyCommand = object as? UIKeyCommand else {
                return nil
            }

            if keyCommand.title.isEmpty {
                subtitle = keyCommand.discoverabilityTitle ?? keyCommand.action?.description
            }
            else {
                subtitle = keyCommand.title
            }

            title = keyCommand.symbols ?? "Key Command"

            self.keyCommand = keyCommand
        }

        private enum Property: String, Swift.CaseIterable {
            case title = "Title"
            case discoverabilityTitle = "Discoverability Title"
            case image = "Image"
            case separator
            case key = "Keys"
            case selector = "Selector"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let keyCommand else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .separator:
                    return .init(
                        descriptor: .init(id: "separator", title: "", kind: .separator, value: .none, editability: .readOnly),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .discoverabilityTitle:
                    return .init(
                        descriptor: .init(id: "discoverability-title", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: nil, allowsNil: true)), editability: .readOnly, presentation: .init(axis: .vertical)),
                        read: { .string(keyCommand.discoverabilityTitle) },
                        write: nil,
                        refreshHint: .none
                    )
                case .image:
                    return .init(
                        descriptor: .init(id: "image", title: property.rawValue, kind: .preview, value: .none, editability: .readOnly),
                        read: { .image(keyCommand.image) },
                        write: nil,
                        refreshHint: .none
                    )
                case .key:
                    return .init(
                        descriptor: .init(id: "key", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: nil, allowsNil: true)), editability: .readOnly, presentation: .init(axis: .vertical)),
                        read: { .string(keyCommand.symbols) },
                        write: nil,
                        refreshHint: .none
                    )
                case .title:
                    return .init(
                        descriptor: .init(id: "title", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: nil, allowsNil: false)), editability: .readOnly, presentation: .init(axis: .vertical)),
                        read: { .string(keyCommand.title) },
                        write: nil,
                        refreshHint: .none
                    )
                case .selector:
                    return .init(
                        descriptor: .init(id: "selector", title: property.rawValue, kind: .textField, value: .string(.init(multiline: false, placeholder: nil, allowsNil: true)), editability: .readOnly, presentation: .init(axis: .vertical)),
                        read: { .string(keyCommand.action?.description) },
                        write: nil,
                        refreshHint: .none
                    )
                }
            }
        }
    }
}

extension UIKeyCommand {
    var symbols: String? {
        let keys = (modifierFlags.symbols + [input?.localizedUppercase]).compactMap { $0 }
        return keys.isEmpty ? nil : keys.joined(separator: " + ")
    }
}

extension UIKeyModifierFlags: CaseIterable {
    typealias AllCases = [UIKeyModifierFlags]

    static let allCases: [UIKeyModifierFlags] = [
        .alphaShift,
        .shift,
        .control,
        .alternate,
        .command,
        .numericPad
    ]
}

extension UIKeyModifierFlags {
    var symbols: [String?] {
        var symbols = [String?]()

        for flag in Self.allCases {
            if contains(flag) {
                symbols.append({
                    switch flag {
                    case .alphaShift:
                        "⇪"
                    case .shift:
                        "⇧"
                    case .control:
                        "^"
                    case .alternate:
                        "⌥"
                    case .command:
                        "⌘"
                    default:
                        nil
                    }
                }())
            }
        }

        return symbols
    }
}
