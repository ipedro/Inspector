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

extension ElementInspectorSizeLibrary {
    final class ContentLayoutPrioritySizeViewModel: InspectorElementSectionItemProtocol {
        private enum Properties: String, Swift.CaseIterable {
            case groupHuggingPriority = "Content Hugging Priority"
            case horizontalHugging = "Horizontal Hugging"
            case verticalHugging = "Vertical Hugging"
            case separator0
            case groupCompressionResistancePriority = "Content Compression Resistance Priority"
            case horizontalCompressionResistance = "Horizontal Resistance"
            case verticalCompressionResistance = "Vertical Resistance"
            case separator1
            case instrinsicContentSize = "Intrinsic Size"
        }

        let title: String = "Content Layout Priority"

        private weak var view: UIView?

        init(view: UIView) {
            self.view = view
        }

        var properties: [InspectorElementViewModelProperty] {
            guard let view = view else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .groupHuggingPriority,
                     .groupCompressionResistancePriority:
                    return .group(title: property.rawValue)

                case .horizontalHugging:
                    return .optionsList(
                        title: property.rawValue,
                        options: UILayoutPriority.allCases.map(\.description),
                        selectedIndex: { UILayoutPriority.allCases.firstIndex(of: view.contentHuggingPriority(for: .horizontal)) },
                        handler: {
                            guard let newIndex = $0 else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentHuggingPriority(priority, for: .horizontal)
                        }
                    )

                case .verticalHugging:
                    return .optionsList(
                        title: property.rawValue,
                        options: UILayoutPriority.allCases.map(\.description),
                        selectedIndex: { UILayoutPriority.allCases.firstIndex(of: view.contentHuggingPriority(for: .vertical)) },
                        handler: {
                            guard let newIndex = $0 else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentHuggingPriority(priority, for: .vertical)
                        }
                    )
                case .horizontalCompressionResistance:
                    return .optionsList(
                        title: property.rawValue,
                        options: UILayoutPriority.allCases.map(\.description),
                        selectedIndex: { UILayoutPriority.allCases.firstIndex(of: view.contentCompressionResistancePriority(for: .horizontal)) },
                        handler: {
                            guard let newIndex = $0 else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentCompressionResistancePriority(priority, for: .horizontal)
                        }
                    )
                case .verticalCompressionResistance:
                    return .optionsList(
                        title: property.rawValue,
                        options: UILayoutPriority.allCases.map(\.description),
                        selectedIndex: { UILayoutPriority.allCases.firstIndex(of: view.contentCompressionResistancePriority(for: .vertical)) },
                        handler: {
                            guard let newIndex = $0 else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentCompressionResistancePriority(priority, for: .vertical)
                        }
                    )
                case .separator0,
                     .separator1:
                    return .separator

                case .instrinsicContentSize:
                    return .cgSize(
                        title: property.rawValue,
                        size: { view.intrinsicContentSize },
                        handler: nil
                    )
                }
            }
        }
    }
}
