//  Copyright (c) 2022 Pedro Almeida
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

import Foundation

import UIKit

extension DefaultElementAttributesLibrary {
    final class ApplicationShortcutItemSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        var title: String { shortcutItem.localizedTitle }

        let shortcutItem: UIApplicationShortcutItem

        init?(with object: NSObject) {
            guard let shortcutItem = object as? UIApplicationShortcutItem else { return nil }
            self.shortcutItem = shortcutItem
        }

        private enum Property: String, Swift.CaseIterable {
            case type = "Link"
            case localizedTitle = "Title"
            case localizedSubtitle = "Subtitle"
        }

        var properties: [InspectorElementProperty] {
            Property.allCases.compactMap { property in
                switch property {
                case .type:
                    return .textField(
                        title: property.rawValue,
                        placeholder: property.rawValue,
                        value: { self.shortcutItem.type }
                    )
                case .localizedTitle:
                    return .textField(
                        title: property.rawValue,
                        placeholder: .none,
                        value: { self.shortcutItem.localizedTitle }
                    )
                case .localizedSubtitle:
                    return .textField(
                        title: property.rawValue,
                        placeholder: property.rawValue,
                        value: { self.shortcutItem.localizedSubtitle }
                    )
                }
            }
        }
    }
}
