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
    case button
    case segmentedControl
    case scrollView
    case label
    case viewFrame
    case contentLayoutPriority
    case layoutConstraints

    var targetClass: AnyClass {
        switch self {
        case .button:
            return UIButton.self

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

    func sections(for referenceView: UIView) -> InspectorElementSections {
        switch self {
        case .button:
            return .init(with: UIButtonSizeViewModel(view: referenceView))

        case .label:
            return .init(with: UILabelSizeViewModel(view: referenceView))

        case .segmentedControl:
            return .init(with: UISegmentedControlSizeViewModel(view: referenceView))

        case .scrollView:
            return .init(with: UIScrollViewSizeViewModel(view: referenceView))
            
        case .viewFrame:
            return .init(with: UIViewFrameSizeViewModel(view: referenceView))

        case .contentLayoutPriority:
            return .init(with: ContentLayoutPrioritySizeViewModel(view: referenceView))

        case .layoutConstraints:
            let element = ViewHierarchyElement(with: referenceView, iconProvider: .default)

            let viewModels = element.constraintElements.map {
                NSLayoutConstraintSizeViewModel(with: $0)
            }

            let horizontal = viewModels.filter { $0.axis == .horizontal }
            let vertical = viewModels.filter { $0.axis == .vertical }

            var sections: InspectorElementSections = []

            if horizontal.isEmpty == false {
                sections.append(
                    InspectorElementSection(
                        title: "Horizontal Constraints",
                        rows: horizontal
                    )
                )
            }
            if vertical.isEmpty == false {
                sections.append(
                    InspectorElementSection(
                        title: "Vertical Constraints",
                        rows: vertical
                    )
                )
            }

            return sections
        }
    }
}
