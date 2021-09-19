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

protocol ElementSizePanelViewModelProtocol: ElementInspectorFormViewControllerDataSource {}

final class ElementSizePanelViewModel {
    let reference: ViewHierarchyReference

    private(set) lazy var items: [ElementInspectorFormItem] = {
        guard let referenceView = reference.rootView else { return [] }

        return AutoLayoutSizeLibrary.allCases
            .map{ $0.items(for: referenceView) }
            .flatMap { $0 }
    }()

    init(reference: ViewHierarchyReference) {
        self.reference = reference
    }
}

// MARK: - ElementSizeInspectorViewModelProtocol

extension ElementSizePanelViewModel: ElementSizePanelViewModelProtocol {
    func typeForRow(at indexPath: IndexPath) -> InspectorElementFormItemView.Type? {
        let viewModel = items[indexPath.section].rows[indexPath.row]

        return AutoLayoutSizeLibrary.viewType(forViewModel: viewModel)
    }
}
