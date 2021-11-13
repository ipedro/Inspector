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

extension Manager: ViewHierarchyActionableProtocol {
    func perform(action: ViewHierarchyElementAction, with element: ViewHierarchyElementReference, from sourceView: UIView) {
        guard canPerform(action: action) else {
            assertionFailure("Should not happen")
            return
        }

        switch action {
        case .layer:
            viewHierarchyCoordinator?.perform(action: action, with: element, from: sourceView)

        case let .inspect(preferredPanel: preferredPanel):
            startElementInspectorCoordinator(for: element, panel: preferredPanel, from: sourceView, animated: true)

        case .copy(.className):
            UIPasteboard.general.string = element.className

        case .copy(.description):
            UIPasteboard.general.string = element.elementDescription
            
        case .copy(.report):
            UIPasteboard.general.string = element.viewHierarchyDescription
        }
    }

    func canPerform(action: ViewHierarchyElementAction) -> Bool {
        true
    }
}
