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

/// Element Libraries are entities that conform to `InspectorElementLibraryProtocol` and are each tied to a unique type. *Pro-tip: Enumerations are recommended.*
public protocol InspectorElementLibraryProtocol: InspectorElementFormDataSource {
    var targetClass: AnyClass { get }

    static func viewType(forViewModel viewModel: InspectorElementViewModelProtocol) -> InspectorElementFormItemView.Type?

    func items(for referenceView: UIView) -> [ElementInspectorFormItem]

    func viewModel(for referenceView: UIView) -> InspectorElementViewModelProtocol?

    func icon(for referenceView: UIView) -> UIImage?
}

// MARK: - Default Implementations

public extension InspectorElementLibraryProtocol {
    static func viewType(forViewModel viewModel: InspectorElementViewModelProtocol) -> InspectorElementFormItemView.Type? { nil }

    func items(for referenceView: UIView) -> [ElementInspectorFormItem] {
        return .single(viewModel(for: referenceView))
    }
}

// MARK: - Sequenece Extension

extension Sequence where Element == InspectorElementLibraryProtocol {
    func targeting(element: NSObject) -> [InspectorElementLibraryProtocol] {
        element.classesForCoder.flatMap { aElementClass in
            filter { $0.targetClass == aElementClass }
        }
    }

    func icon(for element: UIView?, sized size: CGSize = .elementIconSize) -> UIImage? {
        icon(for: element)?.resized(size)
    }

    private func icon(for element: UIView?) -> UIImage? {
        guard let element = element else {
            return .missingViewSymbol
        }

        if element.isHidden {
            return .hiddenViewSymbol
        }

        let candidateIcons = targeting(element: element).compactMap { $0.icon(for: element) }

        return candidateIcons.first ?? .emptyViewSymbol
    }

}
