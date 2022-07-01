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

enum DefaultElementIdentityLibrary: Swift.CaseIterable, InspectorElementLibraryProtocol {
    case preview
    case hierarchy
    case highlightView
    case runtimeAttributes

    var targetClass: AnyClass {
        NSObject.self
    }

    func sections(for object: NSObject) -> InspectorElementSections {
        switch (self, object) {
        case let (.preview, view as UIView):
            return .init(with: PreviewIdentitySectionDataSource(with: view))

        case let (.preview, viewController as UIViewController):
            return .init(with: PreviewIdentitySectionDataSource(with: viewController.view))

        case let (.highlightView, view as UIView):
            return .init(with: HighlightViewSectionDataSource(with: view))

        case let (.highlightView, viewController as UIViewController):
            return .init(with: HighlightViewSectionDataSource(with: viewController.view))

        case (.runtimeAttributes, _):
            return .init(with: RuntimeAttributesIdentitySectionDataSource(with: object))

        case (.hierarchy, _):
            return .init(with: HierarchyIdentitySectionDataSource(with: object))

        default:
            return .empty
        }
    }
}
