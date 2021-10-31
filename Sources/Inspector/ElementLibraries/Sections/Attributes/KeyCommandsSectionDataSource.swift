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

extension ElementAttributesLibrary {
    final class KeyCommandsSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .expanded

        let title: String

        var subtitle: String?

        private let keyCommand: UIKeyCommand?

        var customClass: InspectorElementSectionView.Type? {
            InspectorElementKeyCommandSectionView.self
        }

        init?(with object: NSObject) {
            guard let keyCommand = object as? UIKeyCommand else {
                return nil
            }

            if #available(iOS 13.0, *) {
                self.subtitle = keyCommand.title
            } else {
                self.subtitle = keyCommand.discoverabilityTitle
            }

            self.title = (keyCommand.symbols ?? keyCommand.action?.description) ?? "Key Command"
            
            self.keyCommand = keyCommand
        }

        private enum Property: String, Swift.CaseIterable {
            case key = "Key"
            case selector = "Selector"
        }

        var properties: [InspectorElementProperty] {
            guard let keyCommand = keyCommand else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .key:
                    return .textField(
                        title: property.rawValue,
                        placeholder: "Enter ⌘ Key",
                        axis: .horizontal,
                        value: { keyCommand.symbols },
                        handler: nil
                    )
                case .selector:
                    return .textField(
                        title: property.rawValue,
                        placeholder: "action",
                        axis: .horizontal,
                        value: { keyCommand.action?.description },
                        handler: nil
                    )
                }
            }
        }
    }
}

extension UIKeyCommand {
    var symbols: String? {
        let keys = (modifierFlags.symbols + [input?.localizedUppercase]).compactMap {$0}

        if keys.isEmpty { return nil }

        return keys.joined(separator: " + ")
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

        Self.allCases.forEach { flag in
            if contains(flag) {
                symbols.append({
                    switch flag {
                    case .alphaShift:
                        return "⇪"
                    case .shift:
                        return "⇧"
                    case .control:
                        return "control"
                    case .alternate:
                        return "⌥"
                    case .command:
                        return "⌘"
                    default:
                        return nil
                    }
                }())
            }
        }

        return symbols
    }
}
