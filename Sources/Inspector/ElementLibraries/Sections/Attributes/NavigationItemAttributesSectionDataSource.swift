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
    final class NavigationItemAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Navigation Item"

        private weak var navigationItem: UINavigationItem?

        init?(with object: NSObject) {
            guard let navigationItem = (object as? UIViewController)?.navigationItem else {
                return nil
            }

            self.navigationItem = navigationItem
        }

        private enum Property: String, Swift.CaseIterable {
            case title = "Title"
            case prompt = "Prompt"
            case backButtonTitle = "Back Button"
            case leftItemsSupplementBackButton = "Left Items Supplement"
            case LargeTitle = "Large Title"
        }

        var properties: [InspectorElementProperty] {
            guard let navigationItem = navigationItem else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .title:
                    return .textField(
                        title: property.rawValue,
                        placeholder: navigationItem.title,
                        axis: .vertical,
                        value: { navigationItem.title },
                        handler: { navigationItem.title = $0.isNilOrEmpty ? nil : $0 }
                    )
                case .prompt:
                    return .textField(
                        title: property.rawValue,
                        placeholder: navigationItem.prompt,
                        axis: .vertical,
                        value: { navigationItem.prompt },
                        handler: { navigationItem.prompt = $0.isNilOrEmpty ? nil : $0 }
                    )
                case .backButtonTitle:
                    return .textField(
                        title: property.rawValue,
                        placeholder: navigationItem.backButtonTitle,
                        axis: .vertical,
                        value: { navigationItem.backButtonTitle },
                        handler: { navigationItem.backButtonTitle = $0.isNilOrEmpty ? nil : $0 }
                    )
                case .leftItemsSupplementBackButton:
                    return .switch(
                        title: property.rawValue,
                        isOn: { navigationItem.leftItemsSupplementBackButton },
                        handler: { navigationItem.leftItemsSupplementBackButton = $0 }
                    )
                case .LargeTitle:
                    return .optionsList(
                        title: property.rawValue,
                        axis: .vertical,
                        options: UINavigationItem.LargeTitleDisplayMode.allCases.map { $0.description },
                        selectedIndex: { UINavigationItem.LargeTitleDisplayMode.allCases.firstIndex(of: navigationItem.largeTitleDisplayMode) },
                        handler: {
                            guard let newIndex = $0 else { return }

                            let largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.allCases[newIndex]
                            navigationItem.largeTitleDisplayMode = largeTitleDisplayMode
                        }
                    )
                }
            }
        }
    }
}

extension UINavigationItem.LargeTitleDisplayMode: CaseIterable {
    typealias AllCases = [UINavigationItem.LargeTitleDisplayMode]

    static let allCases: [UINavigationItem.LargeTitleDisplayMode] = [
        automatic,
        always,
        never
    ]
}

extension UINavigationItem.LargeTitleDisplayMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .automatic:
            return "Automatic"
        case .always:
            return "Always"
        case .never:
            return "Never"
        @unknown default:
            return "Unknown"
        }
    }
}
