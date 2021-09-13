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

enum AutoLayoutLibrary: Swift.CaseIterable {
    case contentHuggingCompression
    case layoutConstraints

    static var standard: AllCases {
        Self.allCases
    }
}

// MARK: - InspectorAutoLayoutLibraryProtocol

extension AutoLayoutLibrary: InspectorAutoLayoutLibraryProtocol {
    static func viewType(forViewModel viewModel: InspectorElementViewModelProtocol) -> InspectorElementFormSectionView.Type {
        switch viewModel {
        case is NSLayoutConstraintInspectableViewModel:
            return ElementInspectorLayoutConstraintCard.self
        default:
            return ElementInspectorFormSectionContentView.self
        }
    }

    func viewModels(for referenceView: UIView) -> [ElementInspectorFormSection] {
        switch self {
        case .contentHuggingCompression:
            return [
                ElementInspectorFormSection(
                        rows: [
                            ContentHuggingCompressionInspectableViewModel(view: referenceView)
                        ]
                )
            ]

        case .layoutConstraints:
            var horizontal: [InspectorElementViewModelProtocol] = []
            var vertical: [InspectorElementViewModelProtocol] = []

            referenceView.constraints.forEach {
                guard let viewModel = NSLayoutConstraintInspectableViewModel(with: $0, in: referenceView) else { return }

                switch viewModel.axis {
                case .vertical:
                    vertical.append(viewModel)
                case .horizontal:
                    horizontal.append(viewModel)
                @unknown default:
                    return
                }
            }

            var sections: [ElementInspectorFormSection] = []

            if horizontal.isEmpty == false {
                sections.append(
                    ElementInspectorFormSection(
                        title: "Horizontal Constraints",
                        rows: horizontal
                    )
                )
            }
            if vertical.isEmpty == false {
                sections.append(
                    ElementInspectorFormSection(
                        title: "Vertical Constraints",
                        rows: vertical
                    )
                )
            }

            return sections
        }
    }

    func icon(for viewModel: InspectorElementViewModelProtocol) -> UIImage? { nil }
}
