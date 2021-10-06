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

enum ElementInspectorSizeLibrary: InspectorElementLibraryProtocol, Swift.CaseIterable {
    case segmentedControl
    case scrollView
    case label
    case viewFrame
    case contentLayoutPriority
    case layoutConstraints

    var targetClass: AnyClass {
        switch self {
        case .segmentedControl:
            return UISegmentedControl.self

        case .scrollView:
            return UIScrollView.self

        case .label:
            return UILabel.self

        case .contentLayoutPriority,
             .viewFrame,
             .layoutConstraints:
            return UIView.self
        }
    }

    func viewModel(for referenceView: UIView) -> InspectorElementViewModelProtocol? {
        fatalError()
    }

    func items(for referenceView: UIView) -> [ElementInspectorFormItem] {
        switch self {
        case .label:
            return .single(UILabelSizeAttributesViewModel(view: referenceView))

        case .segmentedControl:
            return .single(UISegmentedControlSizeAttributesViewModel(view: referenceView))

        case .scrollView:
            return .single(UIScrollViewSizeAttributesViewModel(view: referenceView))
            
        case .viewFrame:
            return .single(UIViewFrameAttributesViewModel(view: referenceView))

        case .contentLayoutPriority:
            return .single(ContentLayoutPriorityAttributesViewModel(view: referenceView))

        case .layoutConstraints:
            let element = ViewHierarchyElement(referenceView, iconProvider: .default)

            let viewModels = element.constraintElements.map {
                NSLayoutConstraintAttributesViewModel(with: $0)
            }

            let horizontal = viewModels.filter { $0.axis == .horizontal }
            let vertical = viewModels.filter { $0.axis == .vertical }

            var items: [ElementInspectorFormItem] = []

            if horizontal.isEmpty == false {
                items.append(
                    ElementInspectorFormItem(
                        title: "Horizontal Constraints",
                        rows: horizontal
                    )
                )
            }
            if vertical.isEmpty == false {
                items.append(
                    ElementInspectorFormItem(
                        title: "Vertical Constraints",
                        rows: vertical
                    )
                )
            }

            return items
        }
    }
}
