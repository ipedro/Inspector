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
    final class ScrollViewInsetsInspectableViewModel: InspectorElementViewModelProtocol {
        private enum Properties: String, Swift.CaseIterable {
            case scrollIndicatorInsets = "Indicator Insets"
            case contentInsetsAdjustmentBehavior = "Content Insets Adjustment"
            case contentInset = "Content Inset"
            case separator
            case adjustedContentInset = "Adjusted Content Inset"
        }

        let title: String = "Scroll View"

        private weak var scrollView: UIScrollView?

        init?(view: UIView) {
            guard let scrollView = view as? UIScrollView else { return nil }
            self.scrollView = scrollView
        }

        var properties: [InspectorElementViewModelProperty] {
            guard let scrollView = scrollView else { return [] }

            return Properties.allCases.map { property in
                switch property {
                case .scrollIndicatorInsets:
                    return .edgeInsets(
                        title: property.rawValue,
                        insets: { scrollView.scrollIndicatorInsets },
                        handler: { scrollView.scrollIndicatorInsets = $0 }
                    )
                case .contentInsetsAdjustmentBehavior:
                    return .optionsList(
                        title: property.rawValue,
                        axis: .vertical,
                        options: UIScrollView.ContentInsetAdjustmentBehavior.allCases.map { $0.description },
                        selectedIndex: { UIScrollView.ContentInsetAdjustmentBehavior.allCases.firstIndex(of: scrollView.contentInsetAdjustmentBehavior) },
                        handler: {
                            guard let newIndex = $0 else { return }
                            let contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.allCases[newIndex]
                            scrollView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
                        }
                    )
                case .contentInset:
                    return .edgeInsets(
                        title: property.rawValue,
                        insets: { scrollView.contentInset },
                        handler: { scrollView.contentInset = $0 }
                    )
                case .separator:
                    return .separator

                case .adjustedContentInset:
                    return .edgeInsets(
                        title: property.rawValue,
                        insets: { scrollView.adjustedContentInset },
                        handler: nil
                    )
                }
            }
        }
    }
}
