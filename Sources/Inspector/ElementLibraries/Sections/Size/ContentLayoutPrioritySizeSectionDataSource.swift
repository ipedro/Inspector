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

extension DefaultElementSizeLibrary {
    final class ContentLayoutPrioritySizeSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = "Content Layout Priority"

        private weak var view: UIView?

        init?(with object: NSObject) {
            guard let view = object as? UIView else { return nil }

            self.view = view
        }

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

        var propertyBindings: [InspectorPropertyBinding] {
            guard let view else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .groupHuggingPriority,
                     .groupCompressionResistancePriority:
                    .init(
                        descriptor: .init(
                            id: property.rawValue,
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .horizontalHugging:
                    .init(
                        descriptor: priorityDescriptor(id: "horizontal-hugging", title: property.rawValue),
                        read: { .selection(UILayoutPriority.allCases.firstIndex(of: view.contentHuggingPriority(for: .horizontal))) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentHuggingPriority(priority, for: .horizontal)
                        }
                    )

                case .verticalHugging:
                    .init(
                        descriptor: priorityDescriptor(id: "vertical-hugging", title: property.rawValue),
                        read: { .selection(UILayoutPriority.allCases.firstIndex(of: view.contentHuggingPriority(for: .vertical))) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentHuggingPriority(priority, for: .vertical)
                        }
                    )

                case .horizontalCompressionResistance:
                    .init(
                        descriptor: priorityDescriptor(id: "horizontal-compression", title: property.rawValue),
                        read: { .selection(UILayoutPriority.allCases.firstIndex(of: view.contentCompressionResistancePriority(for: .horizontal))) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentCompressionResistancePriority(priority, for: .horizontal)
                        }
                    )

                case .verticalCompressionResistance:
                    .init(
                        descriptor: priorityDescriptor(id: "vertical-compression", title: property.rawValue),
                        read: { .selection(UILayoutPriority.allCases.firstIndex(of: view.contentCompressionResistancePriority(for: .vertical))) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            let priority = UILayoutPriority.allCases[newIndex]
                            view.setContentCompressionResistancePriority(priority, for: .vertical)
                        }
                    )

                case .separator0,
                     .separator1:
                    .init(
                        descriptor: .init(
                            id: property.rawValue,
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )

                case .instrinsicContentSize:
                    .init(
                        descriptor: .init(
                            id: "intrinsic-content-size",
                            title: property.rawValue,
                            kind: .preview,
                            value: .size,
                            editability: .readOnly
                        ),
                        read: { .size(view.intrinsicContentSize) },
                        write: nil
                    )
                }
            }
        }

        private func priorityDescriptor(id: String, title: String) -> InspectorPropertyDescriptor {
            .init(
                id: id,
                title: title,
                kind: .options,
                value: .selection(
                    .init(options: UILayoutPriority.allCases.enumerated().map {
                        .init(id: "\($0.offset)", title: $0.element.description)
                    }, allowsNil: true)
                ),
                editability: .editable
            )
        }
    }
}
