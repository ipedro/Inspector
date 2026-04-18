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
    final class ScrollViewSizeSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title: String = "Scroll View"

        private weak var scrollView: UIScrollView?

        init?(with object: NSObject) {
            guard let scrollView = object as? UIScrollView else { return nil }
            self.scrollView = scrollView
        }

        private enum Properties: String, Swift.CaseIterable {
            case verticalScrollIndicatorInsets = "Vertical Indicator Insets"
            case horizontalScrollIndicatorInsets = "Horizontal Indicator Insets"
            case contentInsetsAdjustmentBehavior = "Content Insets Adjustment"
            case contentInset = "Content Inset"
            case separator
            case adjustedContentInset = "Adjusted Content Inset"
        }

        var propertyBindings: [InspectorPropertyBinding] {
            guard let scrollView else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .verticalScrollIndicatorInsets:
                    .init(
                        descriptor: .init(
                            id: "vertical-scroll-indicator-insets",
                            title: property.rawValue,
                            kind: .preview,
                            value: .edgeInsets,
                            editability: .editable
                        ),
                        read: { .edgeInsets(scrollView.verticalScrollIndicatorInsets) },
                        write: { newValue in
                            guard case let .edgeInsets(insets) = newValue else { return }
                            scrollView.verticalScrollIndicatorInsets = insets
                        }
                    )
                case .horizontalScrollIndicatorInsets:
                    .init(
                        descriptor: .init(
                            id: "horizontal-scroll-indicator-insets",
                            title: property.rawValue,
                            kind: .preview,
                            value: .edgeInsets,
                            editability: .editable
                        ),
                        read: { .edgeInsets(scrollView.horizontalScrollIndicatorInsets) },
                        write: { newValue in
                            guard case let .edgeInsets(insets) = newValue else { return }
                            scrollView.horizontalScrollIndicatorInsets = insets
                        }
                    )
                case .contentInsetsAdjustmentBehavior:
                    .init(
                        descriptor: .init(
                            id: "content-insets-adjustment-behavior",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(
                                .init(options: UIScrollView.ContentInsetAdjustmentBehavior.allCases.enumerated().map {
                                    .init(id: "\($0.offset)", title: $0.element.description)
                                }, allowsNil: true)
                            ),
                            editability: .editable,
                            presentation: .init(axis: .vertical)
                        ),
                        read: { .selection(UIScrollView.ContentInsetAdjustmentBehavior.allCases.firstIndex(of: scrollView.contentInsetAdjustmentBehavior)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let newIndex = index else { return }
                            let contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.allCases[newIndex]
                            scrollView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
                        }
                    )
                case .contentInset:
                    .init(
                        descriptor: .init(
                            id: "content-inset",
                            title: property.rawValue,
                            kind: .preview,
                            value: .edgeInsets,
                            editability: .editable
                        ),
                        read: { .edgeInsets(scrollView.contentInset) },
                        write: { newValue in
                            guard case let .edgeInsets(insets) = newValue else { return }
                            scrollView.contentInset = insets
                        }
                    )
                case .separator:
                    .init(
                        descriptor: .init(
                            id: "separator",
                            title: property.rawValue,
                            kind: .separator,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .adjustedContentInset:
                    .init(
                        descriptor: .init(
                            id: "adjusted-content-inset",
                            title: property.rawValue,
                            kind: .preview,
                            value: .edgeInsets,
                            editability: .readOnly
                        ),
                        read: { .edgeInsets(scrollView.adjustedContentInset) },
                        write: nil
                    )
                }
            }
        }
    }
}
