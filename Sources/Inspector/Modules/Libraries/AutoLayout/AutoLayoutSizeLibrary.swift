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

enum AutoLayoutSizeLibrary: Swift.CaseIterable, InspectorSizeLibraryProtocol {
    case viewFrame
    case contentLayoutPriority
    case layoutConstraints

    // MARK: - InspectorSizeLibraryProtocol

    static func viewType(forViewModel viewModel: InspectorElementViewModelProtocol) -> InspectorElementFormSectionView.Type {
        switch viewModel {
        case is NSLayoutConstraintInspectableViewModel:
            return ElementInspectorLayoutConstraintCard.self
        default:
            return ElementInspectorFormSectionContentView.self
        }
    }

    func sections(for referenceView: UIView) -> [ElementInspectorFormSection] {
        switch self {
        case .viewFrame:
            return .single(ViewFrameInspectableViewModel(view: referenceView))

        case .contentLayoutPriority:
            return .single(ContentLayoutPriorityInspectableViewModel(view: referenceView))

        case .layoutConstraints:
            var horizontalConstraints: [InspectorElementViewModelProtocol] = []
            var verticalConstraints: [InspectorElementViewModelProtocol] = []

            referenceView.constraints.forEach {
                guard
                    let rowViewModel = NSLayoutConstraintInspectableViewModel(with: $0, in: referenceView)
                else {
                    return
                }

                switch rowViewModel.axis {
                case .vertical:
                    verticalConstraints.append(rowViewModel)
                case .horizontal:
                    horizontalConstraints.append(rowViewModel)
                }
            }

            var sections: [ElementInspectorFormSection] = []

            if horizontalConstraints.isEmpty == false {
                sections.append(
                    ElementInspectorFormSection(
                        title: "Horizontal Constraints",
                        rows: horizontalConstraints
                    )
                )
            }
            if verticalConstraints.isEmpty == false {
                sections.append(
                    ElementInspectorFormSection(
                        title: "Vertical Constraints",
                        rows: verticalConstraints
                    )
                )
            }

            return sections
        }
    }

    func icon(for viewModel: InspectorElementViewModelProtocol) -> UIImage? { nil }
}
